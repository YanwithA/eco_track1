import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eco_track1/models/brand.dart';
import 'package:eco_track1/models/product.dart';
import 'package:eco_track1/widgets/brand_card.dart';
import 'package:eco_track1/screens/product_info_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final categories = ['All', 'Food', 'Personal Care', 'Household'];
  int selectedIndex = 0;
  List<Brand> brands = [];
  bool loading = false;

  final random = Random();

  final categoryIcons = {
    'Food': Icons.fastfood,
    'Personal Care': Icons.face,
    'Household': Icons.cleaning_services,
  };

  final shortDescriptions = [
    'Eco-friendly packaging',
    'Sustainably sourced ingredients',
    'Cruelty-free and vegan',
    'Made with natural materials',
    'Low carbon footprint production',
    'Recyclable container',
    'Minimal water usage in production',
    'Ethically manufactured',
  ];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      loading = true;
      brands = [];
    });

    try {
      final selected = categories[selectedIndex];
      List<Map<String, dynamic>> results = [];

      if (selected == 'All') {
        final responses = await Future.wait([
          http.get(Uri.parse('https://world.openfoodfacts.org/category/snacks.json')),
          http.get(Uri.parse('https://world.openbeautyfacts.org/category/body-lotions.json')),
          http.get(Uri.parse('https://world.openproductsfacts.org/category/surface-cleaners.json')),
        ]);

        final parsed = responses.map((r) =>
        r.statusCode == 200 ? json.decode(r.body) : {'products': []}
        ).toList();

        results = [
          ...(parsed[0]['products'] as List<dynamic>? ?? [])
              .whereType<Map>()
              .map((p) => Map<String, dynamic>.from(p)..['category'] = 'Food'),
          ...(parsed[1]['products'] as List<dynamic>? ?? [])
              .whereType<Map>()
              .map((p) => Map<String, dynamic>.from(p)..['category'] = 'Personal Care'),
          ...(parsed[2]['products'] as List<dynamic>? ?? [])
              .whereType<Map>()
              .map((p) => Map<String, dynamic>.from(p)..['category'] = 'Household'),
        ];
      } else {
        String url = '';
        switch (selected) {
          case 'Food':
            url = 'https://world.openfoodfacts.org/category/snacks.json';
            break;
          case 'Personal Care':
            url = 'https://world.openbeautyfacts.org/category/body-lotions.json';
            break;
          case 'Household':
            url = 'https://world.openproductsfacts.org/category/surface-cleaners.json';
            break;
        }

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          results = (data['products'] as List<dynamic>? ?? [])
              .whereType<Map>()
              .map((p) => Map<String, dynamic>.from(p)..['category'] = selected)
              .toList();
        }
      }

      brands = results.map<Brand>((product) {
        final score = (random.nextInt(10) + 1).toDouble();
        final img = product['image_front_url'] ?? '';
        final category = product['category'] as String? ?? 'Unknown';

        return Brand(
          id: product['code'] ?? '',
          name: product['product_name'] ?? 'Unknown',
          imageUrl: img.isNotEmpty ? img : '',
          sustainabilityScore: score,
          category: category,
          productCount: null,
          description: shortDescriptions[random.nextInt(shortDescriptions.length)],
          certifications: [],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching items: $e');
      brands = [];
    }

    setState(() => loading = false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final sel = selectedIndex == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: ChoiceChip(
                    label: Text(categories[i]),
                    selected: sel,
                    onSelected: (_) {
                      setState(() => selectedIndex = i);
                      _fetchItems();
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: brands.length,
              itemBuilder: (ctx, i) {
                final brand = brands[i];
                return BrandCard(
                  brand: brand,
                  onTap: () {
                    // Create a Product from the Brand and pass it
                    final product = Product(
                      id: brand.id,
                      name: brand.name,
                      brand: brand.name,
                      imageUrl: brand.imageUrl,
                      categories: [brand.category],
                      sustainabilityScore: brand.sustainabilityScore,
                      description: brand.description,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductInfoScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
