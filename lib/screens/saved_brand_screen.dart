import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eco_track1/models/product.dart';
import 'package:eco_track1/widgets/product_card.dart';

class SavedBrandScreen extends StatefulWidget {
  const SavedBrandScreen({super.key});

  @override
  State<SavedBrandScreen> createState() => _SavedBrandScreenState();
}

class _SavedBrandScreenState extends State<SavedBrandScreen> {
  List<Product> savedProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedProducts();
  }

  Future<void> _loadSavedProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        savedProducts = [];
      });
      return;
    }

    final snapshot = await FirebaseDatabase.instance
        .ref('users/${user.uid}/saved')
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
          categories: ['Saved'],
        );
      }).toList();

      setState(() {
        savedProducts = loaded;
        isLoading = false;
      });
    } else {
      setState(() {
        savedProducts = [];
        isLoading = false;
      });
    }
  }

  Future<void> _unsaveProduct(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref('users/${user.uid}/saved/$productId');
    await ref.remove();

    setState(() {
      savedProducts.removeWhere((p) => p.id == productId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Brands'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedProducts.isEmpty
          ? const Center(child: Text('No saved products'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedProducts.length,
        itemBuilder: (context, index) {
          final product = savedProducts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductCard(
              product: product,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _unsaveProduct(product.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
