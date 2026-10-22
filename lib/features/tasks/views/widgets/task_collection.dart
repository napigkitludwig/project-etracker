import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../settings/controllers/settings_controller.dart';
import '../../controllers/task_board_controller.dart';
import '../../models/task.dart';
import '../../models/task_status.dart';
import '../../models/task_view_mode.dart';
import '../../services/task_workflow.dart';
import 'status_actions.dart';
import 'task_card.dart';
import 'task_status_chip.dart';

/// A task collection with its toolbar, rendered as a list or a Kanban board
/// depending on the persisted [TaskViewMode].
///
/// Must be given bounded height (the board scrolls in two directions).
class TaskCollection extends StatelessWidget {
  const TaskCollection({
    super.key,
    required this.controller,
    required this.onOpenTask,
    this.showProject = false,
    this.header,
    this.emptyAction,
  });

  final TaskBoardController controller;

  /// Opens a task's detail page; resolves once the user comes back.
  final Future<void> Function(Task task) onOpenTask;

  /// Shows each task's project (cross-project collections).
  final bool showProject;

  /// Extra content above the toolbar (scrolls away in list mode).
  final Widget? header;

  /// Call-to-action rendered in the empty state.
  final Widget? emptyAction;

  Future<void> _open(Task task) async {
    await onOpenTask(task);
    await controller.load();
  }

  /// Moves a card dropped on a Kanban column, asking for a note when needed.
  Future<void> _drop(BuildContext context, Task task, TaskStatus to) async {
    final TaskTransition? transition = controller.dropTransition(task, to);
    if (transition == null) {
      return;
    }
    String note = '';
    if (transition.requiresNote) {
      final String? entered = await StatusActions.askNote(context, transition);
      if (entered == null) {
        return;
      }
      note = entered;
    }
    final String? error = await controller.moveTask(task, to, note: note);
    if (context.mounted) {
      context.showAppSnack(
        error ?? '"${task.title}" moved to ${to.label}.',
        isError: error != null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TaskViewMode mode = context.select<SettingsController, TaskViewMode>(
      (SettingsController settings) => settings.taskViewMode,
    );

    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? _) {
        final Widget toolbar = _Toolbar(controller: controller, mode: mode);

        if (controller.hasError && controller.allTasks.isEmpty) {
          return ErrorView(
            message: controller.errorMessage!,
            onRetry: controller.load,
          );
        }

        if (mode == TaskViewMode.board) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ?header,
              toolbar,
              if (controller.isLoading) const LinearProgressIndicator(),
              Expanded(
                child: _Board(
                  controller: controller,
                  showProject: showProject,
                  onOpen: _open,
                  onDrop: (Task task, TaskStatus to) =>
                      _drop(context, task, to),
                ),
              ),
            ],
          );
        }

