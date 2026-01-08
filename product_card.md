import 'package:flutter/material.dart';

class NykaaStyleProductCard extends StatelessWidget {
  final String imageUrl;
  final String brandName;
  final String productName;
  final String variantInfo;
  final String originalPrice;
  final String finalPrice;
  final String discountPercentage;
  final String priceDropAmount;
  final double rating;
  final int reviewCount;

  const NykaaStyleProductCard({
    super.key,
    required this.imageUrl,
    required this.brandName,
    required this.productName,
    required this.variantInfo,
    required this.originalPrice,
    required this.finalPrice,
    required this.discountPercentage,
    required this.priceDropAmount,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, // Fixed width for testing, remove if used in GridView
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Product Image
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.1, // Slightly taller than square
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Optional: You could add a "Featured" tag here if needed
            ],
          ),

          // 2. Product Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Only at..." Tag
                Text(
                  'ONLY AT NYKAA',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),

                // Brand Name
                Text(
                  brandName.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                
                // Product Title
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Variant Info (e.g., 8 Pcs)
                Text(
                  variantInfo,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),

                // Price Row
                Row(
                  children: [
                    Text(
                      originalPrice,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      finalPrice,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      height: 12,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: Colors.grey[300],
                    ),
                    Text(
                      discountPercentage,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Price Drop Green Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_downward, size: 12, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Price dropped by $priceDropAmount',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Rating Row
                Row(
                  children: [
                    // Stars
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rating.floor() ? Icons.star : Icons.star_border,
                        size: 14,
                        color: Colors.grey[800],
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '($reviewCount)',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(), // Pushes buttons to the bottom if container is tall
          const SizedBox(height: 12),

          // 3. Footer Buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Heart Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite_border, color: Colors.pink[400], size: 20),
                ),
                const SizedBox(width: 10),
                
                // Add to Bag Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63), // Pink color
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: const Text(
                      'Add to Bag',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}