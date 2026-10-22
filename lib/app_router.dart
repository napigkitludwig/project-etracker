import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_colors.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/views/forgot_password_view.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/home/views/home_view.dart';
import 'features/projects/views/project_detail_view.dart';
import 'features/projects/views/projects_view.dart';
import 'features/settings/views/settings_view.dart';
import 'features/tasks/views/task_detail_view.dart';
import 'features/tasks/views/task_editor_view.dart';
import 'features/tasks/views/tasks_view.dart';
import 'features/team/views/team_view.dart';
import 'shared/widgets/app_shell.dart';
import 'shared/widgets/state_views.dart';

/// Every route in the application, in one place.
///
/// Always navigate with these constants rather than raw strings:
/// `context.goNamed(AppRoute.home.name)`, or with path parameters
/// `context.pushNamed(AppRoute.taskDetail.name, pathParameters: {'taskId': '3'})`.
enum AppRoute {
  login('/login', 'login'),
  register('/register', 'register'),
  forgotPassword('/forgot-password', 'forgot-password'),
  home('/home', 'home'),
  projects('/projects', 'projects'),
  projectDetail('/projects/:projectId', 'project-detail'),
  taskCreate('/projects/:projectId/tasks/new', 'task-create'),
  tasks('/tasks', 'tasks'),
  taskDetail('/tasks/:taskId', 'task-detail'),
  taskEdit('/tasks/:taskId/edit', 'task-edit'),
  team('/team', 'team'),
  settings('/settings', 'settings');

  const AppRoute(this.path, this.name);

  /// URL path (may contain `:parameters`).
  final String path;

  /// Named-route identifier.
  final String name;

  /// Routes reachable without a session.
  static const Set<AppRoute> public = <AppRoute>{
    AppRoute.login,
    AppRoute.register,
    AppRoute.forgotPassword,
  };

  /// Whether this route can be visited while signed out.
  bool get isPublic => public.contains(this);
}

/// Builds the app's [GoRouter].
///
/// The router owns the **authentication guard**: it rebuilds whenever
/// [AuthController] changes and redirects accordingly, so no screen ever has to
/// check `isAuthenticated` before navigating. It also owns the **role guard**
/// for admin-only screens.
///
/// Signed-in screens live inside a [ShellRoute] rendering [AppShell] (sidebar
/// on desktop, bottom bar on phones); detail pages are pushed inside the same
/// shell so the navigation stays visible.
///
/// Controllers are *not* injected through route builders — they come from the
/// `provider` scope created in `app.dart`, which keeps deep links and
/// restore-deep-links working after a cold start.
///
/// This file lives at the top of `lib/` (next to `app.dart`) rather than inside
/// `core/`, because mapping URLs to screens is a composition concern: it is the
/// one place allowed to name feature views. Keeping it here is what lets `core/`
/// stay free of `features/` imports.
class AppRouter {
  const AppRouter({required this.authController});

  /// Session controller driving the guard.
  final AuthController authController;

  /// Creates the configured [GoRouter].
  GoRouter create() {
    return GoRouter(
      initialLocation: AppRoute.login.path,
      refreshListenable: authController,
      redirect: _redirect,
      routes: <RouteBase>[
        _route(AppRoute.login, (_) => const LoginView()),
        _route(AppRoute.register, (_) => const RegisterView()),
        _route(AppRoute.forgotPassword, (_) => const ForgotPasswordView()),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) =>
              AppShell(
                brandName: AppBrand.current.displayName,
                destinations: _destinations(),
                location: state.uri.path,
                onSelect: (ShellDestination destination) =>
                    context.go(destination.path),
                child: child,
              ),
          routes: <RouteBase>[
            _route(AppRoute.home, (_) => const HomeView()),
            _route(AppRoute.projects, (_) => const ProjectsView()),
            _route(
              AppRoute.projectDetail,
              (GoRouterState state) => _withId(
                state,
                'projectId',
                (int id) =>
                    ProjectDetailView(key: ValueKey<int>(id), projectId: id),
              ),
            ),
            _route(
              AppRoute.taskCreate,
              (GoRouterState state) => _withId(
                state,
                'projectId',
                (int id) => TaskEditorView(projectId: id),
              ),
            ),
            _route(AppRoute.tasks, (_) => const TasksView()),
            _route(
              AppRoute.taskDetail,
              (GoRouterState state) => _withId(
                state,
                'taskId',
                (int id) => TaskDetailView(key: ValueKey<int>(id), taskId: id),
              ),
            ),
            _route(
              AppRoute.taskEdit,
              (GoRouterState state) => _withId(
                state,
                'taskId',
                (int id) => TaskEditorView(taskId: id),
              ),
            ),
            _route(AppRoute.team, (_) => const TeamView()),
            _route(AppRoute.settings, (_) => const SettingsView()),
          ],
        ),
      ],
      errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(child: Text('No route matches "${state.uri}".')),
      ),
    );
  }

  /// Primary navigation for the signed-in user's role.
  List<ShellDestination> _destinations() => <ShellDestination>[
    ShellDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      path: AppRoute.home.path,
    ),
    ShellDestination(
      label: 'Projects',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      path: AppRoute.projects.path,
    ),
    ShellDestination(
      label: 'Tasks',
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt,
      path: AppRoute.tasks.path,
    ),
    if (authController.currentUser?.role.canManageUsers ?? false)
      ShellDestination(
        label: 'Team',
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups,
        path: AppRoute.team.path,
      ),
    ShellDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      path: AppRoute.settings.path,
    ),
  ];

  GoRoute _route(AppRoute route, Widget Function(GoRouterState state) build) {
    return GoRoute(
      path: route.path,
      name: route.name,
      builder: (BuildContext context, GoRouterState state) => build(state),
    );
  }

  /// Parses an integer path parameter, rendering a friendly error otherwise.
  static Widget _withId(
    GoRouterState state,
    String parameter,
    Widget Function(int id) build,
  ) {
    final int? id = int.tryParse(state.pathParameters[parameter] ?? '');
    if (id == null) {
      return const Scaffold(
        body: EmptyView(
          icon: Icons.link_off,
          title: 'Not found',
          message: 'This link does not point to a valid item.',
        ),
      );
    }
    return build(id);
  }

  /// Guard: signed-out users only see [AppRoute.public]; signed-in users are
  /// pushed away from the auth screens, and non-admins away from `/team`.
  String? _redirect(BuildContext context, GoRouterState state) {
    final String location = state.matchedLocation;
    final AppRoute? target = _match(location);
    final bool isPublic = target?.isPublic ?? false;
    final bool isAuthenticated = authController.isAuthenticated;

    if (!isAuthenticated) {
      return isPublic ? null : AppRoute.login.path;
    }

    if (isPublic) {
      return AppRoute.home.path;
    }

    if (target == AppRoute.team &&
        !(authController.currentUser?.role.canManageUsers ?? false)) {
      return AppRoute.home.path;
    }

    return null;
  }

  /// Matches static paths only; parameterised routes are never public.
  AppRoute? _match(String location) {
    for (final AppRoute route in AppRoute.values) {
      if (location == route.path) {
        return route;
      }
    }
    return null;
  }
}
