import 'package:fluetpress/core/theme/app_theme.dart';
import 'package:fluetpress/features/tasks/models/task_status.dart';
import 'package:fluetpress/features/tasks/views/widgets/task_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TaskStatusChip renders every status label in the dark theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Wrap(
            children: <Widget>[
              for (final TaskStatus status in TaskStatus.values)
                TaskStatusChip(status: status),
            ],
          ),
        ),
      ),
    );

    for (final TaskStatus status in TaskStatus.values) {
      expect(find.text(status.label), findsOneWidget);
    }
  });
}
