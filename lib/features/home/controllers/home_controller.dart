import '../../../core/controllers/base_controller.dart';
import '../../../core/network/api_response.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../../auth/models/user_role.dart';
import '../../projects/models/project.dart';
import '../../projects/services/project_service.dart';
import '../../tasks/models/task.dart';
import '../../tasks/models/task_status.dart';
import '../../tasks/services/task_service.dart';
import '../models/dashboard_summary.dart';

/// Backs the dashboard: task counters, the projects the user can see and the
/// tasks waiting on *this* user — which depends on their role:
///
/// * **Assignee** — their own tasks that still need work.
/// * **Project Manager** — tasks in internal or client review.
/// * **CEO** — tasks in final review, and done tasks waiting to be closed.
/// * **Admin** — blocked and overdue tasks across the workspace.
class HomeController extends BaseController {
  HomeController({
    required this.authController,
    required this._projectService,
    required this._taskService,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Session controller backing this screen.
  final AuthController authController;

  final ProjectService _projectService;
  final TaskService _taskService;
  final DateTime Function() _clock;

  List<Project> _projects = const <Project>[];
  List<Task> _tasks = const <Task>[];

  /// The signed-in user (delegated to [AuthController]).
  User? get currentUser => authController.currentUser;

  /// Projects the user can see.
  List<Project> get projects => List<Project>.unmodifiable(_projects);

  /// Dashboard counters derived from the visible tasks.
  DashboardSummary get summary => DashboardSummary.fromTasks(
    _tasks,
    userId: currentUser?.id,
    now: _clock(),
  );

  /// What "needs your attention" means for the current role (for the UI).
  String get attentionHint => switch (currentUser?.role) {
    UserRole.admin => 'Blocked and overdue tasks across the workspace.',
    UserRole.ceo => 'Tasks awaiting your final review or closing.',
    UserRole.projectManager => 'Tasks awaiting your internal or client review.',
    _ => 'Your tasks that still need work.',
  };

  /// Tasks waiting on the current user, soonest due first.
  List<Task> get needsAttention {
    final User? user = currentUser;
    if (user == null) {
      return const <Task>[];
    }
    final DateTime now = _clock();
    bool waitsOnUser(Task task) => switch (user.role) {
      UserRole.admin =>
        task.status == TaskStatus.blocked || task.isOverdue(now),
      UserRole.ceo =>
        task.status == TaskStatus.finalReview ||
            task.status == TaskStatus.done ||
            task.status == TaskStatus.handover,
      UserRole.projectManager =>
        task.status == TaskStatus.internalReview ||
            task.status == TaskStatus.clientReview ||
            (task.assignedTo == user.id && _needsWork(task)),
      UserRole.assignee => task.assignedTo == user.id && _needsWork(task),
    };
    return _tasks.where(waitsOnUser).toList(growable: false);
  }

  /// Open tasks due within the next 7 days (or already overdue).
  List<Task> get upcoming {
    final DateTime horizon = _clock().add(const Duration(days: 7));
    return _tasks
        .where(
          (Task task) =>
              task.status.isOpen &&
              task.dueAt != null &&
              task.dueAt!.isBefore(horizon),
        )
        .toList(growable: false);
  }

  // --- Loading ---------------------------------------------------------------

  /// Loads everything the current role is allowed to see.
  ///
  /// Safe to call from `initState` and from pull-to-refresh.
  Future<void> load() async {
    final User? user = currentUser;
    if (user == null) {
      return;
    }
    setLoading(true);
    clearError();
    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      _projectService.visibleProjects(user),
      _taskService.visibleTasks(user),
    ]);
    final Result<List<Project>> projects = results[0] as Result<List<Project>>;
    final Result<List<Task>> tasks = results[1] as Result<List<Task>>;

    _projects = projects.dataOrNull ?? _projects;
    _tasks = tasks.dataOrNull ?? _tasks;
    final String? error = projects.errorOrNull ?? tasks.errorOrNull;
    if (error != null) {
      setError(error);
    }
    setLoading(false);
    notify();
  }

  // --- Session ---------------------------------------------------------------

  /// Ends the session. The router guard navigates back to `/login`.
  Future<void> signOut() => authController.signOut();

  static bool _needsWork(Task task) => const <TaskStatus>{
    TaskStatus.todo,
    TaskStatus.acknowledged,
    TaskStatus.inProgress,
    TaskStatus.blocked,
    TaskStatus.workingWithSupport,
  }.contains(task.status);
}
