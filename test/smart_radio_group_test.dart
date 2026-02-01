import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_form_guard/smart_form_guard.dart';

void main() {
  group('SmartRadioGroup', () {
    testWidgets('renders options correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartRadioGroup<String>(
              initialValue: null,
              options: [
                SmartRadioOption(value: 'a', label: 'Option A'),
                SmartRadioOption(value: 'b', label: 'Option B'),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
    });

    testWidgets('calls onChanged when option selected', (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartRadioGroup<String>(
              initialValue: null,
              options: [
                SmartRadioOption(value: 'a', label: 'Option A'),
                SmartRadioOption(value: 'b', label: 'Option B'),
              ],
              onChanged: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Option A'));
      await tester.pump();

      expect(selectedValue, 'a');

      await tester.tap(find.text('Option B'));
      await tester.pump();

      expect(selectedValue, 'b');
    });

    testWidgets('shows validation error', (WidgetTester tester) async {
      final formKey = GlobalKey<SmartFormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartForm(
              key: formKey,
              child: SmartRadioGroup<String>(
                label: 'Choose One',
                options: [
                  SmartRadioOption(value: 'a', label: 'Option A'),
                ],
                validator: (value) => value == null ? 'Required field' : null,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Trigger validation by finding the form or just let it be invalid initial?
      // SmartForm doesn't validate on start usually.
      // We need to trigger validation.
      // We can access SmartFormState and call validate().
      
      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      expect(find.text('Required field'), findsOneWidget);
    });
  });
}
