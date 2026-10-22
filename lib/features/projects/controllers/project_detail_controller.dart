import '../../../core/controllers/base_controller.dart';
import '../../../core/network/api_response.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../../auth/services/user_local_data_source.dart';
import '../models/project.dart';
import '../services/project_service.dart';

/// Backs the project header on the project screen: details, members and the
/// admin actions. The project's tasks are handled by a `TaskBoardController`.
class ProjectDetailController extends BaseController {
  ProjectDetailController({
    required this.authController,
    required this._projectService,
    required this.projectId,
    UserLocalDataSource? userStore,
  }) : _userStore = userStore ?? UserLocalDataSource();

  final AuthController authController;
  final ProjectService _projectService;
  final UserLocalDataSource _userStore;
  final int projectId;

  Project? _project;
  List<User> _people = const <User>[];
  List<int> _memberIds = const <int>[];

  Project? get project => _project;

  /// Everyone, for the edit form.
  List<User> get people => List<User>.unmodifiable(_people);

  List<int> get memberIds => List<int>.unmodifiable(_memberIds);

  /// Explicit project members.
  List<User> get members => _people
      .where((User user) => _memberIds.contains(user.id))
      .toList(growable: false);

  bool get canManage =>
      authController.currentUser?.role.canManageProjects ?? false;

  Future<void> load() async {
    final User? user = authController.currentUser;
    if (user == null) {
      return;
    }
    setLoading(true);
    clearError();
    final Result<Project> result = await _projectService.getProject(
      user,
      projectId,
    );
    switch (result) {
      case Success<Project>(:final Project data):
        _project = data;
        _memberIds =
            (await _projectService.memberIds(projectId)).dataOrNull ??
            const <int>[];
        _people = await _userStore.getUsers();
      case Failure<Project>(:final String message):
        setError(message);
    }
    setLoading(false);
    notify();
  }

  /// Returns `null` on success, else an error message.
  Future<String?> update({
    required String title,
    required String description,
    required Set<int> memberIds,
  }) => _mutate(
    (User user) => _projectService.updateProject(
      user,
      _project!.copyWith(title: title, description: description),
      memberIds: memberIds,
    ),
  );

  Future<String?> setArchived(bool archived) => _mutate(
    (User user) =>
        _projectService.setArchived(user, _project!, archived: archived),
  );

  Future<String?> delete() async {
    final User? user = authController.currentUser;
    if (user == null) {
      return 'Your session has ended.';
    }
    return (await _projectService.deleteProject(user, projectId)).errorOrNull;
  }

  Future<String?> _mutate<T>(
    Future<Result<T>> Function(User user) action,
  ) async {
    final User? user = authController.currentUser;
    if (user == null || _project == null) {
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
