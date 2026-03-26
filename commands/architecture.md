# Flutter App Architecture Context
## Parent–Child Time-Saving App
### Stack: Cubit (State) + MVC (Logic/Data)

---

## Core Philosophy

| Layer         | Role                                      | Rule                            |
|---------------|-------------------------------------------|---------------------------------|
| View          | Widget tree only                          | No business logic               |
| Cubit         | Emits UI state, calls Controller          | No direct data source access    |
| Controller    | Orchestrates use-cases                    | No Flutter imports              |
| Model         | Immutable data class                      | Pure Dart                       |
| Repository    | Abstract contract                         | Interface only                  |
| Data          | Concrete implementations                  | Knows Firebase / REST / Hive    |

---

## Folder Structure

```
lib/
├── core/
│   ├── di/              # Dependency injection (get_it + injectable)
│   ├── router/          # go_router setup
│   ├── theme/           # AppTheme, colors, text styles
│   └── utils/           # Extensions, helpers, constants
│
├── features/
│   ├── auth/
│   │   ├── view/            # LoginScreen, RegisterScreen
│   │   ├── cubit/           # AuthCubit, AuthState
│   │   ├── model/           # UserModel
│   │   ├── controller/      # AuthController
│   │   └── repository/      # AuthRepository (abstract)
│   │
│   ├── tasks/               # Core feature: child tasks & timers
│   │   ├── view/
│   │   ├── cubit/
│   │   ├── model/
│   │   ├── controller/
│   │   └── repository/
│   │
│   ├── schedule/            # Weekly schedule planner
│   └── rewards/             # Reward system for children
│
├── data/
│   ├── remote/              # Firebase / REST datasources
│   ├── local/               # Hive / SharedPreferences
│   ├── dto/                 # Data Transfer Objects (JSON mappers)
│   └── repositories/        # Concrete repository implementations
│
└── main.dart
```

---

## Key Files

### 1. Model — `features/tasks/model/task_model.dart`
```dart
class TaskModel {
  final String id;
  final String title;
  final int durationMinutes;
  final bool isCompleted;
  final String assignedToChildId;

  const TaskModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.isCompleted,
    required this.assignedToChildId,
  });

  TaskModel copyWith({bool? isCompleted}) => TaskModel(
        id: id,
        title: title,
        durationMinutes: durationMinutes,
        isCompleted: isCompleted ?? this.isCompleted,
        assignedToChildId: assignedToChildId,
      );
}
```

### 2. Repository — `features/tasks/repository/task_repository.dart`
```dart
abstract class TaskRepository {
  Future<List<TaskModel>> fetchTasks(String childId);
  Future<void> completeTask(String taskId);
  Future<void> addTask(TaskModel task);
}
```

### 3. Controller — `features/tasks/controller/task_controller.dart`
```dart
// Pure Dart — no flutter/material imports
class TaskController {
  final TaskRepository _repository;

  TaskController(this._repository);

  Future<List<TaskModel>> getTasksForChild(String childId) =>
      _repository.fetchTasks(childId);

  Future<void> markComplete(String taskId) =>
      _repository.completeTask(taskId);
}
```

### 4. Cubit — `features/tasks/cubit/task_cubit.dart`
```dart
class TaskCubit extends Cubit<TaskState> {
  final TaskController _controller;

  TaskCubit(this._controller) : super(const TaskState.initial());

  Future<void> loadTasks(String childId) async {
    emit(const TaskState.loading());
    try {
      final tasks = await _controller.getTasksForChild(childId);
      emit(TaskState.loaded(tasks));
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }

  Future<void> completeTask(String taskId) async {
    await _controller.markComplete(taskId);
    final current = state.tasks ?? [];
    emit(TaskState.loaded(
      current.map((t) => t.id == taskId ? t.copyWith(isCompleted: true) : t).toList(),
    ));
  }
}
```

### 5. State — `features/tasks/cubit/task_state.dart`
```dart
// Using freezed for fast prototyping
@freezed
class TaskState with _$TaskState {
  const factory TaskState.initial()              = _Initial;
  const factory TaskState.loading()             = _Loading;
  const factory TaskState.loaded(List<TaskModel> tasks) = _Loaded;
  const factory TaskState.error(String message) = _Error;
}
```

### 6. View — `features/tasks/view/task_list_screen.dart`
```dart
class TaskListScreen extends StatelessWidget {
  final String childId;
  const TaskListScreen({required this.childId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskCubit>()..loadTasks(childId),
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) => state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const CircularProgressIndicator(),
          loaded: (tasks) => _TaskList(tasks: tasks),
          error: (msg) => Text('Error: $msg'),
        ),
      ),
    );
  }
}
```

### 7. DI Setup — `core/di/injection.dart`
```dart
// Using get_it
final getIt = GetIt.instance;

void configureDependencies() {
  // Data layer
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt(), getIt()),
  );

  // Domain layer
  getIt.registerFactory(() => TaskController(getIt()));

  // Presentation layer
  getIt.registerFactory(() => TaskCubit(getIt()));
}
```

---

## Data Flow (single direction)

```
User taps → View
         → Cubit.method()
         → Controller.useCase()
         → Repository.abstract()
         → RepositoryImpl (Firebase / Hive)
         ← returns data up the chain
         ← Cubit.emit(newState)
         ← BlocBuilder rebuilds View
```

---

## Recommended Packages

| Purpose            | Package                  |
|--------------------|--------------------------|
| State management   | `flutter_bloc`           |
| DI                 | `get_it`                 |
| Immutable models   | `freezed`                |
| Navigation         | `go_router`              |
| Remote             | `dio` or `firebase_core` |
| Local storage      | `hive_flutter`           |
| Code gen           | `build_runner`           |

---

## Feature Modules (App-Specific)

```
auth/         → Parent & child login, role switching
tasks/        → Create, assign, and complete timed tasks
schedule/     → Weekly time-block planner per child
rewards/      → Points system, redeemable badges
timer/        → Countdown widget tied to a task
notifications/→ Reminders for tasks and schedule
```

---

## Roles & Context

- **Parent role**: manages tasks, schedule, rewards, views reports
- **Child role**: sees own task list, timer, earned rewards
- Role is stored in `UserModel.role` and drives navigation via `go_router` redirect guards

---

## Conventions

- Feature folders are self-contained — no cross-feature imports except through `core/`
- Controllers never import `flutter/material.dart`
- States are always immutable (use `freezed` or manual `copyWith`)
- One Cubit per screen/feature, not per widget
- All async errors are caught in the Cubit — Views only handle state variants