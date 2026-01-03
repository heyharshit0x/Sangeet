// Basic smoke test for Sangeet Music App

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sangeet/main.dart';

void main() {
  testWidgets('Sangeet app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app launches without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
