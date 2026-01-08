import 'package:flutter/material.dart';
import 'package:zionshopings/screens/all_products_screen.dart';

class DiscoveryGuideSection extends StatelessWidget {
  const DiscoveryGuideSection({super.key, dynamic categories});

  final List<Map<String, dynamic>> _guideItems = const [
    {
      'title': 'Lips',
      'color': Color(0xFFFFEBEE), // Light Pink
      'image': 'https://media.istockphoto.com/id/1360667634/photo/red-lipstick-smear-on-white.jpg?s=612x612&w=0&k=20&c=K53eT8JvR8I4S4-X3uVf_v0i8R3E6XmE6I5yG9-_s_Y=', // Representative
    },
    {
      'title': 'Lip Balm',
      'color': Color(0xFFFFF0F0), // Peach
      'image': 'https://media.istockphoto.com/id/1322044810/photo/lip-balm-organic-cosmetics-with-natural-ingredients-isolated-on-white-background.jpg?s=612x612&w=0&k=20&c=L_YFjU8_m6vK5p3G_D2n7T6vL_I_N_E_F_G_H_I_J_K=',
    },
    {
      'title': 'Shampoo',
      'color': Color(0xFFE3F2FD), // Light Blue
      'image': 'https://media.istockphoto.com/id/1149451978/photo/shampoo-bottle-isolated-on-white.jpg?s=612x612&w=0&k=20&c=f-X_n_Q8u_V_v_Y_f-o_X_Y_V_v_V_v_V_v_V_v_V_w=',
    },
    {
      'title': 'Face\nWash',
      'color': Color(0xFFF1F8E9), // Light Green
      'image': 'https://media.istockphoto.com/id/1297155685/photo/face-wash-tube-isolated-on-white.jpg?s=612x612&w=0&k=20&c=v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_k=',
    },
    {
      'title': 'Kajal',
      'color': Color(0xFFF5F5F5), // Light Grey
      'image': 'https://media.istockphoto.com/id/1314644717/photo/kajal-pencil-isolated-on-white.jpg?s=612x612&w=0&k=20&c=V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_Q=',
    },
    {
      'title': 'Serums &\nEssence',
      'color': Color(0xFFF3E5F5), // Light Purple
      'image': 'https://media.istockphoto.com/id/1301980894/photo/serum-bottle-isolated-on-white.jpg?s=612x612&w=0&k=20&c=v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_I=',
    },
    {
      'title': 'Moisturizer',
      'color': Color(0xFFFFF3E0), // Light Orange
      'image': 'https://media.istockphoto.com/id/1051915952/photo/cosmetic-cream-bottle-isolated-on-white.jpg?s=612x612&w=0&k=20&c=v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_U=',
    },
    {
      'title': 'Body Wash',
      'color': Color(0xFFE0F7FA), // Light Cyan
      'image': 'https://media.istockphoto.com/id/1253406322/photo/shower-gel-bottle-isolated-on-white.jpg?s=612x612&w=0&k=20&c=v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_A=',
    },
    {
      'title': 'Suncare',
      'color': Color(0xFFFFFDE7), // Light Yellow
      'image': 'https://media.istockphoto.com/id/1304561845/photo/sunscreen-tube-isolated-on-white.jpg?s=612x612&w=0&k=20&c=v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_V_v_O=',
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
            // Representative Image (Right Aligned)
            Positioned(
              bottom: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                child: SizedBox(
                  width: 70,
                  height: 90,
                  child: Image.network(
                    item['image'],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, size: 20),
                    alignment: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
