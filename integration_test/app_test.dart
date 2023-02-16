import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('[Integration_Test]', () {
    // testWidgets('tap on forecast, camera button 10 times', (tester) async {
    //   app.main();
    //   await tester.pumpAndSettle();
    //   // expect(find.text('Forecast'), findsOneWidget);
    //   final Finder cameraBtn = find.text('Camera');
    //   final Finder forecastBtn = find.byIcon(Icons.filter_drama);
    //   await tester.tap(forecastBtn);
    //   for (var i = 0; i < 10; i++) {
    //     await tester.tap(cameraBtn);
    //     await Future.delayed(const Duration(seconds: 1));
    //     await tester.tap(forecastBtn);
    //     await Future.delayed(const Duration(seconds: 1));
    //   }
    //   await tester.pumpAndSettle();
    // });

    // testWidgets('change location to another location', (tester) async {
    //   app.main();
    //   await tester.pumpAndSettle();
    //   expect(find.text('Forecast'), findsOneWidget);
    //   final Finder cameraBtn = find.text('Camera');
    //   final Finder forecastBtn = find.byIcon(Icons.filter_drama);
    //   // waiting for api fetched
    //   await Future.delayed(const Duration(seconds: 15));
    //   // expect(find.text('AQI'), findsWidgets);
    //   final Finder loc = find.text('Chiang Mai');
    //   expect(find.text('Chiang Mai'), findsWidgets);
    //   await Future.delayed(const Duration(seconds: 2));
    //   tester.tap(loc);
    //   await tester.pumpAndSettle();
    //   await Future.delayed(const Duration(seconds: 2));
    //   expect(find.text('เลือกตำแหน่งที่อยู่'), findsOneWidget);
    //   final Finder inputField = find.byType(TextField);
    //   tester.tap(inputField);
    //   await tester.enterText(inputField, 'doi suthep');
    //   final Finder searchBtn = find.byIcon(Icons.search);
    //   await Future.delayed(const Duration(seconds: 3));
    //   expect(find.text('Taxi station to Doi Suthep (Suthep)'), findsOneWidget);
    //   await Future.delayed(const Duration(seconds: 1));
    //   final Finder loc_text = find.text('Taxi station to Doi Suthep (Suthep)');
    //   tester.tap(loc_text);
    //   await tester.pumpAndSettle();
    // });
  });
}
