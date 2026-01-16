import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zionshopings/models/category_model.dart';

class CategoryService {
  static const String _baseUrl = 'http://localhost:5000/api';

  /// Fetch all categories (legacy method - kept for backward compatibility)
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> categoriesJson = [];

        // Handle the actual API response structure for categories: { "status": "success", "data": { "categories": [...] } }
        if (data is Map && data.containsKey('data') && data['data'] is Map && data['data'].containsKey('categories')) {
          categoriesJson = data['data']['categories'] as List? ?? [];
        }

        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Fetch root categories (top-level categories with no parent)
  Future<List<Category>> getRootCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories/roots'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> categoriesJson = [];

        // Handle response structure
        if (data is Map && data.containsKey('data')) {
          if (data['data'] is List) {
            categoriesJson = data['data'] as List;
          } else if (data['data'] is Map && data['data'].containsKey('categories')) {
            categoriesJson = data['data']['categories'] as List? ?? [];
          }
        } else if (data is List) {
          categoriesJson = data;
        }

        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load root categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching root categories: $e');
    }
  }

  /// Fetch sub-categories (children) of a specific category
  Future<List<Category>> getSubCategories(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories/children/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> categoriesJson = [];

        // Handle response structure
        if (data is Map && data.containsKey('data')) {
          if (data['data'] is List) {
            categoriesJson = data['data'] as List;
          } else if (data['data'] is Map && data['data'].containsKey('categories')) {
            categoriesJson = data['data']['categories'] as List? ?? [];
          } else if (data['data'] is Map && data['data'].containsKey('children')) {
            categoriesJson = data['data']['children'] as List? ?? [];
          }
        } else if (data is List) {
          categoriesJson = data;
        }

        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // No children found - return empty list
        return [];
      } else {
        throw Exception('Failed to load sub-categories: ${response.statusCode}');
      }
    } catch (e) {
      // If error is 404 or no children, return empty list
      if (e.toString().contains('404')) {
        return [];
      }
      throw Exception('Error fetching sub-categories: $e');
    }
  }

  /// Check if a category has children
  Future<bool> hasChildren(int categoryId) async {
    try {
      final children = await getSubCategories(categoryId);
      return children.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}