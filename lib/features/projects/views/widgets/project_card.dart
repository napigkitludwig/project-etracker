import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../models/project.dart';

/// A project with its progress bar and task counters.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap, this.menu});

  final Project project;
  final VoidCallback? onTap;

  /// Optional overflow menu (admin actions).
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors semantic = AppSemanticColors.of(context);
    final TextStyle? meta = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.title.initials,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                project.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (project.isArchived) ...<Widget>[
                              const SizedBox(width: 8),
                              Chip(
                                visualDensity: VisualDensity.compact,
                                label: const Text('Archived'),
                                labelStyle: theme.textTheme.labelSmall,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'by ${project.creatorName ?? 'unknown'} · '
                          '${project.createdAt.compactDate}',
                          style: meta,
                        ),
                      ],
                    ),
                  ),
                  ?menu,
                ],
              ),
              if (project.description.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: project.progress,
                  color: project.progress >= 1 ? semantic.success : null,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Text(
                    '${(project.progress * 100).round()}% complete',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${project.openTaskCount} open · '
                    '${project.completedTaskCount}/${project.taskCount} done',
                    style: meta,
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
