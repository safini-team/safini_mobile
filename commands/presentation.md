# Presentation Layer

The presentation layer is responsible for rendering the UI and handling user interactions. It must be as "dumb" as possible, delegating all business logic to the Domain layer through Cubits. 

## Non-Negotiable Rules

1. **Views are dumb** — Screens and Widgets contain zero business logic. They simply call Cubit methods and render state variations.
2. **One Cubit per screen** — A Cubit represents the state for an entire screen, not individual sub-widgets unless absolutely necessary for complex local states.
3. **No Exceptions in Views** — All errors must be caught in the Cubit. Views should never have `try-catch` blocks and should only switch on `state.status`.

---

## File Templates

### 1. State — `<feature>_state.dart`

```dart
part of '<feature>_cubit.dart';

enum <Feature>Status { initial, loading, loaded, error }

class <Feature>State {
  final <Feature>Status status;
  final <Feature>Model? data;
  final String? errorMessage;

  const <Feature>State({
    this.status = <Feature>Status.initial,
    this.data,
    this.errorMessage,
  });

  <Feature>State copyWith({
    <Feature>Status? status,
    <Feature>Model? data,
    String? errorMessage,
  }) {
    return <Feature>State(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

### 2. Cubit — `<feature>_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/controllers/<feature>_controller.dart';
import '../domain/models/<feature>_model.dart';

part '<feature>_state.dart';

class <Feature>Cubit extends Cubit<<Feature>State> {
  final <Feature>Controller _controller;

  <Feature>Cubit(this._controller) : super(const <Feature>State());

  Future<void> load() async {
    emit(state.copyWith(status: <Feature>Status.loading));
    final result = await _controller.fetch();
    result.fold(
      (failure) => emit(state.copyWith(
        status: <Feature>Status.error,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: <Feature>Status.loaded,
        data: data,
      )),
    );
  }
}
```

### 3. Screen — `<feature>_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/<feature>_cubit.dart';

class <Feature>Screen extends StatelessWidget {
  const <Feature>Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ctx.read<<Feature>Cubit>()..load(),
      child: Scaffold(
        body: BlocBuilder<<Feature>Cubit, <Feature>State>(
          builder: (context, state) {
            switch (state.status) {
              case <Feature>Status.initial:
                return const SizedBox.shrink();
              case <Feature>Status.loading:
                return const Center(child: CircularProgressIndicator());
              case <Feature>Status.loaded:
                return _<Feature>Body(data: state.data!);
              case <Feature>Status.error:
                return Center(child: Text(state.errorMessage ?? 'Error'));
            }
          },
        ),
      ),
    );
  }
}

class _<Feature>Body extends StatelessWidget {
  final <Feature>Model data;
  const _<Feature>Body({required this.data});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(); // Replace with real UI
  }
}
```
