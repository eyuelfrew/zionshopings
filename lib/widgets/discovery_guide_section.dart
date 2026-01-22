import 'package:flutter/material.dart';
import 'package:zionshopings/screens/all_products_screen.dart';

class DiscoveryGuideSection extends StatelessWidget {
  const DiscoveryGuideSection({super.key, dynamic categories});

  final List<Map<String, dynamic>> _guideItems = const [
    {
      'title': 'Lips',
      'color': Color(0xFFFFEBEE), // Light Pink
      'icon': Icons.face_retouching_natural,
    },
    {
      'title': 'Lip Balm',
      'color': Color(0xFFFFF0F0), // Peach
      'icon': Icons.favorite_border,
    },
    {
      'title': 'Shampoo',
      'color': Color(0xFFE3F2FD), // Light Blue
      'icon': Icons.water_drop_outlined,
    },
    {
      'title': 'Face\nWash',
      'color': Color(0xFFF1F8E9), // Light Green
      'icon': Icons.face,
    },
    {
      'title': 'Kajal',
      'color': Color(0xFFF5F5F5), // Light Grey
      'icon': Icons.brush,
    },
    {
      'title': 'Serums &\nEssence',
      'color': Color(0xFFF3E5F5), // Light Purple
      'icon': Icons.science_outlined,
    },
    {
      'title': 'Moisturizer',
      'color': Color(0xFFFFF3E0), // Light Orange
      'icon': Icons.spa_outlined,
    },
    {
      'title': 'Body Wash',
      'color': Color(0xFFE0F7FA), // Light Cyan
      'icon': Icons.shower_outlined,
    },
    {
      'title': 'Suncare',
      'color': Color(0xFFFFFDE7), // Light Yellow
      'icon': Icons.wb_sunny_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Text(
            'Need Help Choosing? Start Here!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF001F3F), // Dark Navy
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _guideItems.length,
          itemBuilder: (context, index) {
            final item = _guideItems[index];
            return _buildGuideCard(context, item);
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildGuideCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllProductsScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: item['color'],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Title
            Positioned(
              top: 15,
              left: 15,
              child: Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF333333),
                  height: 1.1,
                ),
              ),
            ),
            // Arrow Button
            Positioned(
              bottom: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withOpacity(0.4), width: 1.5),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
            // Icon (Right Aligned)
            Positioned(
              bottom: 15,
              right: 15,
              child: Icon(
                item['icon'],
                size: 40,
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
