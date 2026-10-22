import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../../auth/views/widgets/role_badge.dart';
import '../../projects/models/project.dart';
import '../../projects/services/project_service.dart';
import '../../projects/views/widgets/project_card.dart';
import '../../tasks/models/task.dart';
import '../../tasks/models/task_status.dart';
import '../../tasks/services/task_service.dart';
import '../../tasks/views/widgets/task_card.dart';
import '../../tasks/views/widgets/task_status_chip.dart';
import '../controllers/home_controller.dart';
import '../models/dashboard_summary.dart';

/// Dashboard: headline counters, what is waiting on the signed-in user (by
/// role), upcoming deadlines, project progress and the status breakdown.
///
/// Every value comes from [HomeController]; the view never touches SQLite.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeController _controller = HomeController(
    authController: context.read<AuthController>(),
    projectService: context.read<ProjectService>(),
    taskService: context.read<TaskService>(),
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

  Future<void> _signOut() async {
    final bool confirmed = await context.confirm(
      title: 'Sign out',
      message: 'End your session on this device?',
      confirmLabel: 'Sign out',
    );
    if (confirmed) {
      await _controller.signOut();
    }
  }

  Future<void> _openTask(Task task) async {
    await context.pushNamed(
      AppRoute.taskDetail.name,
      pathParameters: <String, String>{'taskId': '${task.id}'},
    );
    await _controller.load();
  }

  Future<void> _openProject(Project project) async {
    await context.pushNamed(
      AppRoute.projectDetail.name,
      pathParameters: <String, String>{'projectId': '${project.id}'},
    );
    await _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (BuildContext context, Widget? _) {
          final User? user = _controller.currentUser;

          // The session disappeared (e.g. signed out from the settings screen).
          if (user == null) {
            return const EmptyView(
              icon: Icons.lock_clock_outlined,
              title: 'Your session has ended',
              message: 'Please sign in again to continue.',
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.load,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 1000;
                final Widget attention = _buildAttention();
                final Widget upcoming = _buildUpcoming();
                final Widget projects = _buildProjects();
                final Widget breakdown = _StatusBreakdown(
                  summary: _controller.summary,
                );

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    if (_controller.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(),
                      ),
                    if (_controller.hasError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppInlineError(
                          message: _controller.errorMessage!,
                        ),
                      ),
                    _Greeting(user: user),
                    const SizedBox(height: 20),
                    _StatGrid(summary: _controller.summary),
                    const SizedBox(height: 20),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: <Widget>[
                                attention,
                                const SizedBox(height: 16),
                                projects,
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: <Widget>[
                                upcoming,
                                const SizedBox(height: 16),
                                breakdown,
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...<Widget>[
                      attention,
                      const SizedBox(height: 16),
                      upcoming,
                      const SizedBox(height: 16),
                      projects,
                      const SizedBox(height: 16),
                      breakdown,
                    ],
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttention() {
    final List<Task> tasks = _controller.needsAttention;
    return _Panel(
      title: 'Needs your attention',
      subtitle: _controller.attentionHint,
      action: TextButton(
        onPressed: () => context.goNamed(AppRoute.tasks.name),
        child: const Text('All tasks'),
      ),
      child: tasks.isEmpty
          ? const _PanelEmpty(
              icon: Icons.celebration_outlined,
              message: 'Nothing is waiting on you right now.',
            )
          : Column(
              children: <Widget>[
                for (final Task task in tasks.take(6))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskCard(
                      task: task,
                      showProject: true,
                      onTap: () => _openTask(task),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildUpcoming() {
    final ThemeData theme = Theme.of(context);
    final List<Task> tasks = _controller.upcoming;
    final DateTime now = DateTime.now();

    return _Panel(
      title: 'Due this week',
      child: tasks.isEmpty
          ? const _PanelEmpty(
              icon: Icons.event_available_outlined,
              message: 'No deadlines in the next 7 days.',
            )
          : Column(
              children: <Widget>[
                for (final Task task in tasks.take(8))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _openTask(task),
                    leading: Icon(task.status.icon, color: task.status.color),
                    title: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(task.assigneeName ?? 'Unassigned'),
                    trailing: Text(
                      task.isOverdue(now)
                          ? 'Overdue'
                          : task.dueAt!.isSameDay(now)
                          ? 'Today ${task.dueAt!.shortTime}'
                          : task.dueAt!.compactDate,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: task.isOverdue(now)
                            ? AppSemanticColors.of(context).danger
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildProjects() {
    final List<Project> projects = _controller.projects;
    return _Panel(
      title: 'Projects',
      action: TextButton(
        onPressed: () => context.goNamed(AppRoute.projects.name),
        child: const Text('View all'),
      ),
      child: projects.isEmpty
          ? const _PanelEmpty(
              icon: Icons.folder_off_outlined,
              message: 'You are not assigned to any project yet.',
            )
          : Column(
              children: <Widget>[
                for (final Project project in projects.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ProjectCard(
                      project: project,
                      onTap: () => _openProject(project),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int hour = DateTime.now().hour;
    final String salutation = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$salutation, ${user.username}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Here's where your projects stand today · "
              '${DateTime.now().shortDate}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        RoleBadge(role: user.role),
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppSemanticColors semantic = AppSemanticColors.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final List<Widget> cards = <Widget>[
      _StatCard(
        label: 'Open tasks',
        value: summary.openTasks,
        icon: Icons.pending_actions_outlined,
        color: scheme.tertiary,
        caption: '${summary.totalTasks} in total',
      ),
      _StatCard(
        label: 'Assigned to me',
        value: summary.myOpenTasks,
        icon: Icons.person_pin_outlined,
        color: scheme.secondary,
        caption: 'still open',
      ),
      _StatCard(
        label: 'In review',
        value: summary.inReviewTasks,
        icon: Icons.rate_review_outlined,
        color: semantic.warning,
        caption: 'internal · client · final',
      ),
      _StatCard(
        label: 'Overdue',
        value: summary.overdueTasks,
        icon: Icons.warning_amber_rounded,
        color: semantic.danger,
        caption: '${summary.completedTasks} completed',
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 420
            ? 2
            : 1;
        const double gap = 12;
        final double width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final Widget card in cards)
              SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.caption,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$value',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stacked bar + legend showing how the visible tasks spread over statuses.
class _StatusBreakdown extends StatelessWidget {
  const _StatusBreakdown({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<MapEntry<TaskStatus, int>> entries = <MapEntry<TaskStatus, int>>[
      for (final TaskStatus status in TaskStatus.values)
        if ((summary.byStatus[status] ?? 0) > 0)
          MapEntry<TaskStatus, int>(status, summary.byStatus[status]!),
    ];

    return _Panel(
      title: 'Status overview',
      child: entries.isEmpty
          ? const _PanelEmpty(
              icon: Icons.bar_chart_outlined,
              message: 'No tasks yet.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      // A childless ColoredBox sizes to its smallest
                      // constraint, so the segments must be stretched.
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final MapEntry<TaskStatus, int> entry in entries)
                          Expanded(
                            flex: entry.value,
                            child: ColoredBox(color: entry.key.color),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final MapEntry<TaskStatus, int> entry in entries)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: entry.key.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${entry.key.label} ${entry.value}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _PanelEmpty extends StatelessWidget {
  const _PanelEmpty({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
