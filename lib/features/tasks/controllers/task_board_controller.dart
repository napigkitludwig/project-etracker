import '../../../core/controllers/base_controller.dart';
import '../../../core/network/api_response.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../services/task_service.dart';
import '../services/task_workflow.dart';

/// Backs every task collection: a project's tasks, or "my tasks" across
/// projects. Renders as a list or a Kanban board — the view decides how,
/// this controller supplies the data, filters and status moves.
class TaskBoardController extends BaseController {
  TaskBoardController({
    required this.authController,
    required this._taskService,
    this.projectId,
    this._assignedToMe = false,
  });

  final AuthController authController;
  final TaskService _taskService;

  /// Scope to one project, or `null` for every visible project.
  final int? projectId;

  bool _assignedToMe;
  List<Task> _tasks = const <Task>[];
  TaskStatus? _statusFilter;
  String _query = '';
  bool _hideFinished = false;

  /// The signed-in user.
  User? get currentUser => authController.currentUser;

  /// Whether only the tasks assigned to the current user are shown.
  bool get assignedToMe => _assignedToMe;

  /// Active status filter (list view only), or `null` for all.
  TaskStatus? get statusFilter => _statusFilter;

  /// Active free-text filter.
  String get query => _query;

  /// Whether closed and cancelled tasks are hidden.
  bool get hideFinished => _hideFinished;

  /// Every loaded task.
  List<Task> get allTasks => List<Task>.unmodifiable(_tasks);

  /// Tasks after the search / "hide finished" filters (board view).
  List<Task> get boardTasks => _tasks
      .where(_matchesQuery)
      .where((Task task) => !_hideFinished || !task.status.isTerminal)
      .toList(growable: false);

  /// Tasks after every filter, including the status filter (list view).
  List<Task> get visibleTasks => boardTasks
      .where(
        (Task task) => _statusFilter == null || task.status == _statusFilter,
      )
      .toList(growable: false);

  /// Board tasks grouped by status, in workflow order.
  Map<TaskStatus, List<Task>> get columns {
    final Map<TaskStatus, List<Task>> grouped = <TaskStatus, List<Task>>{
      for (final TaskStatus status in TaskStatus.values) status: <Task>[],
    };
    for (final Task task in boardTasks) {
      grouped[task.status]!.add(task);
    }
    if (_hideFinished) {
      grouped.removeWhere((TaskStatus status, _) => status.isTerminal);
    }
    return grouped;
  }

  /// Number of loaded tasks per status (for filter chips).
  int countFor(TaskStatus status) =>
      _tasks.where((Task task) => task.status == status).length;

  /// Whether the current user can create tasks here.
  bool get canCreateTasks => currentUser?.role.canManageTasks ?? false;

  // --- Loading & filters -----------------------------------------------------

  Future<void> load() async {
    final User? user = currentUser;
    if (user == null) {
      return;
    }
    setLoading(true);
    clearError();
    final Result<List<Task>> result = await _taskService.visibleTasks(
      user,
      projectId: projectId,
      assignedToMe: _assignedToMe,
    );
    switch (result) {
      case Success<List<Task>>(:final List<Task> data):
        _tasks = data;
      case Failure<List<Task>>(:final String message):
        setError(message);
    }
    setLoading(false);
    notify();
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notify();
  }

  void setQuery(String value) {
    _query = value.trim().toLowerCase();
    notify();
  }

  void setHideFinished(bool value) {
    _hideFinished = value;
    notify();
  }

  Future<void> setAssignedToMe(bool value) async {
    if (value == _assignedToMe) {
      return;
    }
    _assignedToMe = value;
    notify();
    await load();
  }

  // --- Workflow --------------------------------------------------------------

  /// The moves the current user may make on [task].
  List<TaskTransition> transitionsFor(Task task) {
    final User? user = currentUser;
    if (user == null) {
      return const <TaskTransition>[];
    }
    return _taskService.workflow.transitionsFor(task, user);
  }

  /// The regular (non-override) move to [to], if the user may make it now.
  /// Used by the board to decide which columns accept a dragged card.
  TaskTransition? dropTransition(Task task, TaskStatus to) {
    for (final TaskTransition transition in transitionsFor(task)) {
      if (transition.to == to &&
          transition.isEnabled &&
          !transition.isOverride) {
        return transition;
      }
    }
    return null;
  }

  /// Moves [task] to [to]. Returns `null` on success, else an error message.
  Future<String?> moveTask(Task task, TaskStatus to, {String note = ''}) async {
    final User? user = currentUser;
    final int? id = task.id;
    if (user == null || id == null) {
      return 'Your session has ended.';
    }
    final Result<Task> result = await _taskService.changeStatus(
      user,
      id,
      to,
      note: note,
    );
    if (result case Failure<Task>(:final String message)) {
      return message;
    }
    await load();
    return null;
  }

  bool _matchesQuery(Task task) {
    if (_query.isEmpty) {
      return true;
    }
    return task.title.toLowerCase().contains(_query) ||
        (task.assigneeName?.toLowerCase().contains(_query) ?? false) ||
        (task.projectTitle?.toLowerCase().contains(_query) ?? false);
  }
}
