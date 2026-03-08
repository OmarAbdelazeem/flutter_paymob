import 'package:flutter/material.dart';

import 'screens/checkout_screen.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserService.ensureInitialized();
  runApp(const PaymobDemoApp());
}

class PaymobDemoApp extends StatelessWidget {
  const PaymobDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paymob Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CheckoutScreen(),
    );
  }
}
