# Backend Data Format Fix

## ❌ **Problem**
After fixing the token authentication, orders were loading but crashing with:
```
Error fetching orders: type 'String' is not a subtype of type 'int' of 'index'
```

## 🔍 **Root Cause**
The backend returns data in a different format than the Flutter models expected:

### Backend Response Format:
```json
{
  "id": 2,
  "user_id": 1,
  "order_number": "ZS-20260118-002",
  "total_amount": "100.00",           // ❌ String, not number
  "status": "paid",
  "payment_method": "telebirr",
  "shipping_address": "{\"city\":\"Addis Ababa\",\"phone\":\"0911223344\"}",  // ❌ JSON string
  "items": [{
    "product_id": 6,                  // ❌ snake_case
    "product_name": "Test Product",
    "price": "50.00",                 // ❌ String, not number
    "subtotal": "100.00"              // ❌ String, not number
  }]
}
```

### Issues:
1. **Field naming**: Backend uses `snake_case` (e.g., `user_id`, `order_number`)
2. **Number types**: Prices are strings (`"100.00"`) instead of numbers
3. **Nested JSON**: `shipping_address` is a JSON string, not an object
4. **Missing fields**: Some fields like `fullName` and `address` missing from shipping address

## ✅ **Solution**

### 1. **OrderItem Model** - Handle both formats and parse strings to numbers
```dart
factory OrderItem.fromJson(Map<String, dynamic> json) {
  return OrderItem(
    id: json['id'],
    productId: json['productId'] ?? json['product_id'] ?? 0,  // ✅ Both formats
    productName: json['productName'] ?? json['product_name'] ?? '',
    price: _parseDouble(json['price']),  // ✅ Parse string to double
    quantity: json['quantity'] ?? 1,
    subtotal: _parseDouble(json['subtotal']),
    productImage: json['productImage'] ?? json['product_image'],
  );
}

static double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;  // ✅ Parse string
  return 0.0;
}
```

### 2. **ShippingAddress Model** - Parse JSON string
```dart
factory ShippingAddress.fromJson(dynamic json) {
  // Handle if json is a string (needs to be parsed)
  Map<String, dynamic> data;
  if (json is String) {
    try {
      data = jsonDecode(json);  // ✅ Parse JSON string
    } catch (e) {
      print('Error parsing shipping address JSON string: $e');
      return ShippingAddress(/* default values */);
    }
  } else if (json is Map<String, dynamic>) {
    data = json;
  } else {
    return ShippingAddress(/* default values */);
  }

  return ShippingAddress(
    fullName: data['fullName'] ?? data['full_name'] ?? '',  // ✅ Both formats
    phone: data['phone'] ?? '',
    city: data['city'] ?? '',
    subcity: data['subcity'] ?? data['sub_city'],
    address: data['address'] ?? '',
  );
}
```

### 3. **Order Model** - Handle all backend formats
```dart
factory Order.fromJson(Map<String, dynamic> json) {
  return Order(
    id: json['id'],
    orderNumber: json['orderNumber'] ?? json['order_number'],  // ✅ Both formats
    items: (json['items'] as List<dynamic>? ?? [])
        .map((item) => OrderItem.fromJson(item))
        .toList(),
    totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']),  // ✅ Parse
    paymentMethod: PaymentMethod.fromString(
      json['paymentMethod'] ?? json['payment_method'] ?? 'telebirr',
    ),
    shippingAddress: ShippingAddress.fromJson(
      json['shippingAddress'] ?? json['shipping_address'] ?? {},  // ✅ Handles string
    ),
    status: OrderStatus.fromString(json['status'] ?? 'pending'),
    transactionId: json['transactionId'] ?? json['transaction_id'],
    paymentVerified: json['paymentVerified'] ?? json['payment_verified'],
    paymentVerifiedAt: _parseDateTime(json['paymentVerifiedAt'] ?? json['payment_verified_at']),
    createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
    updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
  );
}
```

### 4. **Added New Order Status**
```dart
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
  paid,  // ✅ Added for backend compatibility
}
```

