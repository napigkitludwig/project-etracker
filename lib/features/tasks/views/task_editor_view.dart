import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user.dart';
import '../controllers/task_editor_controller.dart';
import '../models/task.dart';
import '../services/task_service.dart';

/// Create / edit form for a task's planning fields (SRD §4.2): title,
/// description, assignee, due date/time, dependency, time block and hand-off.
///
/// Status and recorded time are deliberately absent — they only change through
/// the workflow and time tracking on the detail screen.
class TaskEditorView extends StatefulWidget {
  const TaskEditorView({super.key, this.projectId, this.taskId})
    : assert(projectId != null || taskId != null);

  /// Project to create the task in.
  final int? projectId;

  /// Task to edit.
  final int? taskId;

  @override
  State<TaskEditorView> createState() => _TaskEditorViewState();
}

class _TaskEditorViewState extends State<TaskEditorView> {
  late final TaskEditorController _controller = TaskEditorController(
    authController: context.read<AuthController>(),
    taskService: context.read<TaskService>(),
    projectId: widget.projectId,
    taskId: widget.taskId,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _timeBlock = TextEditingController();

  int? _assignedTo;
  int? _handoffTo;
  int? _dependencyId;
  DateTime? _dueAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.load();
    final Task? task = _controller.original;
    if (task == null || !mounted) {
      return;
    }
    setState(() {
      _title.text = task.title;
      _description.text = task.description;
      _timeBlock.text = task.timeBlockMinutes?.toString() ?? '';
      _assignedTo = task.assignedTo;
      _handoffTo = task.handoffTo;
      _dependencyId = task.dependencyId;
      _dueAt = task.dueAt;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _title.dispose();
    _description.dispose();
    _timeBlock.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final DateTime now = DateTime.now();
    final DateTime initial = _dueAt ?? now.add(const Duration(days: 1));
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) {
      return;
    }
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _dueAt ?? DateTime(now.year, now.month, now.day, 17),
      ),
    );
    setState(() {
      _dueAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 17,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final int? projectId = _controller.resolvedProjectId;
    if (projectId == null) {
      return;
    }
    final String rawBlock = _timeBlock.text.trim();
    final Task draft =
        (_controller.original ??
                Task(
                  projectId: projectId,
                  title: '',
                  createdAt: DateTime.now(),
                ))
            .copyWith(
              title: _title.text,
              description: _description.text,
              assignedTo: _assignedTo,
              handoffTo: _handoffTo,
              dependencyId: _dependencyId,
              dueAt: _dueAt,
              timeBlockMinutes: rawBlock.isEmpty
                  ? null
                  : int.tryParse(rawBlock),
            );

    final int? id = await _controller.save(draft);
    if (!mounted) {
      return;
    }
    if (id == null) {
      context.showAppSnack(
        _controller.errorMessage ?? 'Could not save the task.',
        isError: true,
      );
      return;
    }
    context.showAppSnack(
      _controller.isEditing ? 'Task saved.' : 'Task created.',
    );
    context.pop(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'New task' : 'Edit task'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (BuildContext context, Widget? _) {
          if (!_controller.isReady) {
            return _controller.hasError
                ? ErrorView(message: _controller.errorMessage!, onRetry: _load)
                : const LoadingView();
          }
          return _buildForm(context);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<User> people = _controller.people;
    final List<Task> candidates = _controller.dependencyCandidates;

    DropdownMenuItem<int?> none(String label) =>
        DropdownMenuItem<int?>(child: Text(label));
    List<DropdownMenuItem<int?>> peopleItems(String emptyLabel) =>
        <DropdownMenuItem<int?>>[
          none(emptyLabel),
          for (final User user in people)
            DropdownMenuItem<int?>(
              value: user.id,
              child: Text('${user.username} · ${user.role.label}'),
            ),
        ];

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              AppTextField(
                controller: _title,
                label: 'Task title',
                icon: Icons.title,
                autofocus: widget.taskId == null,
                validator: (String? value) =>
                    Validators.requiredField(value, field: 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Specifications, links or acceptance criteria',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _assignedTo,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Assign to',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: peopleItems('Unassigned'),
                onChanged: (int? value) => setState(() => _assignedTo = value),
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDue,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Due date / time',
                    prefixIcon: const Icon(Icons.event_outlined),
                    suffixIcon: _dueAt == null
                        ? null
                        : IconButton(
                            tooltip: 'Clear due date',
                            onPressed: () => setState(() => _dueAt = null),
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                  child: Text(_dueAt?.shortDateTime ?? 'No due date'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeBlock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Time block (minutes)',
                  helperText: 'Scheduled time allocated to this task.',
                  prefixIcon: Icon(Icons.schedule),
                ),
                validator: (String? value) {
                  final String raw = (value ?? '').trim();
                  if (raw.isEmpty) {
                    return null;
                  }
                  final int? minutes = int.tryParse(raw);
                  return minutes == null || minutes < 0
                      ? 'Enter a whole number of minutes.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: candidates.any((Task t) => t.id == _dependencyId)
                    ? _dependencyId
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Dependency',
                  helperText: 'Prerequisite that must be completed first.',
                  prefixIcon: Icon(Icons.link),
                ),
                items: <DropdownMenuItem<int?>>[
                  none('No dependency'),
                  for (final Task task in candidates)
                    DropdownMenuItem<int?>(
                      value: task.id,
                      child: Text(
                        '${task.title} · ${task.status.label}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (int? value) =>
                    setState(() => _dependencyId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _handoffTo,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Hand-off recipient',
                  helperText: 'Who receives the task on handover.',
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                items: peopleItems('Not set'),
                onChanged: (int? value) => setState(() => _handoffTo = value),
              ),
              const SizedBox(height: 24),
              if (_controller.hasError) ...<Widget>[
                AppInlineError(message: _controller.errorMessage!),
                const SizedBox(height: 12),
              ],
              AppButton(
                label: widget.taskId == null ? 'Create task' : 'Save changes',
                icon: Icons.check,
                isLoading: _controller.isLoading,
                onPressed: _save,
              ),
              const SizedBox(height: 8),
              Text(
                'New tasks start in "To Do". Status changes follow the '
                'workflow from the task page.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
