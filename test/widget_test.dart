// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:robot_arm_control/main.dart';

void main() {
  testWidgets('Robot Arm Control app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is present
    expect(find.text('Robot Arm Control Panel'), findsOneWidget);

    // Verify that motor sliders are present
    expect(find.text('Motor 1: 0'), findsOneWidget);
    expect(find.text('Motor 2: 0'), findsOneWidget);
    expect(find.text('Motor 3: 0'), findsOneWidget);
    expect(find.text('Motor 4: 0'), findsOneWidget);

    // Verify that control buttons are present
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Save Pose'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);

    // Verify that saved poses section is present
    expect(find.text('Saved Poses:'), findsOneWidget);
  });
}