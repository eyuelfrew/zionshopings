import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../theme/app_theme.dart';
import 'order_details_screen.dart';

class PaymentVerificationScreen extends StatefulWidget {
  final Order order;

  const PaymentVerificationScreen({
    super.key,
    required this.order,
  });

  @override
  State<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();
  final _orderService = OrderService();
  bool _isVerifying = false;
  String? _selectedPaymentMethod; // 'telebirr', 'cbebirr', 'cbebank'

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  Map<String, String> _getPaymentInstructions() {
    switch (_selectedPaymentMethod) {
      case 'telebirr':
        return {
          'title': 'Telebirr Payment',
          'step1': 'Open your Telebirr app',
          'step2': 'Send \$${widget.order.totalAmount.toStringAsFixed(2)} to: 0911123456',
          'step3': 'Copy the Transaction ID from Telebirr',
          'step4': 'Paste the Transaction ID below and verify',
        };
      case 'cbebirr':
        return {
          'title': 'CBE Birr Payment',
          'step1': 'Open your CBE Birr app',
          'step2': 'Send \$${widget.order.totalAmount.toStringAsFixed(2)} to: 0911123456',
          'step3': 'Copy the Transaction ID from CBE Birr',
          'step4': 'Paste the Transaction ID below and verify',
        };
      case 'cbebank':
        return {
          'title': 'CBE Transaction',
          'step1': 'Open your CBE Mobile Banking app',
          'step2': 'Transfer \$${widget.order.totalAmount.toStringAsFixed(2)} to Account: 1000123456789',
          'step3': 'Copy the Transaction Reference Number',
          'step4': 'Paste the Transaction ID below and verify',
        };
      default:
        return {};
    }
  }

  Future<void> _verifyPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // Send payment method name along with transaction verification
      final result = await _orderService.checkTelebirrTransaction(
        transactionId: _transactionIdController.text.trim(),
        orderId: widget.order.id!,
        orderAmount: widget.order.totalAmount,
        paymentMethod: _selectedPaymentMethod!,
      );

      if (mounted) {
        if (result['success'] == true) {
          // Show success dialog
          _showSuccessDialog();
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Payment verification failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Verified!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your payment has been successfully verified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(orderId: widget.order.id!),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Order Details', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Payment'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Information',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.receipt_long_outlined,
                        'Order Number',
                        widget.order.displayOrderNumber,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.payments_outlined,
                        'Total Amount',
                        '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Selection
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              // Payment Method Cards
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethodCard(
                      'telebirr',
                      'Telebirr',
                      'assets/telebirr.jpg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentMethodCard(
                      'cbebirr',
                      'CBE Birr',
                      'assets/cbebirr.webp',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentMethodCard(
                      'cbebank',
                      'CBE Transaction',
                      'assets/cbe.jpg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Instructions Card (only show if payment method is selected)
              if (_selectedPaymentMethod != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getPaymentInstructions()['title'] ?? 'Payment Instructions',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionStep('1', _getPaymentInstructions()['step1'] ?? ''),
                      const SizedBox(height: 12),
                      _buildInstructionStep('2', _getPaymentInstructions()['step2'] ?? ''),
                      const SizedBox(height: 12),
                      _buildInstructionStep('3', _getPaymentInstructions()['step3'] ?? ''),
                      const SizedBox(height: 12),
                      _buildInstructionStep('4', _getPaymentInstructions()['step4'] ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Transaction ID Input
                const Text(
                  'Transaction ID',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _transactionIdController,
                  decoration: InputDecoration(
                    labelText: 'Enter Transaction ID *',
                    hintText: 'e.g., HKJ123456789',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.receipt, size: 20),
                  ),
                  style: const TextStyle(fontSize: 14),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the transaction ID';
                    }
                    if (value.trim().length < 5) {
                      return 'Transaction ID seems too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isVerifying
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Verifying...', style: TextStyle(fontSize: 14)),
                            ],
                          )
                        : const Text(
                            'Verify Payment',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),

              // Pay Later Button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Pay Later',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(String method, String name, String imagePath) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
          _transactionIdController.clear();
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.payment,
                    size: 30,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
