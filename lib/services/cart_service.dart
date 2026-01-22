import 'dart:convert';
import '../models/order_item_model.dart';
import '../models/product_model.dart';
import '../utils/storage.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';
  
  /// Get cart items from storage
  Future<List<OrderItem>> getCartItems() async {
    try {
      final cartJson = await Storage.read(_cartKey);
      if (cartJson == null || cartJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> cartList = jsonDecode(cartJson);
      return cartList.map((item) => OrderItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Save cart items to storage
  Future<void> _saveCartItems(List<OrderItem> items) async {
    try {
      final cartJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await Storage.write(_cartKey, cartJson);
    // ignore: empty_catches
    } catch (e) {
    }
  }
  
  /// Add product to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      final cartItems = await getCartItems();
      
      // Check if product already exists in cart
      final existingIndex = cartItems.indexWhere(
        (item) => item.productId.toString() == product.id,
      );
      
      if (existingIndex >= 0) {
        // Update quantity
        final existingItem = cartItems[existingIndex];
        cartItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
          subtotal: (existingItem.quantity + quantity) * existingItem.price,
        );
      } else {
        // Add new item
        final newItem = OrderItem(
          productId: int.tryParse(product.id) ?? 0,
          productName: product.name,
          price: product.price,
          quantity: quantity,
          subtotal: product.price * quantity,
          productImage: product.primaryImagePath,
        );
        cartItems.add(newItem);
      }
      
      await _saveCartItems(cartItems);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Update item quantity in cart
  Future<void> updateQuantity(String productId, int newQuantity) async {
    try {
      final cartItems = await getCartItems();
      
      if (newQuantity <= 0) {
        // Remove item if quantity is 0 or less
        cartItems.removeWhere((item) => item.productId.toString() == productId);
      } else {
        // Update quantity
        final index = cartItems.indexWhere(
          (item) => item.productId.toString() == productId,
        );
        
        if (index >= 0) {
          final item = cartItems[index];
          cartItems[index] = item.copyWith(
            quantity: newQuantity,
            subtotal: newQuantity * item.price,
          );
        }
      }
      
      await _saveCartItems(cartItems);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      final cartItems = await getCartItems();
      cartItems.removeWhere((item) => item.productId.toString() == productId);
      await _saveCartItems(cartItems);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      await Storage.delete(_cartKey);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get cart total amount
  Future<double> getCartTotal() async {
    try {
      final cartItems = await getCartItems();
      return cartItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
    } catch (e) {
      return 0.0;
    }
  }
  
  /// Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final cartItems = await getCartItems();
      return cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      return 0;
    }
  }
  
  /// Check if product is in cart
  Future<bool> isInCart(String productId) async {
    try {
      final cartItems = await getCartItems();
      return cartItems.any((item) => item.productId.toString() == productId);
    } catch (e) {
      return false;
    }
  }
  
  /// Get quantity of specific product in cart
  Future<int> getProductQuantity(String productId) async {
    try {
      final cartItems = await getCartItems();
      final item = cartItems.firstWhere(
        (item) => item.productId.toString() == productId,
        orElse: () => OrderItem(
          productId: int.tryParse(productId) ?? 0,
          productName: '',
          price: 0,
          quantity: 0,
          subtotal: 0,
        ),
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
}