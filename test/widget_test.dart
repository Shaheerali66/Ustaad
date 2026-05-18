import 'package:flutter_test/flutter_test.dart';
import 'package:khidmat_ai/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const KhidmatAiApp());
    expect(find.text('Khidmat AI'), findsOneWidget);
  });
}
