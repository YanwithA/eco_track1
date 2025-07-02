import 'package:flutter/material.dart';
import 'package:eco_track1/models/product.dart';
import 'package:eco_track1/widgets/product_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  List<Product> allScans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullScanHistory();
  }

  Future<void> _loadFullScanHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseDatabase.instance
        .ref('users/${user.uid}/scans')
        .get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final loaded = data.entries.map((entry) {
        final pd = Map<String, dynamic>.from(entry.value);
        return Product(
          id: entry.key,
          name: pd['name'] ?? 'Unknown',
          brand: pd['brand'] ?? 'Unknown',
          sustainabilityScore: (pd['sustainabilityScore'] ?? 0).toDouble(),
          imageUrl: pd['imageUrl'] ?? 'assets/images/placeholder.png',
          categories: ['Scanned'],
        );
      }).toList();

      setState(() {
        allScans = loaded.reversed.toList(); // newest first
        isLoading = false;
      });
    } else {
      setState(() {
        allScans = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allScans.isEmpty
          ? const Center(child: Text('No scans found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allScans.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            product: allScans[index],
            maxImageSize: 64,
          ),
        ),
      ),
    );
  }
}
