import 'package:flutter/material.dart';
import 'package:zionshopings/models/category_model.dart';
import 'package:zionshopings/services/category_service.dart';
import 'package:zionshopings/widgets/skeleton_loader.dart';
import 'package:zionshopings/screens/category_products_screen.dart';
import 'package:zionshopings/theme/app_theme.dart';

class CategoryNavigationScreen extends StatefulWidget {
  final Category? parentCategory;
  final String? title;

  const CategoryNavigationScreen({
    super.key,
    this.parentCategory,
    this.title,
  });

  @override
  State<CategoryNavigationScreen> createState() => _CategoryNavigationScreenState();
}

class _CategoryNavigationScreenState extends State<CategoryNavigationScreen> {
  bool _isLoading = true;
  List<Category> _categories = [];
  String? _error;
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Category> categories;
      
      if (widget.parentCategory == null) {
        // Load root categories
        categories = await _categoryService.getRootCategories();
      } else {
        // Load sub-categories
        categories = await _categoryService.getSubCategories(widget.parentCategory!.id);
      }

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
        // Has children - navigate to another category navigation screen
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
  Widget build(BuildContext context) {
    final screenTitle = widget.title ?? 'Categories';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(screenTitle),
        centerTitle: false,
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? _buildLoadingSkeleton()
          : _error != null
              ? _buildErrorView()
              : _categories.isEmpty
                  ? _buildEmptyView()
                  : _buildCategoryGrid(),
    );
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) => const SkeletonLoader(height: 200),
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
              onPressed: _loadCategories,
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
              'There are no categories available at the moment',
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

  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    final String categoryColorHex = category.color.replaceAll('#', '0xFF');
    final Color categoryColor = Color(int.parse(categoryColorHex));
    final String imageUrl = category.image.startsWith('http')
        ? category.image
        : 'http://localhost:5000${category.image}';

    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: categoryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.category,
                          size: 48,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    // Gradient overlay for better text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                    // Category name overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (category.description != null &&
                                category.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  category.description!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Arrow indicator
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
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
