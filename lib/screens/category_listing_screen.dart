import 'package:flutter/material.dart';
import 'package:zionshopings/models/category_model.dart';
import 'package:zionshopings/services/category_service.dart';
import 'package:zionshopings/screens/category_navigation_screen.dart';
import 'package:zionshopings/screens/category_products_screen.dart';
import 'package:zionshopings/widgets/skeleton_loader.dart';
import 'package:zionshopings/theme/app_theme.dart';
import 'dart:async';

class CategoryListingScreen extends StatefulWidget {
  const CategoryListingScreen({super.key});

  @override
  _CategoryListingScreenState createState() => _CategoryListingScreenState();
}

class _CategoryListingScreenState extends State<CategoryListingScreen> {
  bool _isLoading = true;
  List<Category> _rootCategories = [];
  String? _error;

  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _loadRootCategories();
  }



  Future<void> _loadRootCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final categories = await _categoryService.getRootCategories();

      setState(() {
        _rootCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading categories: $e';
        _isLoading = false;
      });
    }
  }



  Future<void> _onCategoryTap(Category category) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );

    try {
      // Check if category has children
      final children = await _categoryService.getSubCategories(category.id);
      
      // Dismiss loading
      if (mounted) Navigator.pop(context);

      if (children.isNotEmpty) {
        // Has children - navigate to category navigation screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryNavigationScreen(
                parentCategory: category,
                title: category.name,
              ),
            ),
          );
        }
      } else {
        // No children - it's a leaf category, show products
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsScreen(category: category),
            ),
          );
        }
      }
    } catch (e) {
      // Dismiss loading
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Shop by Category'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 2,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? _buildLoadingList()
          : _error != null
              ? _buildErrorView()
              : _rootCategories.isEmpty
                  ? _buildEmptyView()
                  : _buildCategoryList(),
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return const SkeletonLoader(height: 100);
      },
    );
  }

  Widget _buildCategoryList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: _rootCategories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final category = _rootCategories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    // Parse color or use default for placeholder/loading background
    Color categoryColor;
    try {
      categoryColor = Color(int.parse(category.color.replaceAll('#', '0xFF')));
    } catch (e) {
      categoryColor = const Color(0xFFFCE4EC); 
    }

    final String imageUrl = category.image.startsWith('http')
        ? category.image
        : 'http://localhost:5000${category.image}';

    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: Container(
        height: 120, // Increased height for better banner visibility
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: categoryColor.withOpacity(0.2),
              alignment: Alignment.center,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: categoryColor,
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: categoryColor.withOpacity(0.1),
                alignment: Alignment.center,
                child: SizedBox(
                   width: 30,
                   height: 30,
                   child: CircularProgressIndicator(
                     value: loadingProgress.expectedTotalBytes != null
                         ? loadingProgress.cumulativeBytesLoaded /
                             loadingProgress.expectedTotalBytes!
                         : null,
                     color: categoryColor,
                     strokeWidth: 2,
                   ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRootCategories,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No categories available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
