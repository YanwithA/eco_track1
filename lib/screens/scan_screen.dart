import 'package:flutter/material.dart';
import 'package:eco_track1/widgets/product_card.dart';
import 'package:eco_track1/models/product.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<Product> recentScans = [
    Product(
      id: '1',
      name: 'Organic Almond Milk',
      brand: 'Simple Truth',
      sustainabilityScore: 8.5,
      imageUrl: 'assets/images/almond_milk.png',
      categories: ['Food', 'Dairy Alternative'],
    ),
    Product(
      id: '2',
      name: 'Bamboo Toothbrush',
      brand: 'Brush with Bamboo',
      sustainabilityScore: 9.2,
      imageUrl: 'assets/images/toothbrush.png',
      categories: ['Personal Care', 'Bathroom'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to scan history
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Open barcode scanner
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_scanner, size: 60, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        'Scan Barcode',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get instant sustainability information',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recently Scanned',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (recentScans.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No recent scans',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: recentScans
                    .map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProductCard(product: product),
                ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}