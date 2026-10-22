import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/user_role.dart';

/// Small colour-coded pill that renders a [UserRole].
///
/// Lives in the auth feature because it is the auth feature that owns the role
/// concept; the other screens reuse it rather than duplicating the role →
/// colour mapping.
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role, this.compact = false});

  /// Role to display.
  final UserRole role;

  /// Renders a tighter pill without the icon.
  final bool compact;

  /// The icon that represents [role].
  static IconData iconDataFor(UserRole role) => switch (role) {
    UserRole.admin => Icons.shield_outlined,
    UserRole.ceo => Icons.workspace_premium_outlined,
    UserRole.projectManager => Icons.assignment_ind_outlined,
    UserRole.assignee => Icons.person_outline,
  };

  /// The accent colour for [role].
  static Color colorFor(UserRole role) => switch (role) {
    UserRole.admin => AppColors.statusBlocked,
    UserRole.ceo => AppColors.statusFinalReview,
    UserRole.projectManager => AppColors.accentBlue,
    UserRole.assignee => AppColors.steelBlue,
  };

  /// [role]'s icon in its accent colour (for chips and avatars).
  static Widget iconFor(UserRole role, {double size = 16}) =>
      Icon(iconDataFor(role), size: size, color: colorFor(role));

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = colorFor(role);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!compact) ...<Widget>[
            Icon(iconDataFor(role), size: 16, color: accent),
            const SizedBox(width: 6),
          ],
          Text(
            role.label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