        final List<Task> tasks = controller.visibleTasks;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 96),
            children: <Widget>[
              ?header,
              toolbar,
              if (controller.isLoading) const LinearProgressIndicator(),
              if (tasks.isEmpty && !controller.isLoading)
                EmptyView(
                  icon: Icons.task_alt,
                  title: controller.allTasks.isEmpty
                      ? 'No tasks yet'
                      : 'No tasks match these filters',
                  message: controller.allTasks.isEmpty
                      ? 'Tasks you can see will appear here.'
                      : 'Try another status or search term.',
                  action: controller.allTasks.isEmpty ? emptyAction : null,
                )
              else
                for (final Task task in tasks)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: TaskCard(
                      task: task,
                      showProject: showProject,
                      onTap: () => _open(task),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// Search, view-mode toggle, "hide finished" and (list only) status filters.
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller, required this.mode});

  final TaskBoardController controller;
  final TaskViewMode mode;

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = context.read<SettingsController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextField(
                  onChanged: controller.setQuery,
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search tasks or people',
                  ),
                ),
              ),
              SegmentedButton<TaskViewMode>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<TaskViewMode>>[
                  ButtonSegment<TaskViewMode>(
                    value: TaskViewMode.list,
                    label: Text('List'),
                    icon: Icon(Icons.view_agenda_outlined),
                  ),
                  ButtonSegment<TaskViewMode>(
                    value: TaskViewMode.board,
                    label: Text('Board'),
                    icon: Icon(Icons.view_kanban_outlined),
                  ),
                ],
                selected: <TaskViewMode>{mode},
                onSelectionChanged: (Set<TaskViewMode> selection) =>
                    settings.setTaskViewMode(selection.first),
              ),
              FilterChip(
                label: const Text('Hide closed & cancelled'),
                selected: controller.hideFinished,
                onSelected: controller.setHideFinished,
              ),
            ],
          ),
          if (mode == TaskViewMode.list) ...<Widget>[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  ChoiceChip(
                    label: Text('All ${controller.allTasks.length}'),
                    selected: controller.statusFilter == null,
                    onSelected: (_) => controller.setStatusFilter(null),
                  ),
                  for (final TaskStatus status in TaskStatus.values)
                    if (controller.countFor(status) > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          avatar: Icon(
                            status.icon,
                            size: 16,
                            color: status.color,
                          ),
                          label: Text(
                            '${status.label} ${controller.countFor(status)}',
                          ),
                          selected: controller.statusFilter == status,
                          onSelected: (bool selected) => controller
                              .setStatusFilter(selected ? status : null),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kanban board: one column per status. Cards can be dragged onto any column
/// the workflow allows for the current user; the others refuse the drop.
class _Board extends StatelessWidget {
  const _Board({
    required this.controller,
    required this.showProject,
    required this.onOpen,
    required this.onDrop,
  });

  final TaskBoardController controller;
  final bool showProject;
  final Future<void> Function(Task task) onOpen;
  final Future<void> Function(Task task, TaskStatus to) onDrop;

  static const double _columnWidth = 280;

  @override
  Widget build(BuildContext context) {
    final Map<TaskStatus, List<Task>> columns = controller.columns;

    return Scrollbar(
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: <Widget>[
          for (final MapEntry<TaskStatus, List<Task>> column in columns.entries)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: _columnWidth,
                child: _BoardColumn(
                  status: column.key,
                  tasks: column.value,
                  controller: controller,
                  showProject: showProject,
                  onOpen: onOpen,
                  onDrop: onDrop,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({
    required this.status,
    required this.tasks,
    required this.controller,
    required this.showProject,
    required this.onOpen,
    required this.onDrop,
  });

  final TaskStatus status;
  final List<Task> tasks;
  final TaskBoardController controller;
  final bool showProject;
  final Future<void> Function(Task task) onOpen;
  final Future<void> Function(Task task, TaskStatus to) onDrop;

  bool get _touchFirst =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DragTarget<Task>(
      onWillAcceptWithDetails: (DragTargetDetails<Task> details) =>
          details.data.status != status &&
          controller.dropTransition(details.data, status) != null,
      onAcceptWithDetails: (DragTargetDetails<Task> details) =>
          onDrop(details.data, status),
      builder:
          (
            BuildContext context,
            List<Task?> candidates,
            List<dynamic> rejected,
          ) {
            final bool hovering = candidates.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: hovering
                    ? status.color.withValues(alpha: 0.12)
                    : theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovering
                      ? status.color
                      : rejected.isNotEmpty
                      ? theme.colorScheme.error.withValues(alpha: 0.6)
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: Row(
                      children: <Widget>[
                        Icon(status.icon, size: 16, color: status.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            status.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${tasks.length}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: tasks.isEmpty
                        ? Center(
                            child: Text(
                              hovering ? 'Drop here' : 'No tasks',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            itemCount: tasks.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (BuildContext context, int index) =>
                                _draggable(context, tasks[index]),
                          ),
                  ),
                ],
              ),
            );
          },
    );
  }

  Widget _draggable(BuildContext context, Task task) {
    final Widget card = TaskCard(
      task: task,
      showProject: showProject,
      showStatus: false,
      onTap: () => onOpen(task),
    );
    final Widget feedback = Material(
      color: Colors.transparent,
      child: SizedBox(
        width: _Board._columnWidth - 20,
        child: Opacity(opacity: 0.9, child: card),
      ),
    );
    final Widget placeholder = Opacity(opacity: 0.35, child: card);

    if (_touchFirst) {
      return LongPressDraggable<Task>(
        data: task,
        feedback: feedback,
        childWhenDragging: placeholder,
        child: card,
      );
    }
    return Draggable<Task>(
      data: task,
      feedback: feedback,
      childWhenDragging: placeholder,
      child: card,
    );
  }
}
