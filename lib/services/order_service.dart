import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/order_model.dart';

class OrderService {
  // Update this with your backend IP
  static const baseUrl = "http://localhost:5000/api";
  
  // For iOS Simulator, use:
  // static const baseUrl = "http://localhost:5000/api";
  
  // For Physical Device, replace with your computer's IP:
  // static const baseUrl = "http://192.168.1.XXX:5000/api";

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';

  /// Get authorization headers with backend access token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: _accessTokenKey);
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create a new order
  Future<Order> createOrder(Order order) async {
    try {
      
      final headers = await _getHeaders();
      final body = jsonEncode(order.toJson());
      
      final response = await http.post(
        Uri.parse('$baseUrl/orders/create'),
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection.');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Backend returns minimal response: { success, orderId, orderNumber }
        // We need to fetch the full order details
        final orderId = data['orderId'];
        final orderNumber = data['orderNumber'] ?? data['order_number'];
        
        if (orderId != null) {
          // Fetch the complete order details
          try {
            final fullOrder = await getOrderDetails(orderId);
            return fullOrder;
          } catch (e) {
            // Fallback: return the original order with updated ID and orderNumber
            return order.copyWith(
              id: orderId,
              orderNumber: orderNumber,
            );
          }
        } else {
          // Fallback: return the original order
          return order;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please sign in again.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Check Telebirr transaction status
  Future<Map<String, dynamic>> checkTelebirrTransaction({
    required String transactionId,
    required int orderId,
    required double orderAmount, required String paymentMethod,
  }) async {
    try {
      
      final headers = await _getHeaders();
      final body = jsonEncode({
        'transactionId': transactionId,
        'orderId': orderId,
        'orderAmount': orderAmount,
        'paymentMethod': paymentMethod,
      });
      
      final response = await http.post(
        Uri.parse('$baseUrl/orders/check-telebirr-transaction'),
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Transaction verification timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Transaction verification completed',
          'details': data['details'] ?? {},
        };
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please sign in again.');
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Transaction verification failed',
          'details': {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying transaction: $e',
        'details': {},
      };
    }
  }

  /// Get user's orders
  Future<List<Order>> getMyOrders() async {
    try {
      
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/orders/my-orders'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );


      if (response.statusCode == 200) {
        // Parse the response
        dynamic data;
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Invalid response format');
        }
        
        // Handle different response structures
        final ordersData = data is Map ? (data['data'] ?? data['orders'] ?? data) : data;
        
        // If ordersData is not a list, return empty
        if (ordersData is! List) {
          return [];
        }
        
        // If empty list, return immediately
        if (ordersData.isEmpty) {
          return [];
        }
        
        final orders = <Order>[];
        for (var i = 0; i < ordersData.length; i++) {
          try {
            final orderJson = ordersData[i];
            if (orderJson is! Map<String, dynamic>) {
              continue;
            }
            final order = Order.fromJson(orderJson);
            orders.add(order);
          } catch (e) {
            // Continue parsing other orders instead of failing completely
            continue;
          }
        }
        return orders;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please sign in again.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get order details by ID
  Future<Order> getOrderDetails(int orderId) async {
    try {
      
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different response structures
        final orderData = data['data'] ?? data['order'] ?? data;
        
        return Order.fromJson(orderData);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please sign in again.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch order details');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update order status (if needed)
  Future<Order> updateOrderStatus(int orderId, OrderStatus status) async {
    try {
      
      final headers = await _getHeaders();
      final body = jsonEncode({
        'status': status.name,
      });
      
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orderData = data['data'] ?? data['order'] ?? data;
        return Order.fromJson(orderData);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please sign in again.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update order status');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(int orderId) async {
    try {
      
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );


      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please sign in again.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      rethrow;
    }
  }
}