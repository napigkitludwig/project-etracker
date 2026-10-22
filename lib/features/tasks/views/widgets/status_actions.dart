import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../services/task_workflow.dart';
import 'task_status_chip.dart';

/// Dialogs and sheets used to move a task through the workflow.
class StatusActions {
  const StatusActions._();

  /// Lets the user pick one of [transitions] for [task].
  ///
  /// Regular moves come first; admin overrides are listed separately. Moves
  /// that are currently impossible are shown disabled with their reason.
  static Future<TaskTransition?> pick(
    BuildContext context, {
    required Task task,
    required List<TaskTransition> transitions,
  }) {
    final List<TaskTransition> regular = transitions
        .where((TaskTransition t) => !t.isOverride)
        .toList();
    final List<TaskTransition> overrides = transitions
        .where((TaskTransition t) => t.isOverride)
        .toList();

    return showModalBottomSheet<TaskTransition>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);

        Widget tile(TaskTransition transition) => ListTile(
          enabled: transition.isEnabled,
          leading: Icon(transition.to.icon, color: transition.to.color),
          title: Text(transition.label),
          subtitle: Text(
            transition.blockedReason ?? 'Move to ${transition.to.label}',
          ),
          trailing: transition.requiresNote
              ? const Icon(Icons.edit_note, size: 20)
              : null,
          onTap: () => Navigator.of(sheetContext).pop(transition),
        );

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 16),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Update status',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TaskStatusChip(status: task.status, compact: true),
                    ],
                  ),
                ),
                if (regular.isEmpty)
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('No actions available'),
                    subtitle: Text(
                      'Your role cannot move this task from its current '
                      'status.',
                    ),
                  )
                else
                  ...regular.map(tile),
                if (overrides.isNotEmpty) ...<Widget>[
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Text(
                      'ADMIN OVERRIDE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  ...overrides.map(tile),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Asks for the note a [transition] needs (or allows). Resolves to `null`
  /// when the user cancels, and to the (possibly empty) note otherwise.
  static Future<String?> askNote(
    BuildContext context,
    TaskTransition transition,
  ) async {
    final TextEditingController note = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(transition.label),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: note,
            autofocus: true,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: transition.requiresNote
                  ? 'Reason (required)'
                  : 'Note (optional)',
            ),
            validator: (String? value) =>
                transition.requiresNote && (value ?? '').trim().isEmpty
                ? 'Please explain this change.'
                : null,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            // The theme's full-width minimum would push it onto its own row.
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(note.text.trim());
              }
            },
            child: Text('Move to ${transition.to.label}'),
          ),
        ],
      ),
    );
    note.dispose();
    return result;
  }
}
