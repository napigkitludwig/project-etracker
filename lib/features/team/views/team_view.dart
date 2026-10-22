import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../../auth/models/user_role.dart';
import '../../auth/views/widgets/role_badge.dart';
import '../controllers/team_controller.dart';

/// Team management (Admin only): every account, its role, and the create /
/// change role / delete actions.
class TeamView extends StatefulWidget {
  const TeamView({super.key});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView> {
  late final TeamController _controller = TeamController(
    authController: context.read<AuthController>(),
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

  void _report(bool ok, String success, String fallback) {
    if (!mounted) {
      return;
    }
    context.showAppSnack(
      ok ? success : (_controller.errorMessage ?? fallback),
      isError: !ok,
    );
  }

  Future<void> _confirmDelete(User user) async {
    final bool confirmed = await context.confirm(
      title: 'Delete account',
      message:
          'Remove "${user.username}" permanently? Their tasks become '
          'unassigned.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    final bool deleted = await _controller.deleteUser(user.id!);
    _report(
      deleted,
      '"${user.username}" was deleted.',
      'Could not delete the account.',
    );
  }

  Future<void> _changeRole(User user, UserRole role) async {
    final bool changed = await _controller.changeRole(user, role);
    _report(
      changed,
      '${user.username} is now ${role.label}.',
      'Could not change the role.',
    );
  }

  Future<void> _openCreateUserDialog() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController username = TextEditingController();
    final TextEditingController password = TextEditingController();
    UserRole role = UserRole.assignee;

    final bool? submit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Create account'),
            content: SizedBox(
              width: 420,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppTextField(
                      controller: username,
                      label: 'Username',
                      icon: Icons.person_outline,
                      validator: Validators.username,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: password,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: Validators.newPassword,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserRole>(
                      initialValue: role,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: <DropdownMenuItem<UserRole>>[
                        for (final UserRole value in UserRole.values)
                          DropdownMenuItem<UserRole>(
                            value: value,
                            child: Text(value.label),
                          ),
                      ],
                      onChanged: (UserRole? value) {
                        if (value != null) {
                          setDialogState(() => role = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );

    bool created = false;
    if (submit == true) {
      created = await _controller.createUser(
        username: username.text,
        password: password.text,
        role: role,
      );
    }
    username.dispose();
    password.dispose();

    if (submit == true) {
      _report(
        created,
        'Account created successfully.',
        'Could not create the account.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      floatingActionButton: _controller.canManageUsers
          ? FloatingActionButton.extended(
              onPressed: _openCreateUserDialog,
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Add user'),
            )
          : null,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (BuildContext context, Widget? _) {
          if (!_controller.canManageUsers) {
            return const EmptyView(
              icon: Icons.lock_outline,
              title: 'Administrators only',
              message: 'Ask an administrator if you need an account changed.',
            );
          }
          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: <Widget>[
                if (_controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final UserRole role in UserRole.values)
                      Chip(
                        avatar: RoleBadge.iconFor(role, size: 16),
                        label: Text(
                          '${role.label} · ${_controller.countFor(role)}',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: <Widget>[
                      for (final User user in _controller.accounts)
                        _buildAccountTile(user),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountTile(User user) {
    final ThemeData theme = Theme.of(context);
    final bool isSelf = _controller.isCurrentUser(user.id);

    return ListTile(
      leading: CircleAvatar(child: Text(user.username.initials)),
      title: Text(user.username),
      subtitle: Text('ID #${user.id ?? '-'}', style: theme.textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RoleBadge(role: user.role, compact: true),
          const SizedBox(width: 4),
          if (isSelf)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'You',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            PopupMenuButton<Object>(
              tooltip: 'Account actions',
              onSelected: (Object value) => value is UserRole
                  ? _changeRole(user, value)
                  : _confirmDelete(user),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Object>>[
                for (final UserRole role in UserRole.values)
                  if (role != user.role)
                    PopupMenuItem<Object>(
                      value: role,
                      child: Text('Make ${role.label}'),
                    ),
                const PopupMenuDivider(),
                const PopupMenuItem<Object>(
                  value: 'delete',
                  child: Text('Delete account'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