### 5. **Added Display Helper**
```dart
String get displayOrderNumber => 
  orderNumber ?? (id != null ? 'ORD${id.toString().padLeft(6, '0')}' : 'PENDING');
```

## 🔧 **Key Features**

### Flexible Parsing:
- ✅ Handles both `camelCase` and `snake_case` field names
- ✅ Converts string numbers to doubles
- ✅ Parses JSON strings to objects
- ✅ Provides default values for missing fields
- ✅ Graceful error handling

### Type Safety:
```dart
static double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

static DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      print('Error parsing datetime: $e');
      return null;
    }
  }
  return null;
}
```

## 📊 **Backend Response Handling**

### Example Backend Response:
```json
[
  {
    "id": 2,
    "order_number": "ZS-20260118-002",
    "total_amount": "100.00",
    "status": "paid",
    "payment_method": "telebirr",
    "transaction_id": "TEST-TRANS-12345",
    "payment_verified": true,
    "shipping_address": "{\"city\":\"Addis Ababa\",\"phone\":\"0911223344\"}",
    "items": [
      {
        "product_id": 6,
        "product_name": "Test Product",
        "price": "50.00",
        "quantity": 2,
        "subtotal": "100.00"
      }
    ]
  }
]
```

### Parsed to Flutter Models:
```dart
Order(
  id: 2,
  orderNumber: "ZS-20260118-002",
  totalAmount: 100.0,                    // ✅ Converted to double
  status: OrderStatus.paid,
  paymentMethod: PaymentMethod.telebirr,
  transactionId: "TEST-TRANS-12345",
  paymentVerified: true,
  shippingAddress: ShippingAddress(      // ✅ Parsed from JSON string
    city: "Addis Ababa",
    phone: "0911223344",
    fullName: "",                        // ✅ Default value
    address: "",                         // ✅ Default value
  ),
  items: [
    OrderItem(
      productId: 6,
      productName: "Test Product",
      price: 50.0,                       // ✅ Converted to double
      quantity: 2,
      subtotal: 100.0,                   // ✅ Converted to double
    )
  ]
)
```

## 🎯 **Files Updated**

1. ✅ `lib/models/order_item_model.dart` - Added flexible parsing
2. ✅ `lib/models/shipping_address_model.dart` - Handle JSON strings
3. ✅ `lib/models/order_model.dart` - Support both formats
4. ✅ `lib/screens/order_history_screen.dart` - Use displayOrderNumber
5. ✅ `lib/screens/order_details_screen.dart` - Use displayOrderNumber
6. ✅ `lib/screens/order_success_screen.dart` - Use displayOrderNumber
7. ✅ `lib/screens/transaction_verification_screen.dart` - Use displayOrderNumber

## ✅ **Result**

Orders now load and display correctly:
- ✅ Order list shows all orders
- ✅ Order details display properly
- ✅ Prices formatted correctly
- ✅ Shipping addresses parsed
- ✅ Status indicators work
- ✅ No type conversion errors

## 🧪 **Testing**

### Verified Scenarios:
1. ✅ Loading order list from backend
2. ✅ Displaying order details
3. ✅ Parsing string prices to numbers
4. ✅ Parsing JSON string shipping addresses
5. ✅ Handling missing fields gracefully
6. ✅ Supporting both camelCase and snake_case

### Edge Cases Handled:
- ✅ Null values
- ✅ Missing fields
- ✅ Invalid JSON strings
- ✅ Invalid number formats
- ✅ Invalid date formats
- ✅ Empty arrays

## 📝 **Best Practices Applied**

1. **Defensive Parsing**: Always check types before conversion
2. **Default Values**: Provide sensible defaults for missing data
3. **Error Handling**: Catch and log parsing errors
4. **Flexibility**: Support multiple field name formats
5. **Type Safety**: Use helper methods for type conversion
6. **Null Safety**: Handle null values gracefully

## 🎉 **Success**

The order system now works seamlessly with the backend's data format!
