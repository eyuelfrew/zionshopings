// import 'package:flutter/material.dart';
// import 'dart:async';
// import '../models/order_model.dart';
// import '../services/order_service.dart';
// import '../theme/app_theme.dart';
// import 'order_success_screen.dart';
// import 'order_details_screen.dart';

// class TransactionVerificationScreen extends StatefulWidget {
//   final Order order;

//   const TransactionVerificationScreen({
//     super.key,
//     required this.order,
//   });

//   @override
//   State<TransactionVerificationScreen> createState() => _TransactionVerificationScreenState();
// }

// class _TransactionVerificationScreenState extends State<TransactionVerificationScreen> {
//   final _orderService = OrderService();
//   bool _isVerifying = false;
//   bool _verificationComplete = false;
//   bool _verificationSuccess = false;
//   String _verificationMessage = '';
//   Timer? _verificationTimer;
//   int _verificationAttempts = 0;
//   static const int _maxVerificationAttempts = 10;

//   @override
//   void initState() {
//     super.initState();
//     _startVerificationProcess();
//   }

//   @override
//   void dispose() {
//     _verificationTimer?.cancel();
//     super.dispose();
//   }

//   void _startVerificationProcess() {
//     setState(() {
//       _isVerifying = true;
//       _verificationComplete = false;
//     });

//     // Start periodic verification checks
//     _verificationTimer = Timer.periodic(
//       const Duration(seconds: 5),
//       (timer) => _checkTransactionStatus(),
//     );

//     // Also check immediately
//     _checkTransactionStatus();
//   }

//   Future<void> _checkTransactionStatus() async {
//     if (_verificationAttempts >= _maxVerificationAttempts) {
//       _stopVerification(false, 'Verification timeout. Please contact support.');
//       return;
//     }

//     _verificationAttempts++;

//     try {
//       final result = await _orderService.checkTelebirrTransaction(
//         transactionId: widget.order.transactionId!,
//         orderId: widget.order.id!,
//         orderAmount: widget.order.totalAmount,
//       );

//       if (result['success'] == true) {
//         _stopVerification(true, result['message'] ?? 'Payment verified successfully!');
//       } else if (_verificationAttempts >= _maxVerificationAttempts) {
//         _stopVerification(false, result['message'] ?? 'Payment verification failed');
//       }
//     } catch (e) {
//       if (_verificationAttempts >= _maxVerificationAttempts) {
//         _stopVerification(false, 'Error verifying payment: $e');
//       }
//     }
//   }

//   void _stopVerification(bool success, String message) {
//     _verificationTimer?.cancel();
    
//     if (mounted) {
//       setState(() {
//         _isVerifying = false;
//         _verificationComplete = true;
//         _verificationSuccess = success;
//         _verificationMessage = message;
//       });

//       if (success) {
//         // Auto-navigate to success screen after a short delay
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => OrderSuccessScreen(order: widget.order),
//               ),
//             );
//           }
//         });
//       }
//     }
//   }

//   Future<void> _retryVerification() async {
//     setState(() {
//       _verificationAttempts = 0;
//     });
//     _startVerificationProcess();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment Verification'),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         foregroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Status Icon
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       color: _verificationComplete
//                           ? (_verificationSuccess ? Colors.green : Colors.red)
//                           : AppTheme.primaryColor,
//                       shape: BoxShape.circle,
//                     ),
//                     child: _isVerifying
//                         ? const Padding(
//                             padding: EdgeInsets.all(30),
//                             child: CircularProgressIndicator(
//                               strokeWidth: 4,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : Icon(
//                             _verificationSuccess ? Icons.check : Icons.error_outline,
//                             color: Colors.white,
//                             size: 60,
//                           ),
//                   ),
//                   const SizedBox(height: 32),

//                   // Status Message
//                   Text(
//                     _isVerifying
//                         ? 'Verifying Payment...'
//                         : _verificationSuccess
//                             ? 'Payment Verified!'
//                             : 'Verification Failed',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: _verificationComplete
//                           ? (_verificationSuccess ? Colors.green : Colors.red)
//                           : AppTheme.primaryColor,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),

//                   // Description
//                   Text(
//                     _isVerifying
//                         ? 'Please wait while we verify your Telebirr payment. This may take a few moments.'
//                         : _verificationMessage,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey.shade700,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 24),

//                   // Order Details Card
//                   Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           _buildDetailRow('Order Number', widget.order.displayOrderNumber),
//                           const SizedBox(height: 8),
//                           _buildDetailRow(
//                             'Total Amount',
//                             '\$${widget.order.totalAmount.toStringAsFixed(2)}',
//                           ),
//                           const SizedBox(height: 8),
//                           _buildDetailRow('Payment Method', 'Telebirr'),
//                           const SizedBox(height: 8),
//                           _buildDetailRow(
//                             'Transaction ID',
//                             widget.order.transactionId ?? 'N/A',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   if (_isVerifying) ...[
//                     const SizedBox(height: 24),
//                     Text(
//                       'Attempt ${_verificationAttempts} of $_maxVerificationAttempts',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),

//             // Action Buttons
//             if (_verificationComplete) ...[
//               if (_verificationSuccess) ...[
//                 SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => OrderSuccessScreen(order: widget.order),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'Continue',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ] else ...[
//                 SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: _retryVerification,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryColor,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'Retry Verification',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => OrderDetailsScreen(
//                             orderId: widget.order.id!,
//                           ),
//                         ),
//                       );
//                     },
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppTheme.primaryColor,
//                       side: const BorderSide(color: AppTheme.primaryColor),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'View Order Details',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ] else ...[
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     _verificationTimer?.cancel();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => OrderDetailsScreen(
//                           orderId: widget.order.id!,
//                         ),
//                       ),
//                     );
//                   },
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: AppTheme.primaryColor,
//                     side: const BorderSide(color: AppTheme.primaryColor),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'View Order Details',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }