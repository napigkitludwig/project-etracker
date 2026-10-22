import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/models/user.dart';
import '../../models/project.dart';

/// What the project form returns.
class ProjectFormResult {
  const ProjectFormResult({
    required this.title,
    required this.description,
    required this.memberIds,
  });

  final String title;
  final String description;
  final Set<int> memberIds;
}

/// Create / edit dialog for a project: title, description and the people
/// assigned to it.
class ProjectFormDialog extends StatefulWidget {
  const ProjectFormDialog({
    super.key,
    required this.people,
    this.project,
    this.initialMemberIds = const <int>[],
  });

  /// Shows the dialog; resolves to `null` when cancelled.
  static Future<ProjectFormResult?> show(
    BuildContext context, {
    required List<User> people,
    Project? project,
    List<int> initialMemberIds = const <int>[],
  }) {
    return showDialog<ProjectFormResult>(
      context: context,
      builder: (BuildContext context) => ProjectFormDialog(
        people: people,
        project: project,
        initialMemberIds: initialMemberIds,
      ),
    );
  }

  final List<User> people;
  final Project? project;
  final List<int> initialMemberIds;

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(
    text: widget.project?.title,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.project?.description,
  );
  late final Set<int> _members = widget.initialMemberIds.toSet();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Admins and CEOs see every project anyway; membership matters for the
    // project managers and assignees.
    final List<User> assignable = widget.people
        .where((User user) => !user.role.canViewAllProjects)
        .toList();

    return AlertDialog(
      title: Text(widget.project == null ? 'New project' : 'Edit project'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppTextField(
                  controller: _title,
                  label: 'Title',
                  icon: Icons.folder_outlined,
                  autofocus: widget.project == null,
                  validator: (String? value) =>
                      Validators.requiredField(value, field: 'Title'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Assigned people',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Project managers and assignees only see the projects they '
                  'are assigned to. Anyone given a task is added '
                  'automatically.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                if (assignable.isEmpty)
                  Text(
                    'No accounts to assign yet.',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final User user in assignable)
                        FilterChip(
                          label: Text('${user.username} · ${user.role.label}'),
                          selected: _members.contains(user.id),
                          onSelected: (bool selected) => setState(() {
                            selected
                                ? _members.add(user.id!)
                                : _members.remove(user.id);
                          }),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(
                ProjectFormResult(
                  title: _title.text.trim(),
                  description: _description.text.trim(),
                  memberIds: _members,
                ),
              );
            }
          },
          child: Text(widget.project == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
