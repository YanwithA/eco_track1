import 'package:flutter/material.dart';
import 'package:eco_track1/widgets/product_card.dart';
import 'package:eco_track1/models/product.dart';
import 'package:eco_track1/screens/barcode_scanner_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<Product> recentScans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScannedProducts();
  }

  Future<void> _loadScannedProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }


    final dbRef = FirebaseDatabase.instance.ref('users/${user.uid}/scans');
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final loadedProducts = data.entries.map((entry) {
        final productData = Map<String, dynamic>.from(entry.value);
        return Product(
          id: entry.key,
          name: productData['name'] ?? 'Unknown Product',
          brand: productData['brand'] ?? 'Unknown Brand',
          sustainabilityScore:
          (productData['sustainabilityScore'] ?? 0).toDouble(),
          imageUrl: 'assets/images/placeholder.png',
          categories: ['Scanned'],
        );
      }).toList();

      setState(() {
        recentScans = loadedProducts.reversed.toList(); // latest first
        isLoading = false;
      });
    } else {
      setState(() {
        recentScans = [];
        isLoading = false;
      });
    }
  }


  Future<void> _handleScan(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result != null) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // You can replace this with a real lookup
      final scannedProduct = {
        'name': 'Scanned Product',
        'brand': 'Unknown Brand',
        'barcode': result,
        'sustainabilityScore': 7.5,
        'scannedAt': DateTime.now().toIso8601String(),
      };

      // Save to Firebase
      final dbRef = FirebaseDatabase.instance.ref('users/${user.uid}/scans');
      await dbRef.push().set(scannedProduct);

      // Add to local state
      setState(() {
        recentScans.add(Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: scannedProduct['name']!,
          brand: scannedProduct['brand']!,
          sustainabilityScore: scannedProduct['sustainabilityScore']!,
          imageUrl: 'assets/images/placeholder.png', // You can update this
          categories: ['Scanned'],
        ));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned and saved: $result')),
      );
    }
  }

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
                onTap: () => _handleScan(context),
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
                          color: Colors.grey,
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
