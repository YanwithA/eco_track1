import 'package:flutter/material.dart';
import 'package:eco_track1/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final Widget? trailing;
  final double maxImageSize;
  final bool isSaved;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onSave,
    this.trailing,
    this.maxImageSize = 64, // Avoid pixel overflow
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl.startsWith('http')
                    ? Image.network(
                  product.imageUrl,
                  width: maxImageSize,
                  height: maxImageSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 40),
                )
                    : Image.asset(
                  product.imageUrl,
                  width: maxImageSize,
                  height: maxImageSize,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      product.brand,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.ratingColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.sustainabilityScore}/10',
                            style: TextStyle(
                              color: product.ratingColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.ratingText,
                          style: TextStyle(
                            color: product.ratingColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: product.categories
                          .map(
                            (category) => Chip(
                          label: Text(category),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                          .toList(),
                    ),
                    if (onSave != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: isSaved ? null : onSave,
                          icon: Icon(isSaved ? Icons.bookmark_added : Icons.bookmark_add),
                          label: Text(isSaved ? "Saved" : "Save"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaved ? Colors.grey : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
              ]
            ],
          ),
        ),
      ),
    );
  }
}
