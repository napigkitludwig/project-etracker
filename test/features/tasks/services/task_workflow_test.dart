import 'package:fluetpress/features/auth/models/user.dart';
import 'package:fluetpress/features/auth/models/user_role.dart';
import 'package:fluetpress/features/tasks/models/task.dart';
import 'package:fluetpress/features/tasks/models/task_status.dart';
import 'package:fluetpress/features/tasks/services/task_workflow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const TaskWorkflow workflow = TaskWorkflow();

  const User admin = User(id: 1, username: 'admin', role: UserRole.admin);
  const User ceo = User(id: 2, username: 'ceo', role: UserRole.ceo);
  const User manager = User(
    id: 3,
    username: 'pm',
    role: UserRole.projectManager,
  );
  const User assignee = User(id: 4, username: 'dev', role: UserRole.assignee);
  const User stranger = User(id: 5, username: 'other', role: UserRole.assignee);

  final DateTime created = DateTime(2026, 10, 1, 9);

  Task task(TaskStatus status, {int? dependencyId, TaskStatus? dependency}) =>
      Task(
        id: 10,
        projectId: 1,
        title: 'Build it',
        createdAt: created,
        assignedTo: assignee.id,
        status: status,
        dependencyId: dependencyId,
        dependencyStatus: dependency,
      );

  Set<TaskStatus> targets(Task task, User user) => workflow
      .transitionsFor(task, user)
      .where((TaskTransition t) => !t.isOverride)
      .map((TaskTransition t) => t.to)
      .toSet();

  group('TaskWorkflow — who may move what', () {
    test('the assignee acknowledges, starts and submits for review', () {
      expect(targets(task(TaskStatus.todo), assignee), <TaskStatus>{
        TaskStatus.acknowledged,
      });
      expect(targets(task(TaskStatus.acknowledged), assignee), <TaskStatus>{
        TaskStatus.inProgress,
      });
      expect(targets(task(TaskStatus.inProgress), assignee), <TaskStatus>{
        TaskStatus.internalReview,
        TaskStatus.blocked,
        TaskStatus.workingWithSupport,
      });
    });

    test('an assignee cannot act on somebody else\'s task', () {
      expect(targets(task(TaskStatus.todo), stranger), isEmpty);
    });

    test('an assignee can never approve or skip reviews', () {
      expect(targets(task(TaskStatus.internalReview), assignee), isEmpty);
      expect(targets(task(TaskStatus.finalReview), assignee), isEmpty);
    });

    test('project managers run the internal and client reviews', () {
      expect(targets(task(TaskStatus.internalReview), manager), <TaskStatus>{
        TaskStatus.clientReview,
        TaskStatus.finalReview,
        TaskStatus.inProgress,
        TaskStatus.cancelled,
      });
      expect(targets(task(TaskStatus.clientReview), manager), <TaskStatus>{
        TaskStatus.finalReview,
        TaskStatus.inProgress,
        TaskStatus.cancelled,
      });
    });

    test('only the CEO signs off the final review', () {
      expect(
        targets(task(TaskStatus.finalReview), manager),
        isNot(contains(TaskStatus.done)),
      );
      expect(targets(task(TaskStatus.finalReview), ceo), <TaskStatus>{
        TaskStatus.done,
        TaskStatus.inProgress,
        TaskStatus.cancelled,
      });
    });

    test('only the CEO closes tasks', () {
      expect(targets(task(TaskStatus.done), manager), <TaskStatus>{
        TaskStatus.handover,
      });
      expect(targets(task(TaskStatus.done), ceo), <TaskStatus>{
        TaskStatus.handover,
        TaskStatus.closed,
      });
    });

    test('closed and cancelled tasks are locked', () {
      for (final User user in <User>[ceo, manager, assignee]) {
        expect(workflow.transitionsFor(task(TaskStatus.closed), user), isEmpty);
        expect(
          workflow.transitionsFor(task(TaskStatus.cancelled), user),
          isEmpty,
        );
      }
    });

    test('a task can never jump from To Do to Closed', () {
      expect(
        workflow.nextStatuses(TaskStatus.todo),
        isNot(contains(TaskStatus.closed)),
      );
      expect(
        () => workflow.validate(task(TaskStatus.todo), ceo, TaskStatus.closed),
        throwsA(isA<WorkflowException>()),
      );
    });

    test('admins get every regular move plus overrides', () {
      final List<TaskTransition> transitions = workflow.transitionsFor(
        task(TaskStatus.todo),
        admin,
      );
      final Iterable<TaskTransition> overrides = transitions.where(
        (TaskTransition t) => t.isOverride,
      );

      expect(
        transitions.map((TaskTransition t) => t.to).toSet(),
        TaskStatus.values.toSet()..remove(TaskStatus.todo),
      );
      expect(
        overrides.map((TaskTransition t) => t.to),
        contains(TaskStatus.closed),
      );
      expect(overrides.every((TaskTransition t) => t.requiresNote), isTrue);
    });
  });

  group('TaskWorkflow — guards', () {
    test('work cannot begin before the dependency is complete', () {
      final Task blocked = task(
        TaskStatus.acknowledged,
        dependencyId: 9,
        dependency: TaskStatus.inProgress,
      );
      final TaskTransition start = workflow
          .transitionsFor(blocked, assignee)
          .single;

      expect(start.isEnabled, isFalse);
      expect(
        () => workflow.validate(blocked, assignee, TaskStatus.inProgress),
        throwsA(isA<WorkflowException>()),
      );

      final Task ready = task(
        TaskStatus.acknowledged,
        dependencyId: 9,
        dependency: TaskStatus.done,
      );
      expect(
        workflow.validate(ready, assignee, TaskStatus.inProgress).to,
        TaskStatus.inProgress,
      );
    });

    test('handover needs a hand-off recipient', () {
      final Task done = task(TaskStatus.done);
      expect(
        () => workflow.validate(done, manager, TaskStatus.handover),
        throwsA(isA<WorkflowException>()),
      );
      expect(
        workflow
            .validate(done.copyWith(handoffTo: 4), manager, TaskStatus.handover)
            .to,
        TaskStatus.handover,
      );
    });

    test('rejections need a note', () {
      final Task review = task(TaskStatus.finalReview);
      expect(
        () => workflow.validate(review, ceo, TaskStatus.inProgress),
        throwsA(isA<WorkflowException>()),
      );
      expect(
        workflow
            .validate(
              review,
              ceo,
              TaskStatus.inProgress,
              note: 'Fix the footer',
            )
            .label,
        'Reject & re-open',
      );
    });
  });

  group('TaskWorkflow — side effects', () {
    test('starting stamps Date/Time Started once and starts the timer', () {
      final DateTime start = DateTime(2026, 10, 2, 9);
      final Task started = workflow.apply(
        task(TaskStatus.acknowledged),
        TaskStatus.inProgress,
        start,
      );

      expect(started.status, TaskStatus.inProgress);
      expect(started.startedAt, start);
      expect(started.inProgressSince, start);

      // Leaving In Progress adds the elapsed time to Duration.
      final Task paused = workflow.apply(
        started,
        TaskStatus.blocked,
        start.add(const Duration(minutes: 90)),
      );
      expect(paused.durationMinutes, 90);
      expect(paused.inProgressSince, isNull);

      // Resuming keeps the original start date.
      final DateTime resume = start.add(const Duration(hours: 3));
      final Task resumed = workflow.apply(
        paused,
        TaskStatus.inProgress,
        resume,
      );
      expect(resumed.startedAt, start);
      expect(resumed.inProgressSince, resume);
      expect(
        resumed.trackedMinutes(resume.add(const Duration(minutes: 30))),
        120,
      );
    });
  });
}
