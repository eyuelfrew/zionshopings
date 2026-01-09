import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zionshopings/models/product_model.dart';
import 'package:zionshopings/screens/product_detail_screen.dart';
import 'package:zionshopings/services/cart_controller.dart';
import 'package:zionshopings/services/wishlist_controller.dart';
import 'package:zionshopings/theme/app_theme.dart';
import 'package:zionshopings/utils/auth_helper.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isAddingToBag = false;

  Future<void> _toggleFavorite() async {
    // Check if user is authenticated
    final isAuthenticated = await AuthHelper.requireAuth(
      context,
      message: 'Sign in to save items to your wishlist and access them across all your devices.',
    );

    if (!isAuthenticated) {
      return;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();
    
    final wishlist = context.read<WishlistController>();
    final isFav = wishlist.isFavorite(widget.product.id);
    
    wishlist.toggleFavorite(widget.product);

    // Clear current snackbar so it doesn't pile up
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !isFav 
            ? '${widget.product.name} added to wishlist' 
            : '${widget.product.name} removed from wishlist'
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            _toggleFavorite();
          },
        ),
      ),
    );
  }

  Future<void> _addToBag() async {
    // Check if user is authenticated
    final isAuthenticated = await AuthHelper.requireAuth(
      context,
      message: 'Sign in to add items to your bag and complete your purchase.',
    );

    if (!isAuthenticated) {
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    // Calculate original price with discount
    double originalPrice = widget.product.price + widget.product.discount;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: widget.product),
          ),
        );
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
            // --- 1. IMAGE SECTION ---
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0, // Ensures square image area
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Hero(
                      tag: widget.product.id,
                      child: Image.network(
                        'http://localhost:5000${widget.product.primaryImagePath}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                          Container(
                            color: Colors.grey[100], 
                            child: const Icon(Icons.image, size: 40, color: Colors.grey)
                          ),
                      ),
                    ),
                  ),
                ),
                // Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: AppTheme.primaryColor.withOpacity(0.9),
                    child: const Text(
                      'ONLY AT ZION',
                      style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // --- 2. DETAILS SECTION ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name title
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Price Section (Main Price Below Discount/Original)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.product.discount > 0)
                              Text(
                                '\$${originalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough
                                ),
                              ),
                            if (widget.product.discount > 0) const SizedBox(width: 4),
                            if (widget.product.discount > 0)
                              const Text(
                                '-%',
                                style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          index < 4 ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 12, color: AppTheme.secondaryColor,
                        )),
                        const SizedBox(width: 4),
                        const Text(' (24)', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),

                    // --- 3. ACTION BUTTON ---
                    Row(
                      children: [
                        // Wishlist Button with animation
                        GestureDetector(
                          onTap: _toggleFavorite,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              shape: BoxShape.circle,
                            ),
                              child: Consumer<WishlistController>(
                                builder: (context, wishlist, child) {
                                  final isFavorite = wishlist.isFavorite(widget.product.id);
                                  return Icon(
                                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    key: ValueKey<bool>(isFavorite),
                                    size: 14,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                  );
                                },
                              ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Add to Bag Button
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              onPressed: _isAddingToBag ? null : _addToBag,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[400],
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: _isAddingToBag
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Add to Bag',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ),
                      ],
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