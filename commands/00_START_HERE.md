# AI Context Loader

Read these files in order at the start of every run:

1. `commands/01_PROJECT_CONTEXT.md`
2. `commands/02_DEV_RULES.md`
3. `commands/03_TASK_TEMPLATE.md` (when creating a new task brief)

Required startup checklist for every run:

- Confirm current goal in 1-2 lines.
- Scan affected files before editing.
- Keep changes minimal and focused.
- Run validation (`flutter analyze` and relevant tests) after changes.
- Report exactly what changed and what was verified.

If a request is ambiguous:

- Do not guess silently.
- Ask one concise clarifying question.
