import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/task_status.dart';

/// Status → colour / icon mapping shared by every task widget.
extension TaskStatusStyle on TaskStatus {
  /// The status hue (see `AppColors.status*`).
  Color get color => switch (this) {
    TaskStatus.todo => AppColors.statusTodo,
    TaskStatus.acknowledged => AppColors.statusAcknowledged,
    TaskStatus.inProgress => AppColors.statusInProgress,
    TaskStatus.blocked => AppColors.statusBlocked,
    TaskStatus.workingWithSupport => AppColors.statusSupport,
    TaskStatus.internalReview => AppColors.statusInternalReview,
    TaskStatus.clientReview => AppColors.statusClientReview,
    TaskStatus.finalReview => AppColors.statusFinalReview,
    TaskStatus.done => AppColors.statusDone,
    TaskStatus.handover => AppColors.statusHandover,
    TaskStatus.closed => AppColors.statusClosed,
    TaskStatus.cancelled => AppColors.statusCancelled,
  };

  /// A representative icon.
  IconData get icon => switch (this) {
    TaskStatus.todo => Icons.radio_button_unchecked,
    TaskStatus.acknowledged => Icons.thumb_up_alt_outlined,
    TaskStatus.inProgress => Icons.timelapse,
    TaskStatus.blocked => Icons.block,
    TaskStatus.workingWithSupport => Icons.support_agent,
    TaskStatus.internalReview => Icons.rate_review_outlined,
    TaskStatus.clientReview => Icons.groups_outlined,
    TaskStatus.finalReview => Icons.workspace_premium_outlined,
    TaskStatus.done => Icons.check_circle_outline,
    TaskStatus.handover => Icons.swap_horiz,
    TaskStatus.closed => Icons.lock_outline,
    TaskStatus.cancelled => Icons.cancel_outlined,
  };
}

/// Small pill rendering a [TaskStatus]: a tinted background with a coloured
/// dot, readable in both light and dark mode.
class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.status, this.compact = false});

  final TaskStatus status;

  /// Tighter padding and smaller text for dense rows.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = status.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(status.icon, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style:
                (compact
                        ? theme.textTheme.labelSmall
                        : theme.textTheme.labelMedium)
                    ?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
          ),
        ],
      ),
    );
  }
}
