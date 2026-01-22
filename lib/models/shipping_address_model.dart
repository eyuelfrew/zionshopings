import 'dart:convert';

class ShippingAddress {
  final String fullName;
  final String phone;
  final String city;
  final String? subcity;
  final String address;

  ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.city,
    this.subcity,
    required this.address,
  });

  factory ShippingAddress.fromJson(dynamic json) {
    // Handle if json is a string (needs to be parsed)
    Map<String, dynamic> data;
    if (json is String) {
      try {
        data = jsonDecode(json);
      } catch (e) {
        // Return default address if parsing fails
        return ShippingAddress(
          fullName: '',
          phone: '',
          city: '',
          address: '',
        );
      }
    } else if (json is Map<String, dynamic>) {
      data = json;
    } else {
      // Return default address if json is neither string nor map
      return ShippingAddress(
        fullName: '',
        phone: '',
        city: '',
        address: '',
      );
    }

    return ShippingAddress(
      fullName: data['fullName'] ?? data['full_name'] ?? '',
      phone: data['phone'] ?? '',
      city: data['city'] ?? '',
      subcity: data['subcity'] ?? data['sub_city'],
      address: data['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'city': city,
      if (subcity != null && subcity!.isNotEmpty) 'subcity': subcity,
      'address': address,
    };
  }

  ShippingAddress copyWith({
    String? fullName,
    String? phone,
    String? city,
    String? subcity,
    String? address,
  }) {
    return ShippingAddress(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      subcity: subcity ?? this.subcity,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'ShippingAddress(fullName: $fullName, phone: $phone, city: $city, address: $address)';
  }

  String get formattedAddress {
    final parts = <String>[
      address,
      if (subcity != null && subcity!.isNotEmpty) subcity!,
      city,
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }
}