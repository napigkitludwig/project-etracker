import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/task_board_controller.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'widgets/task_collection.dart';

/// Every task the user can see across projects, defaulting to the ones
/// assigned to them, as a list or a Kanban board.
class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  late final AuthController _auth = context.read<AuthController>();
  late final TaskBoardController _controller = TaskBoardController(
    authController: _auth,
    taskService: context.read<TaskService>(),
    // Assignees mostly care about their own work; managers about everything.
    assignedToMe: !(_auth.currentUser?.role.canManageTasks ?? false),
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

  Future<void> _open(Task task) => context.pushNamed(
    AppRoute.taskDetail.name,
    pathParameters: <String, String>{'taskId': '${task.id}'},
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: _controller.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: TaskCollection(
        controller: _controller,
        showProject: true,
        onOpenTask: _open,
        header: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (BuildContext context, Widget? _) => SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Assigned to me'),
                  icon: Icon(Icons.person_outline),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('All my projects'),
                  icon: Icon(Icons.folder_open_outlined),
                ),
              ],
              selected: <bool>{_controller.assignedToMe},
              onSelectionChanged: (Set<bool> selection) =>
                  _controller.setAssignedToMe(selection.first),
            ),
          ),
        ),
      ),
    );
  }
}
