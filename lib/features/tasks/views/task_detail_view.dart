import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/task_detail_controller.dart';
import '../models/task.dart';
import '../models/task_history_entry.dart';
import '../services/task_service.dart';
import '../services/task_workflow.dart';
import 'widgets/status_actions.dart';
import 'widgets/task_status_chip.dart';

/// Task detail "drawer": every SRD field, the workflow actions the current
/// user may take, time tracking, notes and the status history.
class TaskDetailView extends StatefulWidget {
  const TaskDetailView({super.key, required this.taskId});

  final int taskId;

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  late final TaskDetailController _controller = TaskDetailController(
    authController: context.read<AuthController>(),
    taskService: context.read<TaskService>(),
    taskId: widget.taskId,
  );

  final TextEditingController _notes = TextEditingController();
  bool _notesDirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.load();
    if (!_notesDirty) {
      _notes.text = _controller.task?.notes ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _report(String? error, String success) {
    if (!mounted) {
      return;
    }
    context.showAppSnack(error ?? success, isError: error != null);
  }

  Future<void> _runTransition(TaskTransition transition) async {
    String note = '';
    if (transition.requiresNote || transition.to.isInReview) {
      final String? entered = await StatusActions.askNote(context, transition);
      if (entered == null) {
        return;
      }
      note = entered;
    }
    final String? error = await _controller.changeStatus(
      transition.to,
      note: note,
    );
    _report(error, 'Moved to ${transition.to.label}.');
  }

  Future<void> _openStatusSheet(Task task) async {
    final TaskTransition? picked = await StatusActions.pick(
      context,
      task: task,
      transitions: _controller.transitions,
    );
    if (picked != null && picked.isEnabled) {
      await _runTransition(picked);
    }
  }

  Future<void> _logTime() async {
    final TextEditingController minutes = TextEditingController();
    final int? value = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Log time'),
        content: TextField(
          controller: minutes,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: const InputDecoration(
            labelText: 'Minutes worked',
            helperText: 'Use a negative number to correct a mistake.',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext)
                    .pop(int.tryParse(minutes.text.trim())),
            child: const Text('Log'),
          ),
        ],
      ),
    );
    minutes.dispose();
    if (value == null) {
      return;
    }
    final String? error = await _controller.logTime(value);
    _report(error, 'Logged ${value.abs().asDuration}.');
  }

  Future<void> _saveNotes() async {
    final String? error = await _controller.saveNotes(_notes.text);
    if (error == null) {
      _notesDirty = false;
    }
    _report(error, 'Notes saved.');
  }

  Future<void> _edit(Task task) async {
    await context.pushNamed(
      AppRoute.taskEdit.name,
      pathParameters: <String, String>{'taskId': '${task.id}'},
    );
    await _load();
  }

  Future<void> _delete(Task task) async {
    final bool confirmed = await context.confirm(
      title: 'Delete task',
      message: 'Permanently delete "${task.title}" and its history?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    final String? error = await _controller.delete();
    if (!mounted) {
      return;
    }
    if (error != null) {
      context.showAppSnack(error, isError: true);
      return;
    }
    context.showAppSnack('Task deleted.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, Widget? _) {
        final Task? task = _controller.task;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task'),
            actions: <Widget>[
              if (task != null && _controller.canEditDetails)
                IconButton(
                  tooltip: 'Edit task',
                  onPressed: () => _edit(task),
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (task != null && _controller.canDelete)
                IconButton(
                  tooltip: 'Delete task',
                  onPressed: () => _delete(task),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: _buildBody(task),
        );
      },
    );
  }

  Widget _buildBody(Task? task) {
    if (task == null) {
      if (_controller.hasError) {
        return ErrorView(message: _controller.errorMessage!, onRetry: _load);
      }
      return const LoadingView();
    }

    final List<TaskTransition> transitions = _controller.transitions;
    final List<TaskTransition> primary = transitions
        .where((TaskTransition t) => !t.isOverride)
        .toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              if (_controller.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(),
                ),
              _Header(task: task),
              const SizedBox(height: 16),
              _ActionsCard(
                primary: primary,
                hasMore: transitions.length > primary.length,
                onRun: _runTransition,
                onMore: () => _openStatusSheet(task),
              ),
              const SizedBox(height: 16),
              _FieldsCard(task: task),
              const SizedBox(height: 16),
              _TimeCard(
                task: task,
                onLogTime: _controller.canWork ? _logTime : null,
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Notes',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _notes,
                      enabled: _controller.canWork,
                      minLines: 3,
                      maxLines: 8,
                      onChanged: (_) => _notesDirty = true,
                      decoration: const InputDecoration(
                        hintText: 'Progress notes, links, blockers…',
                      ),
                    ),
                    if (_controller.canWork) ...<Widget>[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: _saveNotes,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save notes'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _HistoryCard(entries: _controller.history),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (task.projectTitle != null)
          Text(
            task.projectTitle!.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.secondary,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          task.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            TaskStatusChip(status: task.status),
            const SizedBox(width: 8),
            Text('Task #${task.id}', style: theme.textTheme.bodySmall),
          ],
        ),
        if (task.description.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            task.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.primary,
    required this.hasMore,
    required this.onRun,
    required this.onMore,
  });

  final List<TaskTransition> primary;
  final bool hasMore;
  final Future<void> Function(TaskTransition transition) onRun;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _Section(
      title: 'Workflow',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (primary.isEmpty)
            Text(
              'No actions available to your role at this stage.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final TaskTransition transition in primary)
                  Tooltip(
                    message: transition.blockedReason ?? '',
                    // Forward moves are filled; moves that need a reason
                    // (block, reject, cancel) are outlined.
                    child: !transition.requiresNote
                        ? FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 44),
                            ),
                            onPressed: transition.isEnabled
                                ? () => onRun(transition)
                                : null,
                            icon: Icon(transition.to.icon, size: 18),
                            label: Text(transition.label),
                          )
                        : OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 44),
                            ),
                            onPressed: transition.isEnabled
                                ? () => onRun(transition)
                                : null,
                            icon: Icon(transition.to.icon, size: 18),
                            label: Text(transition.label),
                          ),
                  ),
              ],
            ),
          for (final TaskTransition transition in primary)
            if (transition.blockedReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppSemanticColors.of(context).warning,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        transition.blockedReason!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          if (hasMore) ...<Widget>[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onMore,
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: const Text('Admin override…'),
            ),
          ],
        ],
      ),
    );
  }
}

