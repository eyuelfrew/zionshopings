import 'package:flutter/material.dart';
import 'package:zionshopings/models/product_model.dart';
import 'package:zionshopings/widgets/product_card.dart';
import 'package:zionshopings/widgets/skeleton_loader.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Product> _products = [];
  String? _error;
  String _selectedCategory = '';
  String _searchQuery = '';
  String _sortBy = 'date'; // Default sort by date
  String _sortDir = 'desc'; // Default sort descending
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _setupScrollController();
    _setupSearchController();
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
          _searchQuery = _searchController.text;
          _currentPage = 1;
          _products.clear();
          _hasMore = true;
          _loadProducts();
        });
      });
    });
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        if (_currentPage == 1) {
          _isLoading = true;
        } else {
          _isLoadingMore = true;
        }
      });

      String url = 'http://localhost:5000/api/products?page=$_currentPage&limit=20';

      if (_selectedCategory.isNotEmpty) {
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

        // Handle the actual API response structure: { "status": "success", "data": { "items": [...] } }
        if (data is Map && data.containsKey('data') && data['data'] is Map && data['data'].containsKey('items')) {
          productsJson = data['data']['items'] as List? ?? [];
        }

        // Check if there are more products available
        _hasMore = productsJson.length == 20; // If we got 20 items, there might be more

        setState(() {
          if (_currentPage == 1) {
            _products = productsJson.map((json) => Product.fromJson(json)).toList();
          } else {
            _products.addAll(productsJson.map((json) => Product.fromJson(json)).toList());
          }
          _isLoading = false;
          _isLoadingMore = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Failed to load products: ${response.statusCode}';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading products: $e';
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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Listing'),
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
      body: Container(
        color: Colors.white,
        child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search for products...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', true),
                _buildCategoryChip('Electronics', false),
                _buildCategoryChip('Fashion', false),
                _buildCategoryChip('Home', false),
                _buildCategoryChip('Beauty', false),
                _buildCategoryChip('Sports', false),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Sort options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Sort by: '),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(
                      value: 'date',
                      child: Text('Date'),
                    ),
                    DropdownMenuItem(
                      value: 'price',
                      child: Text('Price'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                      _currentPage = 1;
                      _products.clear();
                      _hasMore = true;
                      _loadProducts();
                    });
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortDir,
                  items: const [
                    DropdownMenuItem(
                      value: 'asc',
                      child: Text('Asc'),
                    ),
                    DropdownMenuItem(
                      value: 'desc',
                      child: Text('Desc'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortDir = value!;
                      _currentPage = 1;
                      _products.clear();
                      _hasMore = true;
                      _loadProducts();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Products grid
          Expanded(
            child: _isLoading && _currentPage == 1
                ? _buildLoadingGrid()
                : _error != null && _products.isEmpty
                    ? _buildErrorView()
                    : _products.isEmpty
                        ? _buildEmptyView()
                        : _buildProductGrid(),
          ),
          // Loading more indicator
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isAll) {
    String displayCategory = category;
    if (category == 'All') displayCategory = 'All Products';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(displayCategory),
        selected: _selectedCategory == (isAll ? '' : category),
        selectedColor: Theme.of(context).primaryColor,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected && !isAll ? category : '';
            _currentPage = 1;
            _products.clear();
            _hasMore = true;
            _loadProducts();
          });
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
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
      ),
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        controller: _scrollController,
        itemCount: _products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 10,
          childAspectRatio: 0.55,
        ),
        itemBuilder: (context, index) {
          final product = _products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }

  Widget _buildErrorView() {
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
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentPage = 1;
                _products.clear();
                _loadProducts();
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
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
          const Text(
            'No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'No products match "$_searchQuery"'
                : _selectedCategory.isNotEmpty
                    ? 'No products in $_selectedCategory category'
                    : 'No products available',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
