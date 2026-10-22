import 'package:json_annotation/json_annotation.dart';

/// The twelve stages of the task lifecycle (SRD §5), in workflow order.
///
/// [dbValue] is the stable slug persisted to SQLite and exchanged with the API;
/// [label] is what the UI shows. Which moves between stages are legal — and who
/// may make them — is decided by `TaskWorkflow`, not here.
enum TaskStatus {
  /// Newly created task waiting to be acknowledged.
  todo('todo', 'To Do'),

  /// The assignee confirmed receipt and understanding of the task.
  acknowledged('acknowledged', 'Acknowledged'),

  /// Active work is underway.
  inProgress('in_progress', 'In Progress'),

  /// Work stopped due to external dependencies or impediments.
  blocked('blocked', 'Blocked'),

  /// Seeking third-party assistance or technical help.
  workingWithSupport('working_with_support', 'Working with Support'),

  /// Submitted to the project manager for verification.
  internalReview('internal_review', 'Internal Review'),

  /// Pending approval from the external client or stakeholder.
  clientReview('client_review', 'Client Review'),

  /// Escalated to the CEO / owner for executive verification.
  finalReview('final_review', 'Final Review'),

  /// Work fully validated.
  done('done', 'Done'),

  /// Transferred to another department or operator.
  handover('handover', 'Handover'),

  /// Officially archived and locked.
  closed('closed', 'Closed'),

  /// Terminated prior to completion.
  cancelled('cancelled', 'Cancelled');

  const TaskStatus(this.dbValue, this.label);

  /// The literal value stored in the `status` column / JSON payload.
  final String dbValue;

  /// Human readable label.
  final String label;

  /// Work has been delivered and validated (counts towards progress).
  bool get isCompleted =>
      this == TaskStatus.done ||
      this == TaskStatus.handover ||
      this == TaskStatus.closed;

  /// No further transitions are possible without an admin override.
  bool get isTerminal =>
      this == TaskStatus.closed || this == TaskStatus.cancelled;

  /// Still needs work or a decision (not completed and not cancelled).
  bool get isOpen => !isCompleted && this != TaskStatus.cancelled;

  /// Waiting on a reviewer rather than on the assignee.
  bool get isInReview =>
      this == TaskStatus.internalReview ||
      this == TaskStatus.clientReview ||
      this == TaskStatus.finalReview;

  /// Time spent in this status counts towards the task's recorded duration.
  bool get tracksTime => this == TaskStatus.inProgress;

  /// Statuses that satisfy a dependency: a task depending on one of these may
  /// begin.
  static const Set<TaskStatus> dependencySatisfied = <TaskStatus>{
    TaskStatus.done,
    TaskStatus.handover,
    TaskStatus.closed,
  };

  /// Parses a raw database or JSON value (slug or label, case-insensitive).
  ///
  /// Unknown values fall back to [TaskStatus.todo] so a malformed row can never
  /// crash the board.
  static TaskStatus fromDbValue(String? value) {
    final String normalized = (value ?? '').trim().toLowerCase();
    for (final TaskStatus status in TaskStatus.values) {
      if (status.dbValue == normalized ||
          status.label.toLowerCase() == normalized) {
        return status;
      }
    }
    return TaskStatus.todo;
  }
}

/// Serialises [TaskStatus] as its [TaskStatus.dbValue] slug, tolerantly.
class TaskStatusConverter implements JsonConverter<TaskStatus, String> {
  const TaskStatusConverter();

  @override
  TaskStatus fromJson(String json) => TaskStatus.fromDbValue(json);

  @override
  String toJson(TaskStatus object) => object.dbValue;
}
