import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/main.dart';

void main() {
  testWidgets('Quote app initial state test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const QuoteApp());

    // Verify that the initial text is displayed
    expect(find.text('Your quote will appear here'), findsOneWidget);

    // Verify that the fetch button exists
    expect(find.text('Fetch Quote'), findsOneWidget);
  });
}