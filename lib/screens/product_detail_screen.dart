import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zionshopings/models/product_model.dart';
import 'package:zionshopings/services/cart_controller.dart';
import 'package:zionshopings/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAddingToBag = false;
  List<Product> _relatedProducts = [];
  bool _isLoadingRelated = true;
  String? _relatedProductsError;

  @override
  void initState() {
    super.initState();
    _loadRelatedProducts();
  }

  Future<void> _addToBag() async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      _isAddingToBag = true;
    });

    // Add to global cart state
    context.read<CartController>().addToCart(widget.product);

    // Simulate small feedback delay
    await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _isAddingToBag = false;
        });

        // Clear current snackbar so it doesn't stay visible indefinitely/pile up
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.name} added to bag'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
  }

  Future<void> _loadRelatedProducts() async {
    try {
      // Fetch products from the same category, excluding the current product
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/products?category=${widget.product.category}&limit=10'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> productsJson = [];

        // Handle the actual API response structure: { "status": "success", "data": { "items": [...] } }
        if (data is Map && data.containsKey('data') && data['data'] is Map && data['data'].containsKey('items')) {
          productsJson = data['data']['items'] as List? ?? [];
        }

        // Filter out the current product and take up to 4 related products
        final allRelated = productsJson
            .map((json) => Product.fromJson(json))
            .where((product) => product.id != widget.product.id)
            .take(4)
            .toList();

        setState(() {
          _relatedProducts = allRelated;
          _isLoadingRelated = false;
        });
      } else {
        setState(() {
          _relatedProductsError = 'Failed to load related products';
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      setState(() {
        _relatedProductsError = 'Error loading related products: $e';
        _isLoadingRelated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.product.id,
                child: widget.product.images.isNotEmpty
                    ? Image.network(
                        'http://localhost:5000${widget.product.images[0]['path']}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[600],
                              size: 60,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey[600],
                          size: 60,
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name, Price, Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        '4.0', // Using a default rating since it's not in the API model
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Product Info
                  _buildInfoRow('Brand', widget.product.brand),
                  const SizedBox(height: 10),
                  _buildInfoRow('Category', widget.product.category),
                  const SizedBox(height: 10),
                  _buildInfoRow('Stock', widget.product.stock.toString()),
                  const SizedBox(height: 10),
                  _buildInfoRow('Status', widget.product.status),
                  const SizedBox(height: 10),
                  _buildInfoRow('Created', widget.product.createdAt),
                  const SizedBox(height: 20), // Space before related products

                  // Related Products Section
                  if (_relatedProducts.isNotEmpty || _isLoadingRelated || _relatedProductsError != null)
                    _buildRelatedProductsSection(),

                  const SizedBox(height: 80), // Extra space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 42,
        child: FloatingActionButton.extended(
          onPressed: _isAddingToBag ? null : _addToBag,
          label: _isAddingToBag 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Add to Bag',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
          icon: _isAddingToBag ? null : const Icon(Icons.shopping_bag_outlined, size: 20),
          backgroundColor: _isAddingToBag 
              ? Colors.grey 
              : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            'Related Products',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
        ),
        const SizedBox(height: 15),
        _isLoadingRelated
            ? SizedBox(
                height: 200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : _relatedProductsError != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(_relatedProductsError!),
                          TextButton(
                            onPressed: _loadRelatedProducts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _relatedProducts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('No related products found'),
                        ),
                      )
                    : SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _relatedProducts.length,
                          itemBuilder: (context, index) {
                            final product = _relatedProducts[index];
                            return Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 15),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Image
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          widget.product.images.isNotEmpty
                                              ? 'http://localhost:5000${widget.product.images[0]['path']}'
                                              : 'http://localhost:5000${product.images.isNotEmpty ? product.images[0]['path'] : ''}',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.image_not_supported_outlined,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Product Name and Price
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ],
    );
  }
}
