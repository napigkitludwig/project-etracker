import '../../../core/network/api_response.dart';
import '../../auth/models/user.dart';
import '../models/project.dart';
import 'project_local_data_source.dart';

/// Project use-cases, with the RBAC matrix (SRD §3) enforced on every call.
///
/// * **Admin** — create, edit, archive, delete; sees everything.
/// * **CEO** — create; sees every project.
/// * **Project Manager / Assignee** — see the projects they are assigned to.
///
/// Every method takes the acting [User] and returns a [Result], so controllers
/// never branch on roles themselves and views can never bypass a rule.
class ProjectService {
  ProjectService({ProjectLocalDataSource? localDataSource})
    : _store = localDataSource ?? ProjectLocalDataSource();

  final ProjectLocalDataSource _store;

  /// Projects [actor] may see. Only admins may [includeArchived].
  Future<Result<List<Project>>> visibleProjects(
    User actor, {
    bool includeArchived = false,
  }) {
    return Result.guard<List<Project>>(
      () => _store.getProjects(
        visibleTo: actor.role.canViewAllProjects ? null : actor.id,
        includeArchived: includeArchived && actor.role.canManageProjects,
      ),
      fallbackMessage: 'Could not load projects.',
    );
  }

  /// A single project, if [actor] may see it.
  Future<Result<Project>> getProject(User actor, int projectId) async {
    final Result<bool> allowed = await canView(actor, projectId);
    if (allowed case Failure<bool>(:final String message)) {
      return Failure<Project>(message);
    }
    if (allowed.dataOrNull != true) {
      return const Failure<Project>('You do not have access to this project.');
    }
    final Project? project = await _store.getProjectById(projectId);
    if (project == null) {
      return const Failure<Project>('This project no longer exists.');
    }
    return Success<Project>(project);
  }

  /// Whether [actor] may see [projectId].
  Future<Result<bool>> canView(User actor, int projectId) {
    return Result.guard<bool>(() async {
      if (actor.role.canViewAllProjects) {
        return true;
      }
      final int? id = actor.id;
      return id != null && await _store.isAssigned(projectId, id);
    });
  }

  /// Explicit members of [projectId].
  Future<Result<List<int>>> memberIds(int projectId) =>
      Result.guard<List<int>>(() => _store.getMemberIds(projectId));

  /// Creates a project (Admin, CEO) with its assigned [memberIds].
  Future<Result<int>> createProject(
    User actor, {
    required String title,
    String description = '',
    Iterable<int> memberIds = const <int>[],
  }) async {
    if (!actor.role.canCreateProjects) {
      return const Failure<int>('Only the Admin or CEO can create projects.');
    }
    final String trimmed = title.trim();
    if (trimmed.isEmpty) {
      return const Failure<int>('A project title is required.');
    }
    return Result.guard<int>(
      () => _store.insertProject(
        Project(
          title: trimmed,
          description: description.trim(),
          createdBy: actor.id,
          createdAt: DateTime.now(),
        ),
        memberIds,
      ),
      fallbackMessage: 'Could not create the project.',
    );
  }

  /// Edits a project's details and members (Admin only).
  Future<Result<void>> updateProject(
    User actor,
    Project project, {
    Iterable<int>? memberIds,
  }) async {
    if (!actor.role.canManageProjects) {
      return const Failure<void>('Only an Admin can edit projects.');
    }
    if (project.title.trim().isEmpty) {
      return const Failure<void>('A project title is required.');
    }
    return Result.guard<void>(
      () => _store.updateProject(
        project.copyWith(
          title: project.title.trim(),
          description: project.description.trim(),
        ),
        memberIds: memberIds,
      ),
      fallbackMessage: 'Could not save the project.',
    );
  }

  /// Archives or restores a project (Admin only).
  Future<Result<void>> setArchived(
    User actor,
    Project project, {
    required bool archived,
  }) async {
    if (!actor.role.canManageProjects) {
      return const Failure<void>('Only an Admin can archive projects.');
    }
    return Result.guard<void>(
      () => _store.updateProject(project.copyWith(isArchived: archived)),
      fallbackMessage: 'Could not update the project.',
    );
  }

  /// Permanently deletes a project and everything in it (Admin only).
  Future<Result<void>> deleteProject(User actor, int projectId) async {
    if (!actor.role.canManageProjects) {
      return const Failure<void>('Only an Admin can delete projects.');
    }
    return Result.guard<void>(
      () => _store.deleteProject(projectId),
      fallbackMessage: 'Could not delete the project.',
    );
  }

  /// Makes [userId] a member of [projectId] (used when assigning tasks).
  Future<void> ensureMember(int projectId, int userId) =>
      _store.addMember(projectId, userId);
}
