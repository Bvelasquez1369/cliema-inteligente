import 'package:flutter_test/flutter_test.dart';
import 'package:app_clima/main.dart';

void main() {
  testWidgets('Prueba básica', (WidgetTester tester) async {
    await tester.pumpWidget(const AplicacionClima());
  });
}