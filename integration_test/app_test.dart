import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('[Integration_Test]', () {
    testWidgets('tap on forecast, camera button 10 times', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('Forecast'), findsOneWidget);
      final Finder cameraBtn = find.text('Camera');
      final Finder forecastBtn = find.byIcon(Icons.filter_drama);
      await tester.tap(forecastBtn);
      for (var i = 0; i < 10; i++) {
        await tester.tap(cameraBtn);
        await Future.delayed(const Duration(seconds: 1));
        await tester.tap(forecastBtn);
        await Future.delayed(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();
    });
  });
}
