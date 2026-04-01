# Flutter Widget Creation Skill

---

## Purpose

This skill defines how all widgets must be created, named, and organized in this project. Every time an AI agent generates or modifies UI code, it **must** follow these rules exactly — no inline widget classes, no anonymous builders, no exceptions unless explicitly instructed.

---

## Core Rule

> **Never define a widget class inside another widget file.**
> Every widget is its own file, in its own organized subfolder.

> **Use global theme + AutoRoute in every widget/page.**
> Style text with `context.textTheme` and navigate with `context.router`.

---

## Widget Folder Structure

Widgets live inside the feature they belong to. Use subfolders to group by type:

```
lib/
└── features/
    └── <feature>/
        └── presentation/
            └── widgets/
                ├── buttons/
                │   ├── <feature>_primary_button.dart
                │   ├── <feature>_icon_button.dart
                │   └── <feature>_text_button.dart
                │
                ├── fields/
                │   ├── <feature>_text_field.dart
                │   ├── <feature>_dropdown_field.dart
                │   └── <feature>_date_picker_field.dart
                │
                ├── cards/
                │   ├── <feature>_item_card.dart
                │   └── <feature>_summary_card.dart
                │
                ├── dialogs/
                │   ├── <feature>_confirm_dialog.dart
                │   └── <feature>_error_dialog.dart
                │
                ├── tiles/
                │   └── <feature>_list_tile.dart
                │
                └── utils/
                    ├── <feature>_loading_indicator.dart
                    ├── <feature>_empty_state.dart
                    └── <feature>_error_view.dart
```

---

## Subfolder Reference

| Subfolder   | What goes here                                                              |
|-------------|-----------------------------------------------------------------------------|
| `buttons/`  | All tappable actions: primary, secondary, icon, text, FAB variants          |
| `fields/`   | All input widgets: text fields, dropdowns, date pickers, search bars        |
| `cards/`    | Content containers: item cards, summary cards, info panels                  |
| `dialogs/`  | Modal dialogs, bottom sheets, confirmation prompts                          |
| `tiles/`    | List items, row tiles, expandable tiles                                     |
| `utils/`    | Stateless helpers: loading spinners, empty states, error views, dividers    |

> Add new subfolders as needed (e.g. `charts/`, `avatars/`, `badges/`). Keep each folder single-purpose.

---

## File Templates

### Button — `<feature>_primary_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class <Feature>PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const <Feature>PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label, style: context.textTheme.labelLarge),
    );
  }
}
```

---

### Text Field — `<feature>_text_field.dart`

```dart
import 'package:flutter/material.dart';

class <Feature>TextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;

  const <Feature>TextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
```

---

### Card — `<feature>_item_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class <Feature>ItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const <Feature>ItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: context.textTheme.titleMedium),
        subtitle: subtitle != null
            ? Text(subtitle!, style: context.textTheme.bodyMedium)
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
```

---

### Dialog — `<feature>_confirm_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class <Feature>ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;

  const <Feature>ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => <Feature>ConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: context.textTheme.headlineSmall),
      content: Text(message, style: context.textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => context.router.maybePop(),
          child: Text(cancelLabel, style: context.textTheme.labelLarge),
        ),
        TextButton(
          onPressed: () {
            context.router.maybePop();
            onConfirm();
          },
          child: Text(confirmLabel, style: context.textTheme.labelLarge),
        ),
      ],
    );
  }
}
```

---

### Empty State — `<feature>_empty_state.dart`

```dart
import 'package:flutter/material.dart';

class <Feature>EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final Widget? action;

  const <Feature>EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
```

---

### Loading Indicator — `<feature>_loading_indicator.dart`

```dart
import 'package:flutter/material.dart';

class <Feature>LoadingIndicator extends StatelessWidget {
  final String? message;

  const <Feature>LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
```

---

### Error View — `<feature>_error_view.dart`

```dart
import 'package:flutter/material.dart';

class <Feature>ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const <Feature>ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
```

---

## How to Use Widgets in a Screen

Import each widget individually. Never define widget classes inline in the screen file.

```dart
// ✅ Correct
import '../widgets/buttons/<feature>_primary_button.dart';
import '../widgets/fields/<feature>_text_field.dart';
import '../widgets/utils/<feature>_loading_indicator.dart';

class <Feature>Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          <Feature>TextField(label: 'Name', controller: _controller),
          <Feature>PrimaryButton(label: 'Submit', onPressed: _onSubmit),
        ],
      ),
    );
  }
}
```

```dart
// ❌ Never do this — widget class defined inside the screen file
class <Feature>Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SubmitButton(), // defined below in same file — FORBIDDEN
    );
  }
}

class _SubmitButton extends StatelessWidget { ... } // FORBIDDEN
```

---

## Shared / Cross-Feature Widgets

If a widget is used by more than one feature, move it to `core/`:

```
lib/
└── core/
    └── widgets/
        ├── buttons/
        │   └── app_primary_button.dart
        ├── fields/
        │   └── app_text_field.dart
        └── utils/
            ├── app_loading_indicator.dart
            └── app_empty_state.dart
```

Prefix shared widgets with `app_` instead of `<feature>_`.

---

## Non-Negotiable Rules

1. **One widget class per file** — always.
2. **No private widget classes** (`_MyWidget`) defined in a screen or another widget file.
3. **No anonymous widget builders** used as substitutes for named widget classes.
4. **Widgets go in `presentation/widgets/<subfolder>/`** — never in `screens/` or `cubit/`.
5. **Feature-specific widgets** use the `<Feature>` prefix. Shared widgets use the `App` prefix and live in `core/widgets/`.
6. **Widgets are stateless by default** — use `StatefulWidget` only when local ephemeral state is strictly required (e.g. animation controller, focus node). Never manage business state inside a widget.
7. **No BlocProvider or context.read inside a widget** — data flows down as constructor parameters; actions flow up as callbacks.
8. **Typography must come from extension** — always use `context.textTheme.*` for text styles.
9. **Navigation must use AutoRoute** — use `context.router` instead of `Navigator.of(context)`.

---

## Checklist — Before Submitting Any Widget

- [ ] Widget is in its own file under `presentation/widgets/<subfolder>/`
- [ ] File name matches: `<feature>_<widget_name>.dart`
- [ ] Class name matches: `<Feature><WidgetName>`
- [ ] No other widget classes defined in the same file
- [ ] All required data passed as constructor parameters
- [ ] All actions passed as callbacks (`VoidCallback`, `ValueChanged<T>`)
- [ ] No business logic, no Bloc/Cubit reads inside the widget
- [ ] If reused across features → moved to `core/widgets/` with `App` prefix