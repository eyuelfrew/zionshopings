import 'package:flutter/material.dart';
import 'package:zionshopings/models/product_model.dart';

class WishlistController with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => [..._items];

  int get itemCount => _items.length;

  bool isFavorite(String productId) {
    return _items.any((item) => item.id == productId);
  }

  void toggleFavorite(Product product) {
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
