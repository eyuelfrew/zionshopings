import 'package:flutter/material.dart';
import 'package:zionshopings/models/category_model.dart';
import 'package:zionshopings/screens/category_products_screen.dart';

class CategoryCard extends StatefulWidget {
  final Category category;
  final List<Category> allCategories;

  const CategoryCard({
    super.key,
    required this.category,
    required this.allCategories,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    final String categoryColorHex = widget.category.color.replaceAll('#', '0xFF');
    final Color categoryColor = Color(int.parse(categoryColorHex));
    final String imageUrl = widget.category.image.startsWith('http')
        ? widget.category.image
        : 'http://localhost:5000${widget.category.image}';

    // Check if this category has subcategories
    bool hasSubcategories = widget.allCategories
        .any((cat) => cat.parentId == widget.category.id);

    return GestureDetector(
      onTap: () async {
        // If this category has subcategories, navigate to show them
        if (hasSubcategories) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsScreen(category: widget.category),
            ),
          );
        } else {
          // If no subcategories, navigate directly to products in this category
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsScreen(category: widget.category),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white10
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            AspectRatio(
              aspectRatio: 1.0, // Ensures square image area
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                        Container(
                          color: categoryColor.withOpacity(0.1),
                          child: Icon(Icons.category, size: 40, color: categoryColor)
                        ),
                    ),
                    // Indicator for subcategories
                    if (hasSubcategories)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Details section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Name
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    widget.category.description ?? '',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}