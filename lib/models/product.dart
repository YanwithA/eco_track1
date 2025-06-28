import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final double sustainabilityScore;
  final String imageUrl;
  final List<String> categories;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.sustainabilityScore,
    required this.imageUrl,
    required this.categories,
  });

  String get ratingText {
    if (sustainabilityScore >= 9) return 'Excellent';
    if (sustainabilityScore >= 7) return 'Very Good';
    if (sustainabilityScore >= 5) return 'Good';
    return 'Needs Improvement';
  }

  Color get ratingColor {
    if (sustainabilityScore >= 9) return Colors.green;
    if (sustainabilityScore >= 7) return Colors.lightGreen;
    if (sustainabilityScore >= 5) return Colors.orange;
    return Colors.red;
  }
}