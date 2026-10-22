import '../../../core/network/api_response.dart';
import '../../auth/models/user.dart';
import '../../projects/models/project.dart';
import '../../projects/services/project_service.dart';
import '../models/task.dart';
import '../models/task_history_entry.dart';
import '../models/task_status.dart';
import 'task_local_data_source.dart';
import 'task_workflow.dart';

/// Task use-cases, with the RBAC matrix (SRD §3) and the status state machine
/// ([TaskWorkflow]) enforced on every call.
///
/// * **Admin** — full access, including deleting tasks and status overrides.
/// * **CEO / Project Manager** — create, assign and edit tasks.
/// * **Assignee** — update status, track time and add notes on their own
///   tasks.
class TaskService {
  TaskService({
    required ProjectService projectService,
    TaskLocalDataSource? localDataSource,
    this._workflow = const TaskWorkflow(),
    DateTime Function()? clock,
  }) : _projects = projectService,
       _store = localDataSource ?? TaskLocalDataSource(),
       _clock = clock ?? DateTime.now;

  final ProjectService _projects;
  final TaskLocalDataSource _store;
  final TaskWorkflow _workflow;
  final DateTime Function() _clock;

  /// The state machine, exposed so controllers can list allowed moves.
  TaskWorkflow get workflow => _workflow;

  // --- Queries ---------------------------------------------------------------

  /// Tasks [actor] may see, optionally narrowed to one project or to the tasks
  /// assigned to [actor].
  Future<Result<List<Task>>> visibleTasks(
    User actor, {
    int? projectId,
    bool assignedToMe = false,
  }) async {
    if (projectId != null) {
      final Result<bool> allowed = await _projects.canView(actor, projectId);
      if (allowed.dataOrNull != true) {
        return const Failure<List<Task>>(
          'You do not have access to this project.',
        );
      }
    }
    return Result.guard<List<Task>>(
      () => _store.getTasks(
        projectId: projectId,
        assignedTo: assignedToMe ? actor.id : null,
        // Inside one project the access check above already ran; across
        // projects, non-privileged users only see their assigned projects.
        visibleTo: projectId != null || actor.role.canViewAllProjects
            ? null
            : actor.id,
        includeArchived: projectId != null,
      ),
      fallbackMessage: 'Could not load tasks.',
    );
  }

  /// A single task, if [actor] may see its project.
  Future<Result<Task>> getTask(User actor, int taskId) async {
    final Task? task = await _store.getTaskById(taskId);
    if (task == null) {
      return const Failure<Task>('This task no longer exists.');
    }
    final Result<bool> allowed = await _projects.canView(actor, task.projectId);
    if (allowed.dataOrNull != true) {
      return const Failure<Task>('You do not have access to this task.');
    }
    return Success<Task>(task);
  }

  /// Status history of [taskId], newest first.
  Future<Result<List<TaskHistoryEntry>>> history(int taskId) =>
      Result.guard<List<TaskHistoryEntry>>(() => _store.getHistory(taskId));

  // --- Editing ---------------------------------------------------------------

  /// Creates a task in To Do (CEO, Project Manager, Admin).
  Future<Result<int>> createTask(User actor, Task draft) async {
    if (!actor.role.canManageTasks) {
      return const Failure<int>('You are not allowed to create tasks.');
    }
    final Result<Project> project = await _projects.getProject(
      actor,
      draft.projectId,
    );
    if (project case Failure<Project>(:final String message)) {
      return Failure<int>(message);
    }
    if (project.dataOrNull!.isArchived) {
      return const Failure<int>('Archived projects are read-only.');
    }
    final String? invalid = await _validateFields(draft);
    if (invalid != null) {
      return Failure<int>(invalid);
    }

    final DateTime now = _clock();
    final Task task = draft.copyWith(
      id: null,
      title: draft.title.trim(),
      description: draft.description.trim(),
      createdBy: actor.id,
      createdAt: now,
      status: TaskStatus.todo,
      startedAt: null,
      inProgressSince: null,
      durationMinutes: 0,
    );

    return Result.guard<int>(() async {
      final int id = await _store.insertTask(
        task,
        (int id) => TaskHistoryEntry(
          taskId: id,
          toStatus: TaskStatus.todo,
          changedBy: actor.id,
          changedAt: now,
          note: task.assignedTo == null
              ? 'Task created'
              : 'Task created and assigned',
        ),
      );
      await _ensureMembers(task);
      return id;
    }, fallbackMessage: 'Could not create the task.');
  }

  /// Saves edited task fields (CEO, Project Manager, Admin).
  ///
  /// Status, timestamps and recorded time are *not* taken from [edited]: they
  /// only change through [changeStatus] and [logTime].
  Future<Result<void>> updateTask(User actor, Task edited) async {
    if (!actor.role.canManageTasks) {
      return const Failure<void>('You are not allowed to edit task details.');
    }
    final int? id = edited.id;
    if (id == null) {
      return const Failure<void>('This task has not been saved yet.');
    }
    final Result<Task> current = await getTask(actor, id);
    if (current case Failure<Task>(:final String message)) {
      return Failure<void>(message);
    }
    final Task existing = current.dataOrNull!;
    if (existing.status == TaskStatus.closed && !actor.role.isAdmin) {
      return const Failure<void>('Closed tasks are locked.');
    }
    final String? invalid = await _validateFields(edited);
    if (invalid != null) {
      return Failure<void>(invalid);
    }

    final Task merged = existing.copyWith(
      title: edited.title.trim(),
      description: edited.description.trim(),
      assignedTo: edited.assignedTo,
      dueAt: edited.dueAt,
      dependencyId: edited.dependencyId,
      timeBlockMinutes: edited.timeBlockMinutes,
      handoffTo: edited.handoffTo,
      notes: edited.notes,
    );
    return Result.guard<void>(() async {
      await _store.updateTask(merged);
      await _ensureMembers(merged);
    }, fallbackMessage: 'Could not save the task.');
  }

