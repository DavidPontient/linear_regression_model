import 'package:flutter_test/flutter_test.dart';

import 'package:linearapp/main.dart';

void main() {
  testWidgets('Crop Yield Predictor UI loads correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CropApp());

    // Check app title exists
    expect(find.text('Crop Yield Predictor'), findsOneWidget);

    // Check input fields exist
    expect(find.text('Rainfall (mm)'), findsOneWidget);
    expect(find.text('Temperature (°C)'), findsOneWidget);
    expect(find.text('Fertilizer Used (0/1)'), findsOneWidget);
    expect(find.text('Irrigation Used (0/1)'), findsOneWidget);
    expect(find.text('Days to Harvest'), findsOneWidget);

    // Check button exists
    expect(find.text('Predict Yield'), findsOneWidget);
  });
}