class _FieldsCard extends StatelessWidget {
  const _FieldsCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final bool overdue = task.isOverdue(DateTime.now());

    return _Section(
      title: 'Details',
      child: Column(
        children: <Widget>[
          _Field(
            icon: Icons.person_outline,
            label: 'Assigned to',
            value: task.assigneeName ?? 'Unassigned',
          ),
          _Field(
            icon: Icons.event_outlined,
            label: 'Due',
            value: task.dueAt?.shortDateTime ?? 'No due date',
            highlight: overdue ? AppSemanticColors.of(context).danger : null,
          ),
          _Field(
            icon: Icons.add_circle_outline,
            label: 'Created',
            value: task.createdAt.shortDateTime,
          ),
          _Field(
            icon: Icons.play_circle_outline,
            label: 'Started',
            value: task.startedAt?.shortDateTime ?? 'Not started',
          ),
          _Field(
            icon: Icons.link,
            label: 'Depends on',
            value: task.dependencyId == null
                ? 'None'
                : '${task.dependencyTitle ?? '#${task.dependencyId}'}'
                      ' · ${task.dependencyStatus?.label ?? 'unknown'}',
            highlight: task.isDependencySatisfied
                ? null
                : AppSemanticColors.of(context).warning,
          ),
          _Field(
            icon: Icons.swap_horiz,
            label: 'Hand-off to',
            value: task.handoffName ?? 'Not set',
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.task, required this.onLogTime});

  final Task task;
  final VoidCallback? onLogTime;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int tracked = task.trackedMinutes(DateTime.now());
    final int? block = task.timeBlockMinutes;
    final double? ratio = block == null || block == 0 ? null : tracked / block;
    final AppSemanticColors semantic = AppSemanticColors.of(context);

    return _Section(
      title: 'Time',
      trailing: onLogTime == null
          ? null
          : TextButton.icon(
              onPressed: onLogTime,
              icon: const Icon(Icons.more_time),
              label: const Text('Log time'),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _Stat(
                  label: 'Duration (recorded)',
                  value: tracked.asDuration,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Time block (allocated)',
                  value: block?.asDuration ?? '—',
                ),
              ),
            ],
          ),
          if (ratio != null) ...<Widget>[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: ratio.clamp(0, 1).toDouble(),
                color: ratio > 1 ? semantic.danger : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ratio > 1
                  ? 'Over the time block by ${(tracked - block!).asDuration}'
                  : '${(ratio * 100).round()}% of the time block used',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (task.inProgressSince != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Timer running since ${task.inProgressSince!.shortTime}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entries});

  final List<TaskHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _Section(
      title: 'History',
      child: entries.isEmpty
          ? Text('No activity yet.', style: theme.textTheme.bodyMedium)
          : Column(
              children: <Widget>[
                for (final TaskHistoryEntry entry in entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      entry.toStatus.icon,
                      color: entry.toStatus.color,
                    ),
                    title: Text(
                      entry.fromStatus == null
                          ? entry.toStatus.label
                          : '${entry.fromStatus!.label} → ${entry.toStatus.label}',
                    ),
                    subtitle: Text(
                      <String>[
                        '${entry.changedByName ?? 'Someone'} · '
                            '${entry.changedAt.shortDateTime}',
                        if (entry.note.isNotEmpty) entry.note,
                      ].join('\n'),
                    ),
                    trailing: entry.isOverride
                        ? Tooltip(
                            message: 'Admin override',
                            child: Icon(
                              Icons.admin_panel_settings_outlined,
                              color: AppSemanticColors.of(context).warning,
                            ),
                          )
                        : null,
                  ),
              ],
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: highlight,
                fontWeight: highlight == null ? null : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
