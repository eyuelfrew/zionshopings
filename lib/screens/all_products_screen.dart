import 'package:flutter/material.dart';
import 'package:zionshopings/models/product_model.dart';
import 'package:zionshopings/widgets/product_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _error;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    setState(() {
      if (_currentPage == 1) {
        _isLoading = true;
      } else {
      }
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/products?page=$_currentPage&limit=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> items = [];
        int total = 0;

        if (data is Map && data.containsKey('data')) {
           items = data['data']['items'] ?? [];
           total = data['data']['total'] ?? 0;
        }

        final List<Product> fetchedProducts = items.map((j) => Product.fromJson(j)).toList();

        setState(() {
          if (_currentPage == 1) {
            _products = fetchedProducts;
          } else {
            _products.addAll(fetchedProducts);
          }
          _hasMore = _products.length < total;
          _error = null;
        });
      } else {
        setState(() => _error = 'Failed to load products');
      }
    } catch (e) {
      setState(() => _error = 'Connection error');
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (isRefresh) {
        _refreshController.refreshCompleted();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  void _onRefresh() => _loadProducts(isRefresh: true);
  
  void _onLoading() {
    if (_hasMore) {
      _currentPage++;
      _loadProducts();
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: _isLoading && _currentPage == 1
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _products.isEmpty
                  ? _buildErrorUI()
                  : _buildGrid(),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.48,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) => ProductCard(product: _products[index]),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _onRefresh, child: const Text('Retry')),
        ],
      ),
    );
  }
}
