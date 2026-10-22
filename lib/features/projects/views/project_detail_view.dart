import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app_router.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../../tasks/controllers/task_board_controller.dart';
import '../../tasks/models/task.dart';
import '../../tasks/services/task_service.dart';
import '../../tasks/views/widgets/task_collection.dart';
import '../controllers/project_detail_controller.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import 'projects_view.dart' show ProjectAction;
import 'widgets/project_form_dialog.dart';

/// One project: its summary and members, and its tasks as a list or a Kanban
/// board.
class ProjectDetailView extends StatefulWidget {
  const ProjectDetailView({super.key, required this.projectId});

  final int projectId;

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> {
  late final AuthController _auth = context.read<AuthController>();
  late final ProjectDetailController _project = ProjectDetailController(
    authController: _auth,
    projectService: context.read<ProjectService>(),
    projectId: widget.projectId,
  );
  late final TaskBoardController _tasks = TaskBoardController(
    authController: _auth,
    taskService: context.read<TaskService>(),
    projectId: widget.projectId,
  );

  @override
  void initState() {
    super.initState();
    _project.load();
    _tasks.load();
  }

  @override
  void dispose() {
    _project.dispose();
    _tasks.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait(<Future<void>>[_project.load(), _tasks.load()]);
  }

  Future<void> _openTask(Task task) => context.pushNamed(
    AppRoute.taskDetail.name,
    pathParameters: <String, String>{'taskId': '${task.id}'},
  );

  Future<void> _createTask() async {
    await context.pushNamed<int>(
      AppRoute.taskCreate.name,
      pathParameters: <String, String>{'projectId': '${widget.projectId}'},
    );
    await _refresh();
  }

  void _report(String? error, String success) {
    if (mounted) {
      context.showAppSnack(error ?? success, isError: error != null);
    }
  }

  Future<void> _onAction(ProjectAction action) async {
    final Project? project = _project.project;
    if (project == null) {
      return;
    }
    switch (action) {
      case ProjectAction.edit:
        final ProjectFormResult? form = await ProjectFormDialog.show(
          context,
          people: _project.people,
          project: project,
          initialMemberIds: _project.memberIds,
        );
        if (form != null) {
          _report(
            await _project.update(
              title: form.title,
              description: form.description,
              memberIds: form.memberIds,
            ),
            'Project saved.',
          );
        }
      case ProjectAction.archive:
      case ProjectAction.restore:
        final bool archive = action == ProjectAction.archive;
        _report(
          await _project.setArchived(archive),
          archive ? 'Project archived.' : 'Project restored.',
        );
      case ProjectAction.delete:
        final bool confirmed = await context.confirm(
          title: 'Delete project',
          message:
              'Permanently delete "${project.title}" and all of its tasks? '
              'This cannot be undone.',
          confirmLabel: 'Delete',
          destructive: true,
        );
        if (!confirmed) {
          return;
        }
        final String? error = await _project.delete();
        _report(error, 'Project deleted.');
        if (error == null && mounted) {
          context.pop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _project,
      builder: (BuildContext context, Widget? _) {
        final Project? project = _project.project;

        return Scaffold(
          appBar: AppBar(
            title: Text(project?.title ?? 'Project'),
            actions: <Widget>[
              if (project != null && _project.canManage)
                PopupMenuButton<ProjectAction>(
                  tooltip: 'Project actions',
                  onSelected: _onAction,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<ProjectAction>>[
                        const PopupMenuItem<ProjectAction>(
                          value: ProjectAction.edit,
                          child: Text('Edit project'),
                        ),
                        PopupMenuItem<ProjectAction>(
                          value: project.isArchived
                              ? ProjectAction.restore
                              : ProjectAction.archive,
                          child: Text(
                            project.isArchived ? 'Restore' : 'Archive',
                          ),
                        ),
                        const PopupMenuItem<ProjectAction>(
                          value: ProjectAction.delete,
                          child: Text('Delete project'),
                        ),
                      ],
                ),
            ],
          ),
          floatingActionButton:
              project != null && !project.isArchived && _tasks.canCreateTasks
              ? FloatingActionButton.extended(
                  onPressed: _createTask,
                  icon: const Icon(Icons.add_task),
                  label: const Text('New task'),
                )
              : null,
          body: project == null
              ? (_project.hasError
                    ? ErrorView(
                        message: _project.errorMessage!,
                        onRetry: _refresh,
                      )
                    : const LoadingView())
              : TaskCollection(
                  controller: _tasks,
                  onOpenTask: _openTask,
                  header: _ProjectHeader(
                    project: project,
                    members: _project.members,
                  ),
                ),
        );
      },
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({required this.project, required this.members});

  final Project project;
  final List<User> members;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (project.isArchived)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'ARCHIVED — read only',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (project.description.isNotEmpty)
                Text(
                  project.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: project.progress,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${project.completedTaskCount}/${project.taskCount} done',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    'Created by ${project.creatorName ?? 'unknown'} · '
                    '${project.createdAt.shortDate}',
                    style: theme.textTheme.bodySmall,
                  ),
                  for (final User member in members)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: CircleAvatar(
                        child: Text(
                          member.username.initials,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      label: Text(member.username),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
