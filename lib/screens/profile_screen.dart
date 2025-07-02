import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eco_track1/screens/auth/login_screen.dart';
import 'package:eco_track1/screens/settings_screen.dart';
import 'package:eco_track1/screens/about_screen.dart';
import 'edit_profile.dart';
import 'package:eco_track1/screens/saved_brand_screen.dart';
import 'package:eco_track1/screens/scan_history_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Loading...';
  String userEmail = '';
  String userImageBase64 = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? 'No email';
      });

      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}/profile');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          userName = data['name'] ?? 'No Name';
          userImageBase64 = data['imageBase64'] ?? '';
        });
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: userName,
          currentImageBase64: userImageBase64,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        userName = result['name'];
        userImageBase64 = result['imageBase64'] ?? userImageBase64;
      });

      // ✅ Show confirmation that changes were applied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _editProfile,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: userImageBase64.isNotEmpty
                    ? MemoryImage(base64Decode(userImageBase64))
                    : const AssetImage('assets/images/profile.png')
                as ImageProvider,
                child: userImageBase64.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userEmail,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _editProfile,
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 24),
            _buildProfileSection('Activity', [
              _buildProfileItem('My Scans', Icons.history, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
                );
              }),
              const Divider(),
              _buildProfileItem('Saved Brands', Icons.bookmark, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedBrandScreen()),
                );

              }),
            ]),
            const SizedBox(height: 24),
            _buildProfileSection('More', [
              _buildProfileItem('About EcoTrack', Icons.info, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AboutScreen()),
                );
              }),
              const Divider(),
              _buildProfileItem('Logout', Icons.logout, () {
                _logout(context);
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
