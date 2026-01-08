import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zionshopings/models/carousel_model.dart';

class CarouselService {
  static const String _baseUrl = 'http://localhost:5000';
  static const String _apiPath = '/api/carousels/active';

  Future<List<Carousel>> getActiveCarousels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_apiPath'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> carouselsJson = [];

        if (data is Map && data.containsKey('data') && data['data'] is Map && data['data'].containsKey('carousels')) {
          carouselsJson = data['data']['carousels'] as List? ?? [];
        }

        return carouselsJson.map((json) {
          final carousel = Carousel.fromJson(json);
          // Prepend base URL if not included
          String imageUrl = carousel.imageUrl;
          if (!imageUrl.startsWith('http')) {
             imageUrl = '$_baseUrl$imageUrl';
          }
          
          return Carousel(
            id: carousel.id,
            name: carousel.name,
            imageUrl: imageUrl,
            targetCategoryId: carousel.targetCategoryId,
            priority: carousel.priority,
            isActive: carousel.isActive,
          );
        }).toList();
      } else {
        throw Exception('Failed to load carousels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching carousels: $e');
    }
  }
}
