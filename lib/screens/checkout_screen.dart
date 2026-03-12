import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paymob_flutter_lib/models/payment.dart';
import 'package:paymob_flutter_lib/models/payment_result.dart';
import 'package:paymob_flutter_lib/paymob_flutter_lib.dart';

import '../models/saved_card.dart';
import '../models/session_request.dart';
import '../models/session_response.dart';
import '../services/payment_api_service.dart';
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
  final _paymob = PaymobFlutterLib();

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
    final selectedCardId = widget.selectedCardId;

    if (selectedCardId != null) {
      await _payWithSavedCard(
        session: session,
        merchantOrderId: merchantOrderId,
        amountCents: amountCents,
        selectedCardId: selectedCardId,
      );
      return;
    }

    setState(() => _loadingMessage = 'Opening payment...');

    debugPrint('[Paymob] Opening Paymob SDK with payment_key (length=${session.paymentKey.length})');
    PaymentResult? sdkResult;
    try {
      sdkResult = await _paymob.startPayActivityNoToken(
        Payment(
          paymentKey: session.paymentKey,
          saveCardDefault: false,
          showSaveCard: true,
          themeColor: Theme.of(context).colorScheme.primary,
          language: 'en',
          actionbar: true,
        ),
      );
      debugPrint('[Paymob] SDK returned success: dataMessage=${sdkResult?.dataMessage}, token=${sdkResult?.token != null}, maskedPan=${sdkResult?.maskedPan != null}');
      // Save card when user chose to save and we have token + maskedPan (plugin may send dataMessage or not)
      final shouldSaveCard = (sdkResult?.dataMessage == 'TRANSACTION_SUCCESSFUL_CARD_SAVED' ||
              (sdkResult?.token != null && sdkResult?.maskedPan != null)) &&
          sdkResult?.token != null &&
          sdkResult?.maskedPan != null;
      if (shouldSaveCard) {
        try {
          await _cardsApi.saveCard(
            paymobToken: sdkResult!.token!,
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
      // User cancelled or SDK error - show message and poll to confirm final status
      final errorMessage = e.message ?? e.code;
      await _pollAndNavigate(
        merchantOrderId: merchantOrderId,
        amountCents: amountCents,
        currency: 'EGP',
        sdkErrorMessage: errorMessage,
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
    debugPrint('[Paymob] NoToken success path: starting poll for merchant_order_id=$merchantOrderId');

    await _pollAndNavigate(
      merchantOrderId: merchantOrderId,
      amountCents: amountCents,
      currency: 'EGP',
      sdkResult: sdkResult,
    );
  }

  Future<void> _payWithSavedCard({
    required SessionResponse session,
    required String merchantOrderId,
    required int amountCents,
    required String selectedCardId,
  }) async {
    if (!mounted) return;
    setState(() => _loadingMessage = 'Getting card details...');

    CardDetailsForPayment? cardDetails;
    try {
      cardDetails = await _cardsApi.getCardDetails(selectedCardId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
        _errorMessage = 'Failed to load card: $e';
      });
      return;
    }

    if (!mounted) return;
    setState(() => _loadingMessage = 'Opening payment...');

    final customer = Customer(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      apartment: 'NA',
      floor: 'NA',
      building: 'NA',
      city: 'Cairo',
      state: 'Cairo',
      country: 'EG',
      postalCode: '00000',
    );

    PaymentResult? sdkResult;
    try {
      final resultStr = await _paymob.startPayActivityToken(
        Payment(
          paymentKey: session.paymentKey,
          token: cardDetails.paymobToken,
          maskedPanNumber: cardDetails.maskedPan,
          customer: customer,
          saveCardDefault: false,
          showSaveCard: false,
          themeColor: Theme.of(context).colorScheme.primary,
          language: 'en',
          actionbar: true,
        ),
      );
      if (resultStr != null && resultStr.isNotEmpty) {
        try {
          sdkResult = PaymentResult.fromJson(
            jsonDecode(resultStr) as Map<String, dynamic>,
          );
        } catch (_) {}
      }
    } on PlatformException catch (e) {
      debugPrint('[Paymob] Token flow PlatformException: code=${e.code}, message=${e.message}, details=${e.details}');
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
    } catch (e) {
      debugPrint('[Paymob] Token flow error: $e');
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
    debugPrint('[Paymob] Token success path: starting poll for merchant_order_id=$merchantOrderId');
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
    PaymentResult? sdkResult,
    String? sdkErrorMessage,
  }) async {
    const pollInterval = Duration(seconds: 2);
    const maxAttempts = 30;
    debugPrint('[Paymob] _pollAndNavigate: sdkResult=${sdkResult?.dataMessage}, sdkErrorMessage=$sdkErrorMessage');

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

    debugPrint('[Paymob] Poll ended after $maxAttempts attempts. successFromSdk=${sdkResult?.dataMessage == "TRANSACTION_SUCCESSFUL"}');
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });

    final successFromSdk = sdkResult?.dataMessage == 'TRANSACTION_SUCCESSFUL';
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
