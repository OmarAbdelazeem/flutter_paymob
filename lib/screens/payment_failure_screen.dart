import 'package:flutter/material.dart';

class PaymentFailureScreen extends StatelessWidget {
  final String? message;
  final String? merchantOrderId;

  const PaymentFailureScreen({
    super.key,
    this.message,
    this.merchantOrderId,
  });

  static Route<void> route({
    String? message,
    String? merchantOrderId,
  }) {
    return MaterialPageRoute(
      builder: (_) => PaymentFailureScreen(
        message: message,
        merchantOrderId: merchantOrderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Failed'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade600,
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'Your payment could not be completed.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (merchantOrderId != null && merchantOrderId!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Order: $merchantOrderId',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
