import 'package:flutter/material.dart';
import 'package:zionshopings/models/product_model.dart';
import 'package:zionshopings/models/category_model.dart';
import 'package:zionshopings/widgets/product_card.dart';
import 'package:zionshopings/services/category_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductListingScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearchTerm;

  const ProductListingScreen({
    super.key,
    this.initialCategory,
    this.initialSearchTerm,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  // Controllers and state variables
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  // Product and category data
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Filter and sort parameters
  String? _selectedCategory;
  String _sortBy = 'date'; // Default sort by date
  String _sortDir = 'desc'; // Default sort descending
  String _searchQuery = '';

  // Refresh controller for pull-to-refresh
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    
    // Initialize with initial values if provided
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
    if (widget.initialSearchTerm != null) {
      _searchQuery = widget.initialSearchTerm!;
      _searchController.text = _searchQuery;
    }
    
    _setupScrollController();
    _setupSearchController();
    _loadInitialData();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 500) {
        if (!_isLoadingMore && _hasMore) {
          _loadMoreProducts();
        }
      }
    });
  }

  void _setupSearchController() {
    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer?.cancel();
      }
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _searchQuery = _searchController.text.trim();
          _currentPage = 1;
          _products.clear();
          _hasMore = true;
          _loadProducts();
        });
      });
    });
  }

  Future<void> _loadInitialData() async {
    try {
      // Load categories
      _categories = await CategoryService().getCategories();
      
      // Load initial products
      await _loadProducts();
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    if (_isLoading && _currentPage == 1) return; // Prevent duplicate initial loads

    try {
      setState(() {
        if (_currentPage == 1) {
          _isLoading = true;
        } else {
          _isLoadingMore = true;
        }
      });

      // Build the API URL with query parameters
      String url = 'http://localhost:5000/api/products?page=$_currentPage&limit=20';
      
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        url += '&category=$_selectedCategory';
      }
      
      if (_searchQuery.isNotEmpty) {
        url += '&search=$_searchQuery';
      }
      
      url += '&sortBy=$_sortBy&sortDir=$_sortDir';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> productsJson = [];
        int totalProducts = 0;

        if (data is Map && data.containsKey('data') && data['data'] is Map) {
          if (data['data'].containsKey('items')) {
            productsJson = data['data']['items'] as List? ?? [];
          }
          if (data['data'].containsKey('total')) {
            totalProducts = data['data']['total'] as int? ?? 0;
          }
        }

        if (_currentPage == 1) {
          _products = productsJson.map((json) => Product.fromJson(json)).toList();
        } else {
          _products.addAll(productsJson.map((json) => Product.fromJson(json)).toList());
        }

        _hasMore = _products.length < totalProducts;
      } else {
        setState(() {
          _error = 'Failed to load products: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_hasMore || _isLoadingMore) return;

    _currentPage++;
    await _loadProducts();
  }

  Future<void> _refreshProducts() async {
    _currentPage = 1;
    _products.clear();
    _hasMore = true;
    await _loadProducts();
    _refreshController.refreshCompleted();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
    });
    _loadProducts();
  }

  void _onSortChanged(String sortBy, String sortDir) {
    setState(() {
      _sortBy = sortBy;
      _sortDir = sortDir;
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category filter chips
          if (_categories.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip(null, 'All'),
                  ..._categories.map((category) => 
                    _buildCategoryChip(category.name, category.name)
                  ),
                ],
              ),
            ),

          // Sort options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSortOption('Price: Low to High', 'price', 'asc'),
                _buildSortOption('Price: High to Low', 'price', 'desc'),
                _buildSortOption('Newest First', 'date', 'desc'),
                _buildSortOption('Oldest First', 'date', 'asc'),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: _isLoading && _currentPage == 1
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _products.isEmpty
                    ? _buildErrorUI()
                    : _products.isEmpty && (_searchQuery.isNotEmpty || _selectedCategory != null)
                        ? _buildEmptyState()
                        : SmartRefresher(
                            controller: _refreshController,
                            onRefresh: _refreshProducts,
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.all(16),
                                  sliver: SliverGrid(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.7,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (index >= _products.length) {
                                          // Loading indicator at the end when loading more
                                          if (_isLoadingMore) {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: CircularProgressIndicator(),
                                              ),
                                            );
                                          }
                                          return null;
                                        }
                                        return ProductCard(product: _products[index]);
                                      },
                                      childCount: _products.length + (_isLoadingMore ? 1 : 0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? categoryValue, String categoryName) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(categoryName),
        selected: _selectedCategory == categoryValue,
        onSelected: (selected) {
          _onCategoryChanged(selected ? categoryValue : null);
        },
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: _selectedCategory == categoryValue 
              ? Colors.white 
              : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _selectedCategory == categoryValue 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String sortBy, String sortDir) {
    bool isSelected = _sortBy == sortBy && _sortDir == sortDir;
    
    return Expanded(
      child: TextButton(
        onPressed: () => _onSortChanged(sortBy, sortDir),
        style: TextButton.styleFrom(
          backgroundColor: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
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
          Text(
            _error ?? 'An error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshProducts,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search term'
                : 'Try selecting a different category',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}