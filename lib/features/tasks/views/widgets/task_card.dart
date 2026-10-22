import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../models/task.dart';
import 'task_status_chip.dart';

/// One task, as a card: title, status, assignee, due date and tracked time.
///
/// Used by the list view, the Kanban board and the dashboard.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.showProject = false,
    this.showStatus = true,
    this.trailing,
  });

  final Task task;
  final VoidCallback? onTap;

  /// Shows the parent project's title (cross-project lists).
  final bool showProject;

  /// Hides the status pill (the Kanban column already says it).
  final bool showStatus;

  /// Optional widget at the end of the title row.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic = AppSemanticColors.of(context);
    final DateTime now = DateTime.now();
    final bool overdue = task.isOverdue(now);
    final TextStyle? meta = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: task.status.color, width: 3),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (showProject && task.projectTitle != null) ...<Widget>[
                Text(
                  task.projectTitle!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.status.isTerminal
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  if (showStatus)
                    TaskStatusChip(status: task.status, compact: true),
                  _Meta(
                    icon: Icons.person_outline,
                    label: task.assigneeName ?? 'Unassigned',
                    style: meta,
                  ),
                  if (task.dueAt != null)
                    _Meta(
                      icon: overdue ? Icons.warning_amber_rounded : Icons.event,
                      label: overdue
                          ? 'Overdue · ${task.dueAt!.compactDate}'
                          : task.dueAt!.compactDate,
                      style: overdue
                          ? meta?.copyWith(
                              color: semantic.danger,
                              fontWeight: FontWeight.w600,
                            )
                          : meta,
                    ),
                  if (task.timeBlockMinutes != null || task.durationMinutes > 0)
                    _Meta(
                      icon: Icons.schedule,
                      label: task.timeBlockMinutes == null
                          ? task.trackedMinutes(now).asDuration
                          : '${task.trackedMinutes(now).asDuration} / '
                                '${task.timeBlockMinutes!.asDuration}',
                      style: meta,
                    ),
                  // Only relevant before work begins (the start guard).
                  if (!task.isDependencySatisfied && task.startedAt == null)
                    _Meta(
                      icon: Icons.link,
                      label: 'Waiting on dependency',
                      style: meta?.copyWith(color: semantic.warning),
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

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, this.style});

  final IconData icon;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: style?.color),
        const SizedBox(width: 4),
        Text(label, style: style),
      ],
    );
  }
}
