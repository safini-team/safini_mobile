# Development Rules For AI Runs

General:

- Prefer small, safe edits over large refactors.
- Do not change unrelated files.
- Keep naming consistent with existing project style.

Flutter rules:

- Use `const` where possible.
- Keep widgets readable and split only when needed.
- Avoid introducing new dependencies unless necessary.

Validation rules:

- Run `flutter analyze` after code changes.
- Run targeted tests when behavior changes.
- If validation cannot be run, state why.

Communication rules:

- Explain changes by file path.
- Report risks, assumptions, and follow-up suggestions briefly.
