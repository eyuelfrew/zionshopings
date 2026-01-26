import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zionshopings/models/product_model.dart';
import 'package:zionshopings/models/category_model.dart';
import 'package:zionshopings/services/category_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:zionshopings/widgets/product_card.dart';
import 'package:zionshopings/widgets/search_bar.dart';
import 'package:zionshopings/widgets/promo_carousel.dart';
import 'package:zionshopings/widgets/skeleton_loader.dart';
import 'package:zionshopings/widgets/new_arrivals_section.dart';
import 'package:zionshopings/widgets/discovery_guide_section.dart';
import 'package:zionshopings/screens/all_products_screen.dart';
import 'package:zionshopings/screens/cart_screen.dart';
import 'package:zionshopings/screens/wishlist_screen.dart';
import 'package:zionshopings/screens/category_products_screen.dart';
import 'package:zionshopings/screens/search_screen.dart';
import 'package:zionshopings/services/cart_controller.dart';
import 'package:zionshopings/services/carousel_service.dart';
import 'package:zionshopings/models/carousel_model.dart';
import 'package:zionshopings/theme/app_theme.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zionshopings/utils/auth_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Carousel> _carousels = [];
  bool _isCarouselLoading = true;
  String? _error;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      if (_currentPage == 1) {
        _isLoading = true;
      }
    });

    try {
      // Only load categories on the first page load
      if (_currentPage == 1 && _categories.isEmpty) {
        _categories = await CategoryService().getCategories().timeout(const Duration(seconds: 10));
      }

      // Load carousels on the first page load
      if (_currentPage == 1) {
        setState(() => _isCarouselLoading = true);
        try {
          _carousels = await CarouselService().getActiveCarousels().timeout(const Duration(seconds: 10));
        } catch (e) {
          // We don't want to block the whole page if carousels fail
        } finally {
          setState(() => _isCarouselLoading = false);
        }
      }

      final productsResponse = await http.get(
        Uri.parse('http://localhost:5000/api/products?page=$_currentPage&limit=10'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (productsResponse.statusCode == 200) {
        final data = json.decode(productsResponse.body);
        List<dynamic> productsJson = [];

        if (data is Map && data.containsKey('data') && data['data'] is Map) {
          if (data['data'].containsKey('items')) {
            productsJson = data['data']['items'] as List? ?? [];
          }
        }

        if (_currentPage == 1) {
          _products = productsJson.map((json) => Product.fromJson(json)).toList();
        } else {
          _products.addAll(productsJson.map((json) => Product.fromJson(json)).toList());
        }
      } else {
        _error = 'Failed to load products: ${productsResponse.statusCode}';
      }

    } catch (e) {
      _error = 'Error loading data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    _currentPage = 1;
    _products.clear();
    await _loadData();
    
    // Complete the refresh
    if (_error == null) {
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onCategorySelected(Category? category) {
    if (category != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryProductsScreen(category: category),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Zion Shopings'),
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
        actions: [
          // Favorites/Heart icon
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
            onPressed: () async {
              final isAuthenticated = await AuthHelper.requireAuth(
                context,
                message: 'Sign in to view your wishlist and save your favorite items.',
              );
              
              if (isAuthenticated && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistScreen()),
                );
              }
            },
          ),
          // Shopping bag/Cart icon with badge
           Consumer<CartController>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    onPressed: () async {
                      final isAuthenticated = await AuthHelper.requireAuth(
                        context,
                        message: 'Sign in to view your shopping bag and complete your purchase.',
                      );
                      
                      if (isAuthenticated && mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      }
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
        child: Column(
          children: [
            // Search Bar - Fixed at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CustomSearchBar(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
              ),
            ),

            // Scrollable content below the search bar
            Expanded(
              child: SmartRefresher(
                enablePullDown: true,
                header: const WaterDropHeader(),
                onRefresh: _refreshData,
                controller: _refreshController,
                child: _isLoading && _currentPage == 1
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            // Category skeleton
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: _buildCategorySkeleton(),
                            ),
                            // Product skeleton
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                              child: _buildLoadingSkeleton(),
                            ),
                          ],
                        ),
                      )
                    : _error != null && _products.isEmpty
                        ? Center(
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
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _refreshData,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _products.isEmpty
                            ? const Center(
                                child: Text(
                                  'No products found',
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                            : CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  // Category Cards
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: _error != null
                                          ? Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: Text('Error: $_error'),
                                            )
                                          : SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: Row(
                                                children: [
                                                  // All category
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 20),
                                                    child: _buildDynamicCategoryCard(
                                                      context,
                                                      null, // null for 'All' category
                                                      'All',
                                                      'https://via.placeholder.com/60x60', // Placeholder for All category
                                                      '#E0E0E0', // Default color for All
                                                    ),
                                                  ),
                                                  // Dynamic categories from API
                                                  ..._categories.map((category) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(right: 20),
                                                      child: _buildDynamicCategoryCard(
                                                        context,
                                                        category,
                                                        category.name,
                                                        'http://localhost:5000${category.image}',
                                                        category.color,
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),

                                  // Promotional Carousel
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: PromoCarousel(
                                        carousels: _carousels,
                                        categories: _categories,
                                        isLoading: _isCarouselLoading,
                                      ),
                                    ),
                                  ),

                                  // Product Grid (Limited to 6 items)
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                     sliver: SliverGrid(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 0.48,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final product = _products[index];
                                          return ProductCard(product: product);
                                        },
                                        // Display only 6 items on home
                                        childCount: _products.length < 6 ? _products.length : 6,
                                      ),
                                    ),
                                  ),

                                  // View All Bottom Button
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 55,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const AllProductsScreen()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.surface,
                                            foregroundColor: AppTheme.primaryColor,
                                            elevation: 0,
                                            side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'View All Products',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.chevron_right),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // New Arrivals Horizontal Section
                                  SliverToBoxAdapter(
                                    child: NewArrivalsSection(
                                      products: _products.take(8).toList(),
                                    ),
                                  ),

                                  // Discovery Guide 3x3 Grid Section
                                  SliverToBoxAdapter(
                                    child: DiscoveryGuideSection(
                                      categories: _categories,
                                    ),
                                  ),
                                ],
                              ),
              ),
            ),
          ],
        ),
      ),
    )
    );}

  Widget _buildDynamicCategoryCard(
    BuildContext context,
    Category? category,
    String title,
    String imageUrl,
    String colorHex,
  ) {
    // 1. Parse the dynamic color
    Color color = const Color(0xFFE0E0E0); // Default color
    try {
      color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      color = const Color(0xFFE0E0E0);
    }

    return GestureDetector(
      onTap: () => _onCategorySelected(category),
      child: Column(
        children: [
          // The Circular Container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withAlpha((255 * 0.5).round()),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                fit: StackFit.expand, // Ensures child widgets fill the circle
                children: [
                  // Layer 1: The Image
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.category_outlined,
                          color: Colors.grey[600],
                          size: 30,
                        ),
                      );
                    },
                  ),

                  // Layer 2: The Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        // Stops ensure the gradient fades out before reaching the top
                        stops: const [0.0, 0.6],
                        colors: [
                          // Start with the dynamic color at the bottom (with some opacity)
                          color.withAlpha((255 * 0.7).round()),
                          // Fade to completely transparent moving upwards
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ], // <-- close children list (was missing)
              ), // <-- close parent widget (e.g., Stack)
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySkeleton() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 10,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (context, index) {
        return const SkeletonLoader(height: 250);
      },
    );
  }
}
