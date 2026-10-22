import '../../auth/models/user.dart';
import '../../auth/models/user_role.dart';
import '../models/task.dart';
import '../models/task_status.dart';

/// Who is acting on a task, relative to that task.
enum WorkflowActor {
  /// The user the task is assigned to (whatever their role).
  assignee,

  /// A project manager: creates, assigns and updates tasks; runs the internal
  /// and client reviews.
  projectManager,

  /// The CEO / owner: exclusive final review and closing authority.
  ceo,

  /// Administrator: may perform every transition, plus overrides.
  admin,
}

/// A move the acting user may make from a task's current status.
class TaskTransition {
  const TaskTransition({
    required this.to,
    required this.label,
    this.requiresNote = false,
    this.isOverride = false,
    this.blockedReason,
  });

  /// Target status.
  final TaskStatus to;

  /// Action verb shown on the button ("Acknowledge", "Approve", …).
  final String label;

  /// Whether the user must explain the move (rejections, blocks, cancels).
  final bool requiresNote;

  /// An admin-only move outside the regular workflow.
  final bool isOverride;

  /// When non-null the move is listed but currently not possible, and this is
  /// why (e.g. an unfinished dependency).
  final String? blockedReason;

  /// Whether the move can be made right now.
  bool get isEnabled => blockedReason == null;

  @override
  String toString() => 'TaskTransition(${to.dbValue}, $label)';
}

/// The task lifecycle as an explicit state machine (SRD §5, §6 and §10.1).
///
/// Tasks can only move along the edges declared in [_rules], and each edge
/// names the actors allowed to take it — so a task can never jump from
/// *To Do* to *Closed* without passing *Final Review*, an assignee cannot
/// approve their own work, and only the CEO can sign off.
///
/// ```text
/// To Do → Acknowledged → In Progress ⇄ Blocked / Working with Support
///   → Internal Review (PM) → [Client Review (PM)] → Final Review (CEO)
///   → Done → [Handover] → Closed
///   (Reviews can send the task back to In Progress; managers can Cancel any
///    task that is not yet done.)
/// ```
///
/// Pure Dart with no I/O: every rule is unit-testable in isolation.
class TaskWorkflow {
  const TaskWorkflow();

  static const Set<WorkflowActor> _workers = <WorkflowActor>{
    WorkflowActor.assignee,
    WorkflowActor.projectManager,
  };
  static const Set<WorkflowActor> _reviewers = <WorkflowActor>{
    WorkflowActor.projectManager,
  };
  static const Set<WorkflowActor> _executives = <WorkflowActor>{
    WorkflowActor.ceo,
  };
  static const Set<WorkflowActor> _managers = <WorkflowActor>{
    WorkflowActor.projectManager,
    WorkflowActor.ceo,
  };

  /// Statuses a manager may still cancel from.
  static const Set<TaskStatus> _cancellable = <TaskStatus>{
    TaskStatus.todo,
    TaskStatus.acknowledged,
    TaskStatus.inProgress,
    TaskStatus.blocked,
    TaskStatus.workingWithSupport,
    TaskStatus.internalReview,
    TaskStatus.clientReview,
    TaskStatus.finalReview,
  };

  static final List<_Rule> _rules = <_Rule>[
    // Assignee picks the task up.
    const _Rule(
      TaskStatus.todo,
      TaskStatus.acknowledged,
      'Acknowledge',
      _workers,
    ),
    const _Rule(
      TaskStatus.acknowledged,
      TaskStatus.inProgress,
      'Start work',
      _workers,
    ),
    // Working.
    const _Rule(
      TaskStatus.inProgress,
      TaskStatus.internalReview,
      'Submit for review',
      _workers,
    ),
    const _Rule(
      TaskStatus.inProgress,
      TaskStatus.blocked,
      'Mark blocked',
      _workers,
      requiresNote: true,
    ),
    const _Rule(
      TaskStatus.inProgress,
      TaskStatus.workingWithSupport,
      'Request support',
      _workers,
    ),
    const _Rule(
      TaskStatus.blocked,
      TaskStatus.inProgress,
      'Resume work',
      _workers,
    ),
    const _Rule(
      TaskStatus.blocked,
      TaskStatus.workingWithSupport,
      'Request support',
      _workers,
    ),
    const _Rule(
      TaskStatus.workingWithSupport,
      TaskStatus.inProgress,
      'Resume work',
      _workers,
    ),
    const _Rule(
      TaskStatus.workingWithSupport,
      TaskStatus.blocked,
      'Mark blocked',
      _workers,
      requiresNote: true,
    ),
    // Project manager reviews.
    const _Rule(
      TaskStatus.internalReview,
      TaskStatus.clientReview,
      'Send to client review',
      _reviewers,
    ),
    const _Rule(
      TaskStatus.internalReview,
      TaskStatus.finalReview,
      'Escalate to final review',
      _reviewers,
    ),
    const _Rule(
      TaskStatus.internalReview,
      TaskStatus.inProgress,
      'Request changes',
      _reviewers,
      requiresNote: true,
    ),
    const _Rule(
      TaskStatus.clientReview,
      TaskStatus.finalReview,
      'Client approved — escalate',
      _reviewers,
    ),
    const _Rule(
      TaskStatus.clientReview,
      TaskStatus.inProgress,
      'Client requested changes',
      _reviewers,
      requiresNote: true,
    ),
    // CEO sign-off.
    const _Rule(
      TaskStatus.finalReview,
      TaskStatus.done,
      'Approve',
      _executives,
    ),
    const _Rule(
      TaskStatus.finalReview,
      TaskStatus.inProgress,
      'Reject & re-open',
      _executives,
      requiresNote: true,
    ),
    // Wrap-up.
    const _Rule(TaskStatus.done, TaskStatus.handover, 'Hand over', _managers),
    const _Rule(TaskStatus.done, TaskStatus.closed, 'Close', _executives),
    const _Rule(TaskStatus.handover, TaskStatus.closed, 'Close', _executives),
    // Cancellation.
    for (final TaskStatus from in _cancellable)
      _Rule(
        from,
        TaskStatus.cancelled,
        'Cancel task',
        _managers,
        requiresNote: true,
      ),
  ];

  /// Every actor capacity [user] holds on [task].
  ///
  /// A project manager who is also the assignee acts in both capacities.
  Set<WorkflowActor> actorsFor(Task task, User user) {
    final Set<WorkflowActor> actors = <WorkflowActor>{};
    if (user.id != null && task.assignedTo == user.id) {
      actors.add(WorkflowActor.assignee);
    }
    switch (user.role) {
      case UserRole.admin:
        actors.add(WorkflowActor.admin);
      case UserRole.ceo:
        actors.add(WorkflowActor.ceo);
      case UserRole.projectManager:
        actors.add(WorkflowActor.projectManager);
      case UserRole.assignee:
        break;
    }
    return actors;
  }

  /// The regular (non-override) moves out of [from], regardless of actor.
  List<TaskStatus> nextStatuses(TaskStatus from) => <TaskStatus>[
    for (final _Rule rule in _rules)
      if (rule.from == from) rule.to,
  ];

  /// The moves [user] may make on [task], each annotated with whether it is
  /// currently possible.
  ///
  /// Administrators additionally receive every other status as an override
  /// (`isOverride: true`), which always requires a note.
  List<TaskTransition> transitionsFor(Task task, User user) {
    final Set<WorkflowActor> actors = actorsFor(task, user);
    final bool isAdmin = actors.contains(WorkflowActor.admin);

    final List<TaskTransition> transitions = <TaskTransition>[];
    for (final _Rule rule in _rules) {
      if (rule.from != task.status) {
        continue;
      }
      if (!isAdmin && rule.actors.intersection(actors).isEmpty) {
        continue;
      }
      transitions.add(
        TaskTransition(
          to: rule.to,
          label: rule.label,
          requiresNote: rule.requiresNote,
          blockedReason: _guard(task, rule.to),
        ),
      );
    }

    if (isAdmin) {
      final Set<TaskStatus> covered = <TaskStatus>{
        task.status,
        for (final TaskTransition transition in transitions) transition.to,
      };
      for (final TaskStatus status in TaskStatus.values) {
        if (!covered.contains(status)) {
          transitions.add(
            TaskTransition(
              to: status,
              label: 'Override → ${status.label}',
              requiresNote: true,
              isOverride: true,
            ),
          );
        }
      }
    }
    return transitions;
  }

  /// Validates moving [task] to [to] as [user].
  ///
  /// Returns the matching [TaskTransition] or throws a [WorkflowException]
  /// carrying a user-facing message.
  TaskTransition validate(
    Task task,
    User user,
    TaskStatus to, {
    String note = '',
  }) {
    if (to == task.status) {
      throw WorkflowException('The task is already "${to.label}".');
    }
    final TaskTransition? transition = transitionsFor(
      task,
      user,
    ).where((TaskTransition candidate) => candidate.to == to).firstOrNull;

    if (transition == null) {
      throw WorkflowException(
        'You cannot move a task from "${task.status.label}" to "${to.label}".',
      );
    }
    if (transition.blockedReason != null) {
      throw WorkflowException(transition.blockedReason!);
    }
    if (transition.requiresNote && note.trim().isEmpty) {
      throw const WorkflowException(
        'Please add a note explaining this change.',
      );
    }
    return transition;
  }

  /// Returns [task] moved to [to] at [now], applying the lifecycle side
  /// effects:
  /// * the first move into In Progress stamps **Date/Time Started**,
  /// * time spent In Progress is added to **Duration** when the task leaves it.
  Task apply(Task task, TaskStatus to, DateTime now) {
    int duration = task.durationMinutes;
    DateTime? since = task.inProgressSince;

    if (task.status.tracksTime && !to.tracksTime) {
      if (since != null && now.isAfter(since)) {
        duration += now.difference(since).inMinutes;
      }
      since = null;
    } else if (!task.status.tracksTime && to.tracksTime) {
      since = now;
    }

    return task.copyWith(
      status: to,
      startedAt: to == TaskStatus.inProgress
          ? (task.startedAt ?? now)
          : task.startedAt,
      durationMinutes: duration,
      inProgressSince: since,
    );
  }

  /// Business preconditions on entering [to].
  String? _guard(Task task, TaskStatus to) {
    if (to == TaskStatus.inProgress &&
        task.status == TaskStatus.acknowledged &&
        !task.isDependencySatisfied) {
      final String name = task.dependencyTitle ?? 'the prerequisite task';
      return 'Waiting on "$name" to be completed first.';
    }
    if (to == TaskStatus.handover && task.handoffTo == null) {
      return 'Choose a hand-off recipient before handing over.';
    }
    return null;
  }
}

/// A rejected workflow move. [message] is safe to show to the user.
class WorkflowException implements Exception {
  const WorkflowException(this.message);

  final String message;

  @override
  String toString() => 'WorkflowException: $message';
}

class _Rule {
  const _Rule(
    this.from,
    this.to,
    this.label,
    this.actors, {
    this.requiresNote = false,
  });

  final TaskStatus from;
  final TaskStatus to;
  final String label;
  final Set<WorkflowActor> actors;
  final bool requiresNote;
}
