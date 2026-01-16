import 'package:flutter/material.dart';
import 'package:zionshopings/models/product_model.dart';
import 'package:zionshopings/widgets/product_card.dart';
import 'package:zionshopings/widgets/skeleton_loader.dart';
import 'package:zionshopings/widgets/category_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Category category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  bool _isLoading = true;
  List<Product> _products = [];
  List<Category> _subCategories = [];
  List<Category> _allCategories = [];
  String? _error;
  final String _baseUrl = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all categories to determine if there are subcategories
      _allCategories = await CategoryService().getCategories();
      _subCategories = _allCategories.where((c) => c.parentId == widget.category.id).toList();

      // If there are no subcategories, load products for this category
      if (_subCategories.isEmpty) {
        await _loadCategoryProducts();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      _error = 'Error loading data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategoryProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/products?category=${widget.category.name}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> productsJson = [];

        // Handle the actual API response structure: { "status": "success", "data": { "items": [...] } }
        if (data is Map && data.containsKey('data') && data['data'] is Map && data['data'].containsKey('items')) {
          productsJson = data['data']['items'] as List? ?? [];
        }

        _products = productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        _error = 'Failed to load products: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error loading products: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String categoryColorHex = widget.category.color.replaceAll('#', '0xFF');
    final Color categoryColor = Color(int.parse(categoryColorHex));
    final String imageUrl = widget.category.image.startsWith('http') 
        ? widget.category.image 
        : '$_baseUrl${widget.category.image}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Brand Identity Header
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  widget.category.name,
                  style: const TextStyle(
                    fontFamily: 'Serif', 
                    fontSize: 42,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Beauty'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 4,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                // Hero Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: categoryColor.withOpacity(0.1),
                        child: Icon(Icons.category, size: 50, color: categoryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 2. Sub-categories Circular List
          if (_subCategories.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 125,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _subCategories.length,
                  itemBuilder: (context, index) {
                    final sub = _subCategories[index];
                    final subImageUrl = sub.image.startsWith('http') 
                        ? sub.image 
                        : '$_baseUrl${sub.image}';
                    return GestureDetector(
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryProductsScreen(category: sub),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                                image: DecorationImage(
                                  image: NetworkImage(subImageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sub.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 3. Category Stats & Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_subCategories.isNotEmpty)
                    Text(
                      '${_subCategories.length} subcategories',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    )
                  else
                    Text(
                      '${_products.length} products',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  const SizedBox(height: 16),
                  if (_subCategories.isEmpty) // Only show filters for products, not subcategories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('🎁 Most Gifted'),
                          _buildFilterChip('🔥 New at Zion'),
                          _buildFilterChip('⭐ Top Rated'),
                          _buildFilterChip('👍 Bestseller'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 4. Content Grid (either subcategories or products)
          if (_isLoading)
            SliverFillRemaining(
              child: _buildLoadingSkeleton(),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(child: Text('Error: $_error')),
            )
          else if (_subCategories.isNotEmpty)
            // Show subcategories
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.52,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subCategory = _subCategories[index];
                    return CategoryCard(
                      category: subCategory,
                      allCategories: _allCategories, // Pass all categories to determine if subcategory has its own subcategories
                    );
                  },
                  childCount: _subCategories.length,
                ),
              ),
            )
          else if (_products.isEmpty)
            SliverFillRemaining(
              child: const Center(child: Text('No products found')),
            )
          else
            // Show products
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.52,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(product: _products[index]),
                  childCount: _products.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (context, index) => const SkeletonLoader(height: 250),
    );
  }
}