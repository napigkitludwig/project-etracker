# project-etracker
Project-eTracker is a streamlined project management system designed to track, manage, and monitor projects and tasks in real time. It provides teams with full visibility into progress, task assignments, and deadlines, helping to optimize workflows and boost overall productivity.

Built with Flutter (Android, iOS, desktop and web) on the FluetPress architecture:
feature-first folders, MVC controllers, SQLite persistence, go_router guards.

## Features

- **Dashboard**: open / assigned / in-review / overdue counters, a role-specific
  "Needs your attention" list, deadlines due this week, project progress and a
  status breakdown.
- **Projects**: create, edit, archive, delete, and assign members.
- **Tasks**: every field in the spec (assignee, due date/time, date started,
  dependency, time block, recorded duration, hand-off, notes) in either a
  **List** view or a **Kanban board**. On the board you drag cards between
  status columns, and a column only accepts a card when the workflow allows
  that move.
- **Workflow**: a strict 12-stage state machine with an audit trail (see below).
- **Team**: admins create accounts, change roles and delete accounts.
- **IdeaHub theme**: dark-mode native palette (near-black canvas, charcoal
  cards, off-white CTAs, steel-blue accents). Light mode is available in
  Settings.

## Roles (RBAC)

| Role            | Projects                      | Tasks                          | Review & sign-off         |
|-----------------|-------------------------------|--------------------------------|---------------------------|
| Admin           | Create, edit, archive, delete | Full access, delete, overrides | Full override             |
| CEO / Owner     | Create, view all              | Create & assign                | Final review, close       |
| Project Manager | View assigned                 | Create, assign, update         | Internal & client reviews |
| Assignee        | View assigned                 | Update status, time, notes     | Submit for review         |

The matrix lives in `lib/features/auth/models/user_role.dart`. It is enforced
in `ProjectService` and `TaskService`, not only in the UI.

## Task lifecycle

```
To Do → Acknowledged → In Progress ⇄ Blocked / Working with Support
  → Internal Review (PM) → [Client Review (PM)] → Final Review (CEO)
  → Done → [Handover] → Closed          (reviews can send work back to In Progress;
                                          managers can Cancel any unfinished task)
```

Defined in `lib/features/tasks/services/task_workflow.dart`:

- Tasks cannot skip stages. Assignees cannot approve their own work, and only
  the CEO signs off and closes.
- A task cannot start until its dependency is Done, Handover or Closed.
  Handover requires a hand-off recipient.
- Rejections, blocks and cancellations require a note.
- The first move to In Progress stamps the **Date/Time Started**. Time spent In
  Progress is added to **Duration** automatically, and manual time can also be
  logged.
- Every move is recorded in `task_history`, including admin overrides.

## Running

```bash
flutter pub get
flutter run
```

Seeded demo accounts. They are created on first launch and listed as one-tap
buttons on the login screen:

| Role            | Username        | Password              |
|-----------------|-----------------|-----------------------|
| Admin           | `admin_user`    | `AdminPassword123!`   |
| CEO             | `ceo_user`      | `CeoPassword123!`     |
| Project Manager | `pm_user`       | `ManagerPassword123!` |
| Assignee        | `standard_user` | `UserPassword123!`    |

Existing installs are migrated to schema v3: `User` accounts become `Assignee`,
and the CEO / PM accounts and a demo project are added.

After editing a `@freezed` model, regenerate the code:

```bash
dart run build_runner build
```

## Tests

```bash
flutter test
```

`flutter test` cannot load test files when the project path contains a `$`
(for example `C:\$projects\…`), because the generated test listener breaks on
it. Run the tests from a path without one.

## Not yet implemented

The spec also describes syncing to a hosted MySQL database through Vercel
serverless endpoints. Today all data lives in on-device SQLite, as in the
original boilerplate's local mode. The services return `Result<T>` and own
every rule, so a remote data source can be added behind them later.
