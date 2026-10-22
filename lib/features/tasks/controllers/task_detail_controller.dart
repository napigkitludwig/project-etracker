import '../../../core/controllers/base_controller.dart';
import '../../../core/network/api_response.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../models/task.dart';
import '../models/task_history_entry.dart';
import '../models/task_status.dart';
import '../services/task_service.dart';
import '../services/task_workflow.dart';

/// Backs the task detail screen: the task, its history, the status moves the
/// current user may make, time tracking and notes.
class TaskDetailController extends BaseController {
  TaskDetailController({
    required this.authController,
    required this._taskService,
    required this.taskId,
  });

  final AuthController authController;
  final TaskService _taskService;
  final int taskId;

  Task? _task;
  List<TaskHistoryEntry> _history = const <TaskHistoryEntry>[];

  Task? get task => _task;
  List<TaskHistoryEntry> get history =>
      List<TaskHistoryEntry>.unmodifiable(_history);

  User? get currentUser => authController.currentUser;

  /// Whether the current user is this task's assignee.
  bool get isAssignee {
    final int? id = currentUser?.id;
    return id != null && _task?.assignedTo == id;
  }

  /// Can edit title, description, assignment, dates, dependency, hand-off.
  bool get canEditDetails {
    final User? user = currentUser;
    if (user == null || _task == null) {
      return false;
    }
    return user.role.canManageTasks &&
        (_task!.status != TaskStatus.closed || user.role.isAdmin);
  }

  /// Can log time and edit notes.
  bool get canWork {
    final User? user = currentUser;
    if (user == null || _task == null) {
      return false;
    }
    if (_task!.status.isTerminal && !user.role.isAdmin) {
      return false;
    }
    return isAssignee || user.role.canManageTasks;
  }

  bool get canDelete => currentUser?.role.canDeleteTasks ?? false;

  /// Status moves available to the current user.
  List<TaskTransition> get transitions {
    final User? user = currentUser;
    if (user == null || _task == null) {
      return const <TaskTransition>[];
    }
    return _taskService.workflow.transitionsFor(_task!, user);
  }

  Future<void> load() async {
    final User? user = currentUser;
    if (user == null) {
      return;
    }
    setLoading(true);
    clearError();
    final Result<Task> result = await _taskService.getTask(user, taskId);
    switch (result) {
      case Success<Task>(:final Task data):
        _task = data;
        _history =
            (await _taskService.history(taskId)).dataOrNull ??
            const <TaskHistoryEntry>[];
      case Failure<Task>(:final String message):
        setError(message);
    }
    setLoading(false);
    notify();
  }

  /// Returns `null` on success, else an error message.
  Future<String?> changeStatus(TaskStatus to, {String note = ''}) => _run(
    (User user) => _taskService.changeStatus(user, taskId, to, note: note),
  );

  Future<String?> logTime(int minutes) =>
      _run((User user) => _taskService.logTime(user, taskId, minutes));

  Future<String?> saveNotes(String notes) =>
      _run((User user) => _taskService.updateNotes(user, taskId, notes));

  /// Deletes the task. Returns `null` on success.
  Future<String?> delete() async {
    final User? user = currentUser;
    if (user == null) {
      return 'Your session has ended.';
    }
    final Result<void> result = await _taskService.deleteTask(user, taskId);
    return result.errorOrNull;
  }

  Future<String?> _run<T>(Future<Result<T>> Function(User user) action) async {
    final User? user = currentUser;
    if (user == null) {
      return 'Your session has ended.';
    }
    setLoading(true);
    final Result<T> result = await action(user);
    setLoading(false);
    if (result case Failure<T>(:final String message)) {
      return message;
    }
    await load();
    return null;
  }
}
