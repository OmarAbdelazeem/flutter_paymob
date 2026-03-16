import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/api_config.dart';
import '../models/session_request.dart';
import '../models/session_response.dart';
import '../services/payment_api_service.dart';
import '../services/paymob_sdk_service.dart';
import '../services/saved_cards_api_service.dart';
import 'payment_failure_screen.dart';
import 'payment_success_screen.dart';
import 'my_cards_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.selectedCardId});

  final String? selectedCardId;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = PaymentApiService();
  final _cardsApi = SavedCardsApiService();
  final _paymob = PaymobSdkService();

  final _merchantOrderIdController = TextEditingController();
  final _amountController = TextEditingController(text: '10000');
  final _emailController = TextEditingController(text: 'test@example.com');
  final _firstNameController = TextEditingController(text: 'John');
  final _lastNameController = TextEditingController(text: 'Doe');
  final _phoneController = TextEditingController(text: '+201012345678');

  bool _isLoading = false;
  String? _loadingMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _merchantOrderIdController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _getDemoOrder() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Getting demo order...';
      _errorMessage = null;
    });

    try {
      final merchantOrderId = await _api.getDemoOrderId();
      if (!mounted) return;
      _merchantOrderIdController.text = merchantOrderId;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to get demo order: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
        });
      }
    }
  }

  Future<void> _handlePay() async {
    if (!_formKey.currentState!.validate()) return;

    final merchantOrderId = _merchantOrderIdController.text.trim();
    if (merchantOrderId.isEmpty) {
      setState(() => _errorMessage = 'Please enter or fetch a merchant order ID');
      return;
    }

    final amountCents = int.tryParse(_amountController.text.trim());
    if (amountCents == null || amountCents <= 0) {
      setState(() => _errorMessage = 'Please enter a valid amount in cents');
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Creating payment session...';
      _errorMessage = null;
    });

    final selectedCardId = widget.selectedCardId;

    SessionResponse? session;
    try {
      session = await _api.createPaymobSession(
        SessionRequest(
          merchantOrderId: merchantOrderId,
          amountCents: amountCents,
          currency: 'EGP',
          customer: SessionCustomer(
            id: merchantOrderId,
            email: _emailController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim(),
          ),
          billing: SessionBilling(),
          savedCardUuid: selectedCardId,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
        _errorMessage = 'Session failed: $e';
      });
      return;
    }

    if (!mounted) return;

    final publicKey = session.effectivePublicKey(ApiConfig.paymobPublicKey);
    if (publicKey.isEmpty) {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
        _errorMessage = 'Paymob public key not configured. Set PAYMOB_PUBLIC_KEY or have backend return public_key.';
      });
      return;
    }

    setState(() => _loadingMessage = 'Opening payment...');
    debugPrint('[Paymob] Opening SDK with clientSecret (length=${session.effectiveClientSecret.length})');

    PaymobSdkResult? sdkResult;
    try {
      sdkResult = await _paymob.payWithPaymob(
        publicKey: publicKey,
        clientSecret: session.effectiveClientSecret,
        appName: 'Flutter Paymob',
        buttonBackgroundColor: Theme.of(context).colorScheme.primary,
        buttonTextColor: Colors.white,
        saveCardDefault: false,
        showSaveCard: selectedCardId == null,
      );
      debugPrint('[Paymob] SDK returned: status=${sdkResult.status}, token=${sdkResult.token != null}, maskedPan=${sdkResult.maskedPan != null}');
      if (sdkResult.isSuccess && sdkResult.token != null && sdkResult.maskedPan != null) {
        try {
          await _cardsApi.saveCard(
            paymobToken: sdkResult.token!,
            maskedPan: sdkResult.maskedPan!,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card saved')),
            );
          }
        } catch (e) {
          debugPrint('[Paymob] Save card failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Card could not be saved: $e')),
            );
          }
        }
      }
    } on PlatformException catch (e) {
      debugPrint('[Paymob] SDK PlatformException: code=${e.code}, message=${e.message}, details=${e.details}');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      await _pollAndNavigate(
        merchantOrderId: merchantOrderId,
        amountCents: amountCents,
        currency: 'EGP',
        sdkErrorMessage: e.message ?? e.code,
      );
      return;
    } catch (e, stack) {
      debugPrint('[Paymob] SDK threw: $e');
      debugPrint('[Paymob] Stack: $stack');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
        _errorMessage = 'Payment SDK error: $e';
      });
      return;
    }

    if (!mounted) return;
    setState(() => _loadingMessage = 'Checking payment status...');
    debugPrint('[Paymob] Success path: starting poll for merchant_order_id=$merchantOrderId');

    await _pollAndNavigate(
      merchantOrderId: merchantOrderId,
      amountCents: amountCents,
      currency: 'EGP',
      sdkResult: sdkResult,
    );
  }

  Future<void> _pollAndNavigate({
    required String merchantOrderId,
    required int amountCents,
    required String currency,
    PaymobSdkResult? sdkResult,
    String? sdkErrorMessage,
  }) async {
    const pollInterval = Duration(seconds: 2);
    const maxAttempts = 30;
    debugPrint('[Paymob] _pollAndNavigate: sdkResult=${sdkResult?.status}, sdkErrorMessage=$sdkErrorMessage');

    for (var i = 0; i < maxAttempts; i++) {
      if (!mounted) return;
      setState(() => _loadingMessage = 'Checking payment status...');

      try {
        final status = await _api.getPaymentStatus(merchantOrderId);
        debugPrint('[Paymob] Poll #${i + 1}: status=${status.status}');

        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
        });

        if (status.isPaid) {
          debugPrint('[Paymob] Status PAID -> navigating to success');
          Navigator.of(context).pushReplacement(
            PaymentSuccessScreen.route(
              merchantOrderId: merchantOrderId,
              amountCents: status.amountCents,
              currency: status.currency,
            ),
          );
          return;
        }

        if (status.isFailed) {
          debugPrint('[Paymob] Status FAILED -> navigating to failure');
          Navigator.of(context).pushReplacement(
            PaymentFailureScreen.route(
              message: sdkErrorMessage ?? 'Payment was declined or failed.',
              merchantOrderId: merchantOrderId,
            ),
          );
          return;
        }
      } catch (e) {
        debugPrint('[Paymob] Poll #${i + 1} error: $e');
        // Continue polling on network errors
      }

      await Future<void>.delayed(pollInterval);
    }

    debugPrint('[Paymob] Poll ended after $maxAttempts attempts. successFromSdk=${sdkResult?.isSuccess}');
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });

    final successFromSdk = sdkResult?.isSuccess ?? false;
    if (successFromSdk) {
      debugPrint('[Paymob] Navigating to success (from SDK result)');
      Navigator.of(context).pushReplacement(
        PaymentSuccessScreen.route(
          merchantOrderId: merchantOrderId,
          amountCents: amountCents,
          currency: currency,
        ),
      );
    } else {
      debugPrint('[Paymob] Navigating to failure (timeout or no success from SDK)');
      Navigator.of(context).pushReplacement(
        PaymentFailureScreen.route(
          message: sdkErrorMessage ?? 'Payment status could not be confirmed. Please check your order.',
          merchantOrderId: merchantOrderId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const MyCardsScreen(),
              ),
            ),
            tooltip: 'My Cards',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: _merchantOrderIdController,
                    decoration: const InputDecoration(
                      labelText: 'Merchant Order ID',
                      hintText: 'Or use "Get Demo Order" below',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _getDemoOrder,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Get Demo Order'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (cents)',
                      hintText: 'e.g. 10000 for 100 EGP',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test card (Paymob)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Card 1: 5123 4567 8901 2346 • 12/25 • CVV 123',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          Text(
                            'Card 2: 2223 0000 0000 0007 • 01/39 • CVV 100 • Name: Test Family',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          Text(
                            'Expiry = MM/YY (e.g. 01/39 = Jan 2039). Card field is 16 digits max.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isLoading ? null : _handlePay,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Pay'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(_loadingMessage ?? 'Loading...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
