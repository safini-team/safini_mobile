# Safini Color Context

Use this palette for UI styling unless explicitly overridden.

## Core Palette

- `#8100D1` - Primary purple
- `#B600BA` - Secondary violet
- `#EE4FA2` - Accent pink
- `#F09A77` - Accent peach

## Usage Guidance

- Primary actions, top gradients: `#8100D1`
- Secondary surfaces/sections: `#B600BA`
- Highlights, badges, CTA accents: `#EE4FA2`
- Warm contrast blocks/background accents: `#F09A77`

## Typography (SF Pro)

Use SF Pro as the default font family across the app.

- Primary font family: `SF Pro Display` (headings), fallback `SF Pro Text`
- Default body font: `SF Pro Text`
- Keep typography clean and readable; avoid mixing multiple font families

### Text Style Guidance

- Headings: `SF Pro Display`, weight `700` or `800`
- Subheadings: `SF Pro Display`, weight `600`
- Body: `SF Pro Text`, weight `400` or `500`
- Buttons/CTAs: `SF Pro Text`, weight `600`
- Captions/helper text: `SF Pro Text`, weight `400`

### Platform Note

- iOS: prefer native SF Pro rendering
- Android: use configured SF Pro assets when bundled in project

## Global Theme Extension (Mandatory)

Use the shared extension in `lib/core/utils/theme_extensions.dart` for text and colors.

- Import: `package:safini/core/utils/theme_extensions.dart`
- Do not create raw `TextStyle` for standard typography in pages/widgets.
- Use extension getters for typography:
  - `context.headingXl`
  - `context.headingMd`
  - `context.bodyLg`
  - `context.bodyMd`
- Use `context.onPrimaryStyle(...)` when text is on top of primary/gradient backgrounds.

### Implementation Rule

- Prefer `context` theme extensions first.
- If a one-off override is needed, start from extension style and use `copyWith(...)`.
- Keep font families centralized in `AppTheme`; UI files should consume theme styles, not redefine font families.
