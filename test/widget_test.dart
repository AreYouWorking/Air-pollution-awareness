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
  testWidgets('[MainScreen] widgets test', (WidgetTester tester) async {
    await tester.pumpWidget(
        MaterialApp(home: const MainScreen(), theme: ThemeData.dark()));
    // must have application name on main page
    expect(find.text('AirWareness'), findsOneWidget);
    // main page must contains 2 button for switch between camera and forecast
    var forecastBtn = find.text('forecast');
    var cameraBtn = find.text('camera');
    expect(forecastBtn, findsOneWidget);
    expect(cameraBtn, findsOneWidget);
    // in forecast page must contains 3 section (Today, Daily, Hourly)
    await tester.tap(forecastBtn);
    await tester.pump();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Hourly'), findsOneWidget);
    // in camera page must contains memory
    await tester.tap(cameraBtn);
    await tester.pump();
    expect(find.text('Memory'), findsOneWidget);
  });
}
