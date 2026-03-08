import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String merchantOrderId;
  final int amountCents;
  final String currency;

  const PaymentSuccessScreen({
    super.key,
    required this.merchantOrderId,
    required this.amountCents,
    required this.currency,
  });

  static Route<void> route({
    required String merchantOrderId,
    required int amountCents,
    required String currency,
  }) {
    return MaterialPageRoute(
      builder: (_) => PaymentSuccessScreen(
        merchantOrderId: merchantOrderId,
        amountCents: amountCents,
        currency: currency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$amountCents $currency',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              if (merchantOrderId.isNotEmpty) ...[
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
