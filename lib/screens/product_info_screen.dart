import 'dart:math';
import 'package:flutter/material.dart';
import 'package:eco_track1/models/product.dart';
import 'package:eco_track1/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductInfoScreen extends StatefulWidget {
  final Product product;
  const ProductInfoScreen({super.key, required this.product});

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  late Product displayProduct;
  bool alreadySaved = false;

  @override
  void initState() {
    super.initState();
    displayProduct = _withRandomDescription(widget.product);
    _checkSaved();
  }

  Product _withRandomDescription(Product p) {
    final descPool = {
      'Food': [
        'A tasty and eco‑friendly snack!',
        'Delicious and better for the planet.',
      ],
      'Personal Care': [
        'Fresh and gentle for your daily routine.',
        'Kind to your skin and the world.',
      ],
      'Household': [
        'Cleans effectively with minimal impact.',
        'Leaves your home fresh and green-friendly.',
      ],
    };
    final category = p.categories.isNotEmpty ? p.categories.first : 'Food';
    final pool = descPool[category] ?? [
      'A great sustainable choice!',
      'Carefully made with the planet in mind.',
    ];
    final desc = pool[Random().nextInt(pool.length)];
    return Product(
      id: p.id,
      name: p.name,
      brand: p.brand,
      sustainabilityScore: p.sustainabilityScore,
      imageUrl: p.imageUrl,
      categories: p.categories,
      description: desc,
    );
  }

  Future<void> _checkSaved() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final saved = await isAlreadySaved(uid, displayProduct.id);
      setState(() => alreadySaved = saved);
    }
  }

  Future<void> _saveItem() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || alreadySaved) return;

    await saveToFavorites(uid, {
      'id': displayProduct.id,
      'name': displayProduct.name,
      'brand': displayProduct.brand,
      'imageUrl': displayProduct.imageUrl,
      'sustainabilityScore': displayProduct.sustainabilityScore,
      'categories': displayProduct.categories,
      'description': displayProduct.description,
    });

    setState(() => alreadySaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayProduct.imageUrl.isNotEmpty)
              Center(
                child: Image.network(
                  displayProduct.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(displayProduct.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('by ${displayProduct.brand}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            Text(displayProduct.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: alreadySaved ? null : _saveItem,
              icon: Icon(alreadySaved ? Icons.check : Icons.bookmark_add),
              label: Text(alreadySaved ? 'Saved' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
