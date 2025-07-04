import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eco_track1/models/product.dart';
import 'package:eco_track1/widgets/product_card.dart';
import 'package:eco_track1/screens/barcode_scanner_screen.dart';
import 'package:eco_track1/screens/scan_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eco_track1/service/database_service.dart';
import 'dart:math';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

final _random = Random();
final _shortDescriptions = [
  'Eco-friendly packaging',
  'Sustainably sourced ingredients',
  'Cruelty-free and vegan',
  'Made with natural materials',
  'Low carbon footprint production',
  'Recyclable container',
  'Minimal water usage in production',
  'Ethically manufactured',
];

class _ScanScreenState extends State<ScanScreen> {
  List<Map<String, dynamic>> recentScans = [];
  Set<String> savedProductIds = {};
  bool isLoading = true;
  String userName = '';
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await _fetchUserProfile();
    await _loadRecentScans();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref('users/${user.uid}/profile');
    final snap = await ref.get();

    if (snap.exists) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      setState(() {
        userName = data['name'] ?? 'User';
        userEmail = data['email'] ?? user.email;
      });
    } else {
      // Create default profile if not exists
      await ref.set({
        'email': user.email,
        'name': 'Anonymous',
        'joinedAt': DateTime.now().toIso8601String(),
      });
      setState(() {
        userName = 'Anonymous';
        userEmail = user.email;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<Map<String, dynamic>> lookupProductByBarcode(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final jsonData = json.decode(resp.body);
      if (jsonData['status'] == 1) {
        final product = jsonData['product'];

        // Generate random score between 1-10 (same as DiscoverScreen)
        final score = (_random.nextInt(10) + 1).toDouble();

        return {
          'name': product['product_name'] ?? 'Unknown Product',
          'brand': (product['brands'] as String? ?? 'Unknown').split(',').first,
          'sustainabilityScore': score,
          'imageUrl': product['image_front_url'] ?? product['image_url'] ?? '',
          'description': _shortDescriptions[_random.nextInt(_shortDescriptions.length)],
        };
      }
    }
    throw Exception('Product not found');
  }
  Future<void> _loadRecentScans() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      setState(() {
        recentScans = [];
        isLoading = false;
      });
      return;
    }

    final scanSnap = await FirebaseDatabase.instance.ref('users/${u.uid}/scans').get();
    final savedSnap = await FirebaseDatabase.instance.ref('users/${u.uid}/saved').get();

    savedProductIds.clear();
    if (savedSnap.exists) {
      final savedData = Map<String, dynamic>.from(savedSnap.value as Map);
      for (var entry in savedData.entries) {
        final item = Map<String, dynamic>.from(entry.value);
        if (item['id'] != null) {
          savedProductIds.add(item['id']);
        }
      }
    }

    if (!scanSnap.exists) {
      setState(() {
        recentScans = [];
        isLoading = false;
      });
      return;
    }

    final data = Map<String, dynamic>.from(scanSnap.value as Map);
    final list = data.entries.map((e) {
      final v = Map<String, dynamic>.from(e.value);
      return {
        'product': Product(
          id: e.key,
          name: v['name'] ?? '',
          brand: v['brand'] ?? '',
          sustainabilityScore: (v['sustainabilityScore'] ?? 0).toDouble(),
          imageUrl: v['imageUrl'] ?? '',
          categories: ['Scanned'],
        ),
        'scannedAt': v['scannedAt'] ?? '',
      };
    }).toList();

    list.sort((a, b) {
      return DateTime.tryParse(b['scannedAt'])!
          .compareTo(DateTime.tryParse(a['scannedAt'])!);
    });

    setState(() {
      recentScans = list.take(5).toList();
      isLoading = false;
    });
  }

  Future<void> _handleScan() async {
    final res = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (res == null || !mounted) return;

    final code = res['barcode'] as String;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    try {
      final prod = await lookupProductByBarcode(code);
      final now = DateTime.now().toIso8601String();
      final ref = FirebaseDatabase.instance.ref('users/${u.uid}/scans').push();
      await ref.set({
        ...prod,
        'scannedAt': now,
      });

      await _loadRecentScans();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned ${prod['name']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lookup failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Scan Product'),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
          ),
        )
      ],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (userName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Welcome, $userName!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _handleScan,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  Icon(Icons.qr_code_scanner,
                      size: 60, color: Colors.green),
                  SizedBox(height: 16),
                  Text('Scan Barcode',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Get instant sustainability info',
                      style:
                      TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Recently Scanned',
            style:
            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (recentScans.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No recent scans',
                  style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...recentScans.map((e) {
            final prod = e['product'] as Product;
            final dt = DateTime.tryParse(e['scannedAt'])!
                .toLocal()
                .toString()
                .split('.')[0];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductCard(
                  product: prod,
                  maxImageSize: 64,
                  isSaved: savedProductIds.contains(prod.id),
                  onSave: savedProductIds.contains(prod.id)
                      ? null
                      : () async {
                    await saveToFavorites(
                      FirebaseAuth.instance.currentUser!.uid,
                      {
                        'id': prod.id,
                        'name': prod.name,
                        'brand': prod.brand,
                        'imageUrl': prod.imageUrl,
                        'sustainabilityScore':
                        prod.sustainabilityScore,
                        'categories': prod.categories,
                      },
                    );
                    await _loadRecentScans();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 16),
                  child: Text('Scanned on: $dt',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                )
              ],
            );
          }),
      ],
    ),
  );
}
