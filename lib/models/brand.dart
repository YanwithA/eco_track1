import 'package:flutter/material.dart';

class Brand {
  final String id;
  final String name;
  final double sustainabilityScore;
  final String imageUrl;
  final String category;
  final String description;
  final int? productCount;
  final List<String> certifications;
  final bool isFromApi;
  final DateTime? scannedAt;

  Brand({
    required this.id,
    required this.name,
    required this.sustainabilityScore,
    required this.imageUrl,
    required this.category,
    required this.description,
    this.productCount,
    List<String>? certifications,
    this.isFromApi = false,
    this.scannedAt,
  }) : certifications = certifications ?? [];

  /// Derived label from score
  String get ratingText {
    if (sustainabilityScore >= 9) return 'Excellent';
    if (sustainabilityScore >= 7) return 'Very Good';
    if (sustainabilityScore >= 5) return 'Good';
    return 'Poor';
  }

  /// Derived color from score
  Color get ratingColor {
    if (sustainabilityScore >= 9) return Colors.green;
    if (sustainabilityScore >= 7) return Colors.lightGreen;
    if (sustainabilityScore >= 5) return Colors.orange;
    return Colors.red;
  }
}