  /// Updates the working notes (the assignee, or anyone who can edit tasks).
  Future<Result<void>> updateNotes(User actor, int taskId, String notes) async {
    final Result<Task> loaded = await _loadForWork(actor, taskId);
    if (loaded case Failure<Task>(:final String message)) {
      return Failure<void>(message);
    }
    return Result.guard<void>(
      () => _store.updateTask(loaded.dataOrNull!.copyWith(notes: notes.trim())),
      fallbackMessage: 'Could not save the notes.',
    );
  }

  /// Adds [minutes] of manually tracked time (negative values correct
  /// mistakes, never below zero).
  Future<Result<void>> logTime(User actor, int taskId, int minutes) async {
    if (minutes == 0) {
      return const Failure<void>('Enter a number of minutes.');
    }
    final Result<Task> loaded = await _loadForWork(actor, taskId);
    if (loaded case Failure<Task>(:final String message)) {
      return Failure<void>(message);
    }
    final Task task = loaded.dataOrNull!;
    final int total = task.durationMinutes + minutes;
    return Result.guard<void>(
      () => _store.updateTask(
        task.copyWith(durationMinutes: total < 0 ? 0 : total),
      ),
      fallbackMessage: 'Could not log the time.',
    );
  }

  /// Moves a task through the workflow, recording the transition.
  Future<Result<Task>> changeStatus(
    User actor,
    int taskId,
    TaskStatus to, {
    String note = '',
  }) async {
    final Result<Task> loaded = await getTask(actor, taskId);
    if (loaded case Failure<Task>(:final String message)) {
      return Failure<Task>(message);
    }
    final Task task = loaded.dataOrNull!;

    final TaskTransition transition;
    try {
      transition = _workflow.validate(task, actor, to, note: note);
    } on WorkflowException catch (error) {
      return Failure<Task>(error.message);
    }

    final DateTime now = _clock();
    final Task moved = _workflow.apply(task, to, now);
    return Result.guard<Task>(() async {
      await _store.updateTask(
        moved,
        history: TaskHistoryEntry(
          taskId: taskId,
          fromStatus: task.status,
          toStatus: to,
          changedBy: actor.id,
          changedAt: now,
          note: note.trim().isEmpty ? transition.label : note.trim(),
          isOverride: transition.isOverride,
        ),
      );
      return moved;
    }, fallbackMessage: 'Could not update the status.');
  }

  /// Permanently deletes a task (Admin only — everyone else cancels).
  Future<Result<void>> deleteTask(User actor, int taskId) async {
    if (!actor.role.canDeleteTasks) {
      return const Failure<void>(
        'Only an Admin can delete tasks. Cancel the task instead.',
      );
    }
    return Result.guard<void>(
      () => _store.deleteTask(taskId),
      fallbackMessage: 'Could not delete the task.',
    );
  }

  // --- Helpers ---------------------------------------------------------------

  /// Loads a task the actor may *work on*: their own task, or any task when
  /// they can manage tasks. Closed and cancelled tasks are locked.
  Future<Result<Task>> _loadForWork(User actor, int taskId) async {
    final Result<Task> loaded = await getTask(actor, taskId);
    if (loaded case Failure<Task>()) {
      return loaded;
    }
    final Task task = loaded.dataOrNull!;
    final bool isOwner = actor.id != null && task.assignedTo == actor.id;
    if (!isOwner && !actor.role.canManageTasks) {
      return const Failure<Task>('Only the assignee can update this task.');
    }
    if (task.status.isTerminal && !actor.role.isAdmin) {
      return Failure<Task>('${task.status.label} tasks are locked.');
    }
    return loaded;
  }

  Future<String?> _validateFields(Task task) async {
    if (task.title.trim().isEmpty) {
      return 'A task title is required.';
    }
    final int? minutes = task.timeBlockMinutes;
    if (minutes != null && minutes < 0) {
      return 'The time block cannot be negative.';
    }
    final int? dependency = task.dependencyId;
    if (dependency != null) {
      if (dependency == task.id) {
        return 'A task cannot depend on itself.';
      }
      final Task? prerequisite = await _store.getTaskById(dependency);
      if (prerequisite == null) {
        return 'The selected dependency no longer exists.';
      }
      if (prerequisite.projectId != task.projectId) {
        return 'A dependency must belong to the same project.';
      }
      final int? id = task.id;
      if (id != null &&
          (await _store.getDependencyChain(dependency)).contains(id)) {
        return 'That dependency would create a circular chain.';
      }
    }
    return null;
  }

  /// Assigned users and hand-off recipients become project members, so the
  /// project shows up in their "assigned projects".
  Future<void> _ensureMembers(Task task) async {
    for (final int? userId in <int?>[task.assignedTo, task.handoffTo]) {
      if (userId != null) {
        await _projects.ensureMember(task.projectId, userId);
      }
    }
  }
}
