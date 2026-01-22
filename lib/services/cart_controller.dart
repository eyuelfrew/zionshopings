import 'package:flutter/material.dart';
import 'package:zionshopings/models/product_model.dart';
import 'package:zionshopings/services/cart_service.dart';
import 'package:zionshopings/models/order_item_model.dart';

class CartController with ChangeNotifier {
  final CartService _cartService = CartService();
  List<OrderItem> _items = [];
  bool _isLoading = false;

  List<OrderItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  int get itemCount => _items.fold<int>(0, (total, item) => total + item.quantity);

  double get totalAmount => _items.fold<double>(0.0, (total, item) => total + item.subtotal);

  // Initialize and load cart from storage
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _items = await _cartService.getCartItems();
    } catch (e) {
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add product to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      await _cartService.addToCart(product, quantity: quantity);
      await loadCart(); // Reload cart to update UI
    } catch (e) {
      rethrow;
    }
  }

  // Remove product from cart
  Future<void> removeFromCart(String productId) async {
    try {
      await _cartService.removeFromCart(productId);
      await loadCart(); // Reload cart to update UI
    } catch (e) {
      rethrow;
    }
  }

  // Update quantity
  Future<void> updateQuantity(String productId, int newQuantity) async {
    try {
      await _cartService.updateQuantity(productId, newQuantity);
      await loadCart(); // Reload cart to update UI
    } catch (e) {
      rethrow;
    }
  }

  // Decrease quantity (convenience method)
  Future<void> decreaseQuantity(String productId) async {
    final item = _items.firstWhere(
      (item) => item.productId.toString() == productId,
      orElse: () => OrderItem(
        productId: 0,
        productName: '',
        price: 0,
        quantity: 0,
        subtotal: 0,
      ),
    );
    
    if (item.quantity > 0) {
      await updateQuantity(productId, item.quantity - 1);
    }
  }

  // Increase quantity (convenience method)
  Future<void> increaseQuantity(String productId) async {
    final item = _items.firstWhere(
      (item) => item.productId.toString() == productId,
      orElse: () => OrderItem(
        productId: 0,
        productName: '',
        price: 0,
        quantity: 0,
        subtotal: 0,
      ),
    );
    
    if (item.quantity > 0) {
      await updateQuantity(productId, item.quantity + 1);
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.productId.toString() == productId);
  }

  // Get product quantity in cart
  int getProductQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.productId.toString() == productId,
      orElse: () => OrderItem(
        productId: 0,
        productName: '',
        price: 0,
        quantity: 0,
        subtotal: 0,
      ),
    );
    return item.quantity;
  }
}