import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zionshopings/models/category_model.dart';

class CategoryService {
  static const String _baseUrl = 'http://localhost:5000/api';

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
}