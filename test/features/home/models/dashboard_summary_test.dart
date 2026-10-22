import 'package:fluetpress/features/home/models/dashboard_summary.dart';
import 'package:fluetpress/features/tasks/models/task.dart';
import 'package:fluetpress/features/tasks/models/task_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 22, 12);

  Task task(int id, TaskStatus status, {int? assignedTo, DateTime? dueAt}) =>
      Task(
        id: id,
        projectId: 1,
        title: 'Task $id',
        createdAt: now,
        status: status,
        assignedTo: assignedTo,
        dueAt: dueAt,
      );

  group('DashboardSummary', () {
    test('is empty before any task is loaded', () {
      const DashboardSummary summary = DashboardSummary.empty();

      expect(summary.totalTasks, 0);
      expect(summary.isEmpty, isTrue);
    });

    test('counts open, mine, overdue, in-review and completed tasks', () {
      final DashboardSummary summary = DashboardSummary.fromTasks(
        <Task>[
          task(1, TaskStatus.todo, assignedTo: 7),
          task(
            2,
            TaskStatus.inProgress,
            assignedTo: 7,
            dueAt: now.subtract(const Duration(days: 1)),
          ),
          task(3, TaskStatus.internalReview, assignedTo: 8),
          task(4, TaskStatus.finalReview),
          task(
            5,
            TaskStatus.done,
            dueAt: now.subtract(const Duration(days: 3)),
          ),
          task(6, TaskStatus.closed),
          task(7, TaskStatus.cancelled),
        ],
        userId: 7,
        now: now,
      );

      expect(summary.totalTasks, 7);
      expect(summary.openTasks, 4);
      expect(summary.myOpenTasks, 2);
      // Done tasks are never overdue, even past their due date.
      expect(summary.overdueTasks, 1);
      expect(summary.inReviewTasks, 2);
      expect(summary.completedTasks, 2);
      expect(summary.byStatus[TaskStatus.todo], 1);
      expect(summary.byStatus[TaskStatus.blocked], isNull);
    });

    test('has value semantics', () {
      DashboardSummary build() => DashboardSummary.fromTasks(
        <Task>[task(1, TaskStatus.todo)],
        userId: null,
        now: now,
      );

      expect(build(), build());
      expect(build().hashCode, build().hashCode);
      expect(build(), isNot(const DashboardSummary.empty()));
    });
  });
}
