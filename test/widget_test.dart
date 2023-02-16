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
  group('[Widget_Test] [Page]', () {
    testWidgets('should have application name, location',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: const MainScreen(), theme: ThemeData.dark()));
      expect(find.text('AirWareness'), findsOneWidget);
      expect(find.byIcon(Icons.near_me_outlined), findsOneWidget);
    });

    testWidgets('should have Camera, Forecast button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: const MainScreen(), theme: ThemeData.dark()));
      expect(find.text('Camera'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.text('Forecast'), findsOneWidget);
      expect(find.byIcon(Icons.filter_drama), findsOneWidget);
    });

    testWidgets('forecast page must contains Today, Daily, Hourly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: const MainScreen(), theme: ThemeData.dark()));
      var forecastBtn = find.text('Forecast');
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
      var cameraBtn = find.text('Camera');
      await tester.tap(cameraBtn);
      await tester.pump();
      expect(find.text('- Memory -'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });
  });

  group('[Widget_Test] [MainScreen -> Camera]', () {
    testWidgets('can open built in camera and close',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: const MainScreen(), theme: ThemeData.dark()));
      var cameraBtn = find.text('Camera');
      await tester.tap(cameraBtn);
      await tester.pump();
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });
  });
}
