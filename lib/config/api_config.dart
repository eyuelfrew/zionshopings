

class ApiConfig {
  // Base URL for the backend API
  static const String baseUrl = 'http://localhost:5000';
  
  // API endpoints
  static const String apiPath = '/api';
  static const String authPath = '$apiPath/auth';
  static const String productsPath = '$apiPath/products';
  static const String categoriesPath = '$apiPath/categories';
  static const String ordersPath = '$apiPath/orders';
  static const String carouselsPath = '$apiPath/carousels';
  
  // Full API URLs
  static String get apiBaseUrl => '$baseUrl$apiPath';
  static String get authUrl => '$baseUrl$authPath';
  static String get productsUrl => '$baseUrl$productsPath';
  static String get categoriesUrl => '$baseUrl$categoriesPath';
  static String get ordersUrl => '$baseUrl$ordersPath';
  static String get carouselsUrl => '$baseUrl$carouselsPath';
  
  // Helper method to get full image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return '$baseUrl$imagePath';
  }
  
  // Helper method to check if running on physical device
  static bool get isPhysicalDevice {
    // This is a simple check - you might want to make this more sophisticated
    return !baseUrl.contains('localhost') && !baseUrl.contains('10.0.2.2');
  }
}
