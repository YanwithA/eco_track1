import 'package:flutter/material.dart';
import 'package:eco_track1/widgets/brand_card.dart';
import 'package:eco_track1/models/brand.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final List<String> categories = [
    'All',
    'Food',
    'Fashion',
    'Personal Care',
    'Household',
    'Electronics',
  ];

  int _selectedCategoryIndex = 0;

  final List<Brand> topBrands = [
    Brand(
      id: '1',
      name: 'Patagonia',
      sustainabilityScore: 9.5,
      imageUrl: 'assets/images/patagonia.jpg',
      category: 'Fashion',
      description: 'Outdoor clothing company committed to environmental and social responsibility',
    ),
    Brand(
      id: '2',
      name: 'Seventh Generation',
      sustainabilityScore: 9.2,
      imageUrl: 'assets/images/seventh_gen.jpg',
      category: 'Household',
      description: 'Eco-friendly cleaning and personal care products',
    ),
    Brand(
      id: '3',
      name: 'Beyond Meat',
      sustainabilityScore: 8.8,
      imageUrl: 'assets/images/beyond_meat.jpg',
      category: 'Food',
      description: 'Plant-based meat alternatives with lower environmental impact',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(categories[index]),
                      selected: _selectedCategoryIndex == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Top Sustainable Brands',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: topBrands
                  .where((brand) => _selectedCategoryIndex == 0 ||
                  brand.category == categories[_selectedCategoryIndex])
                  .map((brand) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BrandCard(brand: brand),
              ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sustainability News',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/sustainability_news.jpg',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'How to Reduce Your Carbon Footprint Through Everyday Choices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Simple changes in your daily routine can significantly reduce your environmental impact...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}