import 'package:flutter/material.dart';
import 'package:zionshopings/models/product_model.dart';
import 'package:zionshopings/widgets/product_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
    if (_searchQuery.isEmpty) {
      setState(() {
        _products.clear();
        _error = null;
      });
      return;
    }

    try {
      setState(() {
        if (_currentPage == 1) {
          _isLoading = true;
        } else {
          _isLoadingMore = true;
        }
      });

      String url = 'http://localhost:5000/api/products?page=$_currentPage&limit=10&search=$_searchQuery';

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
          _error = 'Unable to find products. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error. Please check your internet.';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_hasMore || _isLoadingMore || _searchQuery.isEmpty) return;

    _currentPage++;
    await _loadProducts();
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC0CB).withOpacity(0.3), // Pink shadow
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search for products...',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFFFF69B4), // Pink color
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 1;
                _products.clear();
                _hasMore = true;
                _loadProducts();
              });
            },
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
        children: [
          // Advertisement section below the search bar
          Container(
            height: 150,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.pink[100],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1607082350899-7e105aa886ae?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Special Offer!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Products list
          Expanded(
            child: _isLoading && _currentPage == 1
                ? const Center(child: CircularProgressIndicator())
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
                               'Search Error',
                               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             const SizedBox(height: 8),
                             Text(
                               _error ?? 'Something went wrong',
                               style: Theme.of(context).textTheme.bodyMedium,
                               textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _products.isEmpty && _searchQuery.isNotEmpty
                        ? const Center(
                            child: Text(
                              'No products found',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : _products.isEmpty && _searchQuery.isEmpty
                            ? const Center(
                                child: Text(
                                  'Enter a search term to find products',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  _currentPage = 1;
                                  _products.clear();
                                  _hasMore = true;
                                  await _loadProducts();
                                },
                                child: GridView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.55,
                                  ),
                                  itemCount: _products.length + (_isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= _products.length) {
                                      // Loading indicator at the end
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    final product = _products[index];
                                    return ProductCard(product: product);
                                  },
                                ),
                              ),
          ),
        ],
      ),
      ),
    );
  }
}