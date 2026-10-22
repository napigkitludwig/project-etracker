import '../../tasks/models/task.dart';
import '../../tasks/models/task_status.dart';

/// Aggregated task numbers shown on the dashboard.
///
/// A plain immutable value object: it is computed in memory from the tasks the
/// user can see and never crosses the wire, so it does not need (or want) code
/// generation.
class DashboardSummary {
  const DashboardSummary({
    required this.totalTasks,
    required this.openTasks,
    required this.myOpenTasks,
    required this.overdueTasks,
    required this.inReviewTasks,
    required this.completedTasks,
    required this.byStatus,
  });

  /// Empty summary, used before the tasks are loaded.
  const DashboardSummary.empty()
    : totalTasks = 0,
      openTasks = 0,
      myOpenTasks = 0,
      overdueTasks = 0,
      inReviewTasks = 0,
      completedTasks = 0,
      byStatus = const <TaskStatus, int>{};

  /// Derives the summary from [tasks] for the user [userId] at [now].
  factory DashboardSummary.fromTasks(
    List<Task> tasks, {
    required int? userId,
    required DateTime now,
  }) {
    int open = 0;
    int mine = 0;
    int overdue = 0;
    int review = 0;
    int completed = 0;
    final Map<TaskStatus, int> byStatus = <TaskStatus, int>{};

    for (final Task task in tasks) {
      byStatus[task.status] = (byStatus[task.status] ?? 0) + 1;
      if (task.status.isOpen) {
        open++;
        if (userId != null && task.assignedTo == userId) {
          mine++;
        }
      }
      if (task.isOverdue(now)) {
        overdue++;
      }
      if (task.status.isInReview) {
        review++;
      }
      if (task.status.isCompleted) {
        completed++;
      }
    }

    return DashboardSummary(
      totalTasks: tasks.length,
      openTasks: open,
      myOpenTasks: mine,
      overdueTasks: overdue,
      inReviewTasks: review,
      completedTasks: completed,
      byStatus: Map<TaskStatus, int>.unmodifiable(byStatus),
    );
  }

  /// Every visible task.
  final int totalTasks;

  /// Tasks that still need work or a decision.
  final int openTasks;

  /// Open tasks assigned to the current user.
  final int myOpenTasks;

  /// Open tasks past their due date.
  final int overdueTasks;

  /// Tasks waiting on an internal, client or final review.
  final int inReviewTasks;

  /// Done, handed over or closed.
  final int completedTasks;

  /// Number of tasks per status.
  final Map<TaskStatus, int> byStatus;

  bool get isEmpty => totalTasks == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardSummary &&
          other.totalTasks == totalTasks &&
          other.openTasks == openTasks &&
          other.myOpenTasks == myOpenTasks &&
          other.overdueTasks == overdueTasks &&
          other.inReviewTasks == inReviewTasks &&
          other.completedTasks == completedTasks;

  @override
  int get hashCode => Object.hash(
    totalTasks,
    openTasks,
    myOpenTasks,
    overdueTasks,
    inReviewTasks,
    completedTasks,
  );

  @override
  String toString() =>
      'DashboardSummary(total: $totalTasks, open: $openTasks, '
      'mine: $myOpenTasks, overdue: $overdueTasks, review: $inReviewTasks, '
      'completed: $completedTasks)';
}
