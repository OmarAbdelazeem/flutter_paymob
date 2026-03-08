import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_paymob/main.dart';

void main() {
  testWidgets('App loads with checkout screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PaymobDemoApp());

    expect(find.text('Pay'), findsOneWidget);
    expect(find.text('Get Demo Order'), findsOneWidget);
  });
}
