import '../../../core/controllers/base_controller.dart';
import '../../../core/network/api_response.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../../auth/services/user_local_data_source.dart';
import '../models/project.dart';
import '../services/project_service.dart';

/// Backs the projects list and the project create / edit / archive / delete
/// actions. Permission enforcement lives in [ProjectService]; the flags here
/// only decide which controls the view shows.
class ProjectsController extends BaseController {
  ProjectsController({
    required this.authController,
    required this._projectService,
    UserLocalDataSource? userStore,
  }) : _userStore = userStore ?? UserLocalDataSource();

  final AuthController authController;
  final ProjectService _projectService;
  final UserLocalDataSource _userStore;

  List<Project> _projects = const <Project>[];
  List<User> _people = const <User>[];
  bool _showArchived = false;

  List<Project> get projects => List<Project>.unmodifiable(_projects);

  /// Accounts that can be made project members.
  List<User> get people => List<User>.unmodifiable(_people);

  bool get showArchived => _showArchived;

  User? get currentUser => authController.currentUser;

  bool get canCreate => currentUser?.role.canCreateProjects ?? false;

  /// Edit, archive and delete (Admin only).
  bool get canManage => currentUser?.role.canManageProjects ?? false;

  Future<void> load() async {
    final User? user = currentUser;
    if (user == null) {
      return;
    }
    setLoading(true);
    clearError();
    final Result<List<Project>> result = await _projectService.visibleProjects(
      user,
      includeArchived: _showArchived,
    );
    switch (result) {
      case Success<List<Project>>(:final List<Project> data):
        _projects = data;
      case Failure<List<Project>>(:final String message):
        setError(message);
    }
    if (canCreate && _people.isEmpty) {
      _people = await _userStore.getUsers();
    }
    setLoading(false);
    notify();
  }

  Future<void> setShowArchived(bool value) async {
    _showArchived = value;
    notify();
    await load();
  }

  /// Member ids of [project] (to pre-fill the edit form).
  Future<List<int>> memberIdsOf(Project project) async =>
      (await _projectService.memberIds(project.id!)).dataOrNull ??
      const <int>[];

  /// Returns `null` on success, else an error message.
  Future<String?> create({
    required String title,
    required String description,
    required Set<int> memberIds,
  }) => _mutate(
    (User user) => _projectService.createProject(
      user,
      title: title,
      description: description,
      memberIds: memberIds,
    ),
  );

  Future<String?> update(
    Project project, {
    required String title,
    required String description,
    required Set<int> memberIds,
  }) => _mutate(
    (User user) => _projectService.updateProject(
      user,
      project.copyWith(title: title, description: description),
      memberIds: memberIds,
    ),
  );

  Future<String?> setArchived(Project project, bool archived) => _mutate(
    (User user) =>
        _projectService.setArchived(user, project, archived: archived),
  );

  Future<String?> delete(Project project) =>
      _mutate((User user) => _projectService.deleteProject(user, project.id!));

  Future<String?> _mutate<T>(
    Future<Result<T>> Function(User user) action,
  ) async {
    final User? user = currentUser;
    if (user == null) {
      return 'Your session has ended.';
    }
    final Result<T> result = await action(user);
    if (result case Failure<T>(:final String message)) {
      return message;
    }
    await load();
    return null;
  }
}
