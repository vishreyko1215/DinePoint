import 'package:flutter_test/flutter_test.dart';
import 'package:dinepoint/main.dart';

void main() {
  testWidgets('DinePoint smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DinePoint());

    // Verify that the DinePoint title is displayed.
    expect(find.text('DinePoint'), findsOneWidget);
  });
}
