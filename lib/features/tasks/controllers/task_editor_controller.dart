import '../../../core/controllers/base_controller.dart';
import '../../../core/network/api_response.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../../auth/services/user_local_data_source.dart';
import '../models/task.dart';
import '../services/task_service.dart';

/// Backs the create / edit task form: loads the people who can be assigned and
/// the project's other tasks (dependency candidates), then saves.
class TaskEditorController extends BaseController {
  TaskEditorController({
    required this.authController,
    required this._taskService,
    required this.projectId,
    this.taskId,
    UserLocalDataSource? userStore,
  }) : _userStore = userStore ?? UserLocalDataSource();

  final AuthController authController;
  final TaskService _taskService;
  final UserLocalDataSource _userStore;

  /// Project a new task is created in (taken from the task when editing).
  final int? projectId;

  /// The task being edited, or `null` when creating.
  final int? taskId;

  Task? _original;
  List<User> _people = const <User>[];
  List<Task> _projectTasks = const <Task>[];
  bool _ready = false;

  bool get isEditing => taskId != null;

  /// `true` once [load] finished (the form can be shown).
  bool get isReady => _ready;

  /// The task as loaded, when editing.
  Task? get original => _original;

  /// The project the form saves into.
  int? get resolvedProjectId => _original?.projectId ?? projectId;

  /// Everyone who can be assigned or receive a hand-off.
  List<User> get people => List<User>.unmodifiable(_people);

  /// Tasks this one may depend on (same project, not itself).
  List<Task> get dependencyCandidates => _projectTasks
      .where((Task task) => task.id != taskId)
      .toList(growable: false);

  Future<void> load() async {
    final User? user = authController.currentUser;
    if (user == null) {
      return;
    }
    setLoading(true);
    clearError();
    try {
      _people = await _userStore.getUsers();
      if (taskId != null) {
        final Result<Task> loaded = await _taskService.getTask(user, taskId!);
        _original = loaded.dataOrNull;
        if (loaded case Failure<Task>(:final String message)) {
          setError(message);
        }
      }
      final int? project = resolvedProjectId;
      if (project != null) {
        _projectTasks =
            (await _taskService.visibleTasks(
              user,
              projectId: project,
            )).dataOrNull ??
            const <Task>[];
      }
      _ready = !hasError && project != null;
    } catch (_) {
      setError('Could not load the form.');
    }
    setLoading(false);
    notify();
  }

  /// Creates or updates [task]. Returns the task id on success.
  Future<int?> save(Task task) async {
    final User? user = authController.currentUser;
    if (user == null) {
      setError('Your session has ended.');
      return null;
    }
    setLoading(true);
    clearError();
    final int? savedId;
    if (isEditing) {
      final Result<void> result = await _taskService.updateTask(
        user,
        task.copyWith(id: taskId),
      );
      savedId = result.isSuccess ? taskId : null;
      if (result case Failure<void>(:final String message)) {
        setError(message);
      }
    } else {
      final Result<int> result = await _taskService.createTask(user, task);
      savedId = result.dataOrNull;
      if (result case Failure<int>(:final String message)) {
        setError(message);
      }
    }
    setLoading(false);
    return savedId;
  }
}
