import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app_router.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/projects_controller.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import 'widgets/project_card.dart';
import 'widgets/project_form_dialog.dart';

/// Admin project actions available from a card's overflow menu.
enum ProjectAction { edit, archive, restore, delete }

/// Every project the user can see. Admins and CEOs can create projects; only
/// admins can edit, archive and delete them.
class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  late final ProjectsController _controller = ProjectsController(
    authController: context.read<AuthController>(),
    projectService: context.read<ProjectService>(),
  );

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _report(String? error, String success) {
    if (mounted) {
      context.showAppSnack(error ?? success, isError: error != null);
    }
  }

  Future<void> _create() async {
    final ProjectFormResult? form = await ProjectFormDialog.show(
      context,
      people: _controller.people,
    );
    if (form == null) {
      return;
    }
    final String? error = await _controller.create(
      title: form.title,
      description: form.description,
      memberIds: form.memberIds,
    );
    _report(error, 'Project "${form.title}" created.');
  }

  Future<void> _open(Project project) async {
    await context.pushNamed(
      AppRoute.projectDetail.name,
      pathParameters: <String, String>{'projectId': '${project.id}'},
    );
    await _controller.load();
  }

  Future<void> _onAction(Project project, ProjectAction action) async {
    switch (action) {
      case ProjectAction.edit:
        final List<int> members = await _controller.memberIdsOf(project);
        if (!mounted) {
          return;
        }
        final ProjectFormResult? form = await ProjectFormDialog.show(
          context,
          people: _controller.people,
          project: project,
          initialMemberIds: members,
        );
        if (form == null) {
          return;
        }
        _report(
          await _controller.update(
            project,
            title: form.title,
            description: form.description,
            memberIds: form.memberIds,
          ),
          'Project saved.',
        );
      case ProjectAction.archive:
      case ProjectAction.restore:
        final bool archive = action == ProjectAction.archive;
        _report(
          await _controller.setArchived(project, archive),
          archive ? 'Project archived.' : 'Project restored.',
        );
      case ProjectAction.delete:
        final bool confirmed = await context.confirm(
          title: 'Delete project',
          message:
              'Permanently delete "${project.title}" and all '
              '${project.taskCount} of its tasks? This cannot be undone.',
          confirmLabel: 'Delete',
          destructive: true,
        );
        if (confirmed) {
          _report(await _controller.delete(project), 'Project deleted.');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Projects'),
            actions: <Widget>[
              if (_controller.canManage)
                IconButton(
                  tooltip: _controller.showArchived
                      ? 'Hide archived'
                      : 'Show archived',
                  isSelected: _controller.showArchived,
                  onPressed: () =>
                      _controller.setShowArchived(!_controller.showArchived),
                  icon: const Icon(Icons.inventory_2_outlined),
                  selectedIcon: const Icon(Icons.inventory_2),
                ),
            ],
          ),
          floatingActionButton: _controller.canCreate
              ? FloatingActionButton.extended(
                  onPressed: _create,
                  icon: const Icon(Icons.add),
                  label: const Text('New project'),
                )
              : null,
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    final List<Project> projects = _controller.projects;

    if (_controller.hasError && projects.isEmpty) {
      return ErrorView(
        message: _controller.errorMessage!,
        onRetry: _controller.load,
      );
    }
    if (projects.isEmpty) {
      return _controller.isLoading
          ? const LoadingView()
          : EmptyView(
              icon: Icons.folder_off_outlined,
              title: 'No projects yet',
              message: _controller.canCreate
                  ? 'Create the first project to start assigning tasks.'
                  : 'Projects you are assigned to will appear here.',
            );
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int columns = (constraints.maxWidth / 420).floor().clamp(1, 3);
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 210,
            ),
            itemCount: projects.length,
            itemBuilder: (BuildContext context, int index) {
              final Project project = projects[index];
              return ProjectCard(
                project: project,
                onTap: () => _open(project),
                menu: _controller.canManage ? _menu(project) : null,
              );
            },
          );
        },
      ),
    );
  }

  Widget _menu(Project project) {
    return PopupMenuButton<ProjectAction>(
      tooltip: 'Project actions',
      onSelected: (ProjectAction action) => _onAction(project, action),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ProjectAction>>[
        const PopupMenuItem<ProjectAction>(
          value: ProjectAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
          ),
        ),
        PopupMenuItem<ProjectAction>(
          value: project.isArchived
              ? ProjectAction.restore
              : ProjectAction.archive,
          child: ListTile(
            leading: Icon(
              project.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
            title: Text(project.isArchived ? 'Restore' : 'Archive'),
          ),
        ),
        const PopupMenuItem<ProjectAction>(
          value: ProjectAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
          ),
        ),
      ],
    );
  }
}
