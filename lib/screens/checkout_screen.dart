import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/shipping_address_model.dart';
import '../models/address_model.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/address_controller.dart';
import '../theme/app_theme.dart';
import 'order_success_screen.dart';
import 'add_address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<OrderItem>? items;
  final double? totalAmount;

  const CheckoutScreen({
    super.key,
    this.items,
    this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cartService = CartService();
  final _orderService = OrderService();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _subcityController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  // State variables
  List<OrderItem> _cartItems = [];
  double _totalAmount = 0.0;
  bool _isLoading = false;
  
  // Address selection
  Address? _selectedAddress;
  bool _useNewAddress = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final addressController = Provider.of<AddressController>(context, listen: false);
    
    // Ensure addresses are loaded from storage
    await addressController.loadAddresses();
    
    if (addressController.addresses.isNotEmpty) {
      setState(() {
        _selectedAddress = addressController.defaultAddress;
        _useNewAddress = false;
      });
    } else {
      setState(() {
        _useNewAddress = true;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _subcityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCartItems() async {
    try {
      if (widget.items != null && widget.totalAmount != null) {
        // Use provided items (e.g., from product detail page)
        setState(() {
          _cartItems = widget.items!;
          _totalAmount = widget.totalAmount!;
        });
      } else {
        // Load from cart
        final items = await _cartService.getCartItems();
        final total = await _cartService.getCartTotal();
        setState(() {
          _cartItems = items;
          _totalAmount = total;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading cart items: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }


  Future<void> _placeOrder() async {
    
    // Validate form only if using new address
    if (_useNewAddress && !_formKey.currentState!.validate()) {
      return;
    }

    // Check if address is selected
    if (!_useNewAddress && _selectedAddress == null) {
      _showErrorSnackBar('Please select a delivery address');
      return;
    }

    if (_cartItems.isEmpty) {
      _showErrorSnackBar('Your cart is empty');
      return;
    }


    setState(() {
      _isLoading = true;
    });

    try {
      // Create shipping address from selected or new address
      final ShippingAddress shippingAddress;
      
      if (_useNewAddress) {
        // Use form data
        shippingAddress = ShippingAddress(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          city: _cityController.text.trim(),
          subcity: _subcityController.text.trim().isNotEmpty
              ? _subcityController.text.trim()
              : null,
          address: _addressController.text.trim(),
        );
      } else {
        // Convert saved Address to ShippingAddress
        shippingAddress = ShippingAddress(
          fullName: _selectedAddress!.receiverName,
          phone: _selectedAddress!.phoneNumber,
          city: _selectedAddress!.city,
          subcity: _selectedAddress!.state.isNotEmpty ? _selectedAddress!.state : null,
          address: _selectedAddress!.street,
        );
      }


      // Create order without payment method (will be selected later)
      final order = Order(
        items: _cartItems,
        totalAmount: _totalAmount,
        shippingAddress: shippingAddress,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );


      // Submit order to backend
      final createdOrder = await _orderService.createOrder(order);


      // Clear cart if using cart items
      if (widget.items == null) {
        await _cartService.clearCart();
      }

      // Navigate to success screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(
              order: createdOrder,
            ),
          ),
        );
      }
    } catch (e) {

      _showErrorSnackBar('Failed to place order: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: _cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Order Summary
                  _buildOrderSummary(),
                  const SizedBox(height: 24),

                  // Shipping Address
                  _buildShippingAddressSection(),
                  const SizedBox(height: 24),

                  // Notes
                  _buildNotesSection(),
                  const SizedBox(height: 32),

                  // Place Order Button
                  _buildPlaceOrderButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._cartItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} x${item.quantity}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressSection() {
    return Consumer<AddressController>(
      builder: (context, addressController, child) {
        final hasAddresses = addressController.addresses.isNotEmpty;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasAddresses)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _useNewAddress = !_useNewAddress;
                          });
                        },
                        icon: Icon(_useNewAddress ? Icons.list : Icons.add),
                        label: Text(_useNewAddress ? 'Select Saved' : 'Add New'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Show saved addresses selector if user has addresses and not adding new
                if (hasAddresses && !_useNewAddress) ...[
                  ...addressController.addresses.map((address) => 
                    _buildAddressCard(address, addressController)
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAddressScreen(),
                        ),
                      );
                      _loadDefaultAddress();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ],
                
                // Show address form only if no addresses exist OR user clicked "Add New"
                if (!hasAddresses || _useNewAddress) ...[
                  _buildAddressForm(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressCard(Address address, AddressController controller) {
    final isSelected = _selectedAddress?.id == address.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddress = address;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.receiverName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    address.phoneNumber,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address.street}, ${address.city}${address.state.isNotEmpty ? ', ${address.state}' : ''}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_useNewAddress && (value == null || value.trim().isEmpty)) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            border: OutlineInputBorder(),
            prefixText: '+251 ',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          validator: (value) {
            if (_useNewAddress) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.trim().length != 9) {
                return 'Please enter a valid phone number';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_useNewAddress && (value == null || value.trim().isEmpty)) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _subcityController,
                decoration: const InputDecoration(
                  labelText: 'Subcity',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Address *',
            border: OutlineInputBorder(),
            hintText: 'Street, building, apartment number',
          ),
          maxLines: 2,
          validator: (value) {
            if (_useNewAddress && (value == null || value.trim().isEmpty)) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Notes (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Special instructions',
                border: OutlineInputBorder(),
                hintText: 'Any special delivery instructions...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Placing Order...'),
                ],
              )
            : Text(
                'Place Order - \$${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
