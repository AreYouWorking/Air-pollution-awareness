// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  group('[Widget_Test] [MainScreen]', () {
    testWidgets('should have application name', (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: const MainScreen(), theme: ThemeData.dark()));
      expect(find.text('AirWareness'), findsOneWidget);
    });

    testWidgets('should have Camera, Forecast button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: const MainScreen(), theme: ThemeData.dark()));
      expect(find.text('camera'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.text('forecast'), findsOneWidget);
      expect(find.byIcon(Icons.filter_drama), findsOneWidget);
    });

    testWidgets('forecast page must contains Today, Daily, Hourly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: const MainScreen(), theme: ThemeData.dark()));
      var forecastBtn = find.text('forecast');
      await tester.tap(forecastBtn);
      await tester.pump();
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Hourly'), findsOneWidget);
    });

    testWidgets('camera page must contains memory and camera button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: const MainScreen(), theme: ThemeData.dark()));
      var cameraBtn = find.text('camera');
      await tester.tap(cameraBtn);
      await tester.pump();
      expect(find.text('Memory'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsWidgets);
    });
  });
}
