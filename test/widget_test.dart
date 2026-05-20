import 'package:flutter_test/flutter_test.dart';
import 'package:ustaad/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const USTAADAiApp());
    expect(find.text('USTAAD'), findsOneWidget);
  });
}
