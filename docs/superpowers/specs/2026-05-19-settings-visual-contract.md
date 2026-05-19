# Settings Visual Contract — Liquid Glass

> Date: 2026-05-19
> Scope: All settings surfaces (`lib/page/home/settings_page.dart` +
> `lib/page/settings_page/**/*.dart`)
> Related: `2026-05-18-liquid-glass-ui-design.md`

## Problem

The settings area has accreted three rendering layers over time:

1. **Tab landing** uses `OmnigramCard` (warm pastel cards)
2. **Mainstream subpages** use `SettingsSection` + `SettingsTile`
   (now glass-styled via T14 + T20)
3. **Rich pages** (companion, server connection, AI provider) hand-roll
   layouts with `Material SwitchListTile`, raw `Text` headers, and
   default Material controls

Result: the chrome (top tab, app bar, action pills) feels Liquid Glass
but stepping into a settings detail breaks the spell. Per-page fixes
keep surfacing because there is no canonical pattern.

This spec defines that pattern. Every settings surface must conform.

## Four canonical layouts

### L1. Page head

- Every settings page uses `AppGlassAppBar` (drop-in for AppBar).
- For top-tier pages reached from the tab (Companion, Reading, etc.)
  the page title is rendered **once** inside the AppBar — not also in
  the body. Removes the "two titles" look.
- AppBar title style: default `titleLarge` from theme — do not override.

### L2. Section card

A logical group of preferences renders as **one** glass card:

```
┌─────────────────────────────────────┐  Section title (optional)
│  ▢ Title 1               Value  >   │  ← SettingsTile.navigation
│  ▢ Title 2                       ◯  │  ← SettingsTile.switchTile
│  ▢ Title 3 (custom)                 │  ← CustomSettingsTile
└─────────────────────────────────────┘
```

- Container: `GlassSurface(radiusBar, blurSigmaThin)` produced by
  `SettingsSection.buildSectionBody`.
- Inside the card: a `Column` of `AbstractSettingsTile` instances
  separated by an automatic 1px outline-variant divider at alpha 0.3
  (rendered by `_GlassSettingsRow`; do not add `Divider()` manually).
- Max items per card: **6**. If a logical group exceeds that, split
  it into two cards with descriptive titles.
- Section title: rendered above the card by `SettingsSection.title`.
  Use `OmnigramTypography.titleMedium` + `onSurface` + `w600`. Do
  **not** write headers as raw `Text(...)` inside `CustomSettingsTile`
  children — that creates the "header inside header" mismatch.

### L3. Tile vocabulary

Only four tile shapes. Anything richer goes in a detail page reached
via `SettingsTile.navigation`.

| Form | Use when |
|------|---------|
| `SettingsTile.navigation(leading, title, value, onPressed)` | Choosing one value from a list, or jumping to a sub-screen |
| `SettingsTile.switchTile(leading, title, initialValue, onToggle)` | Boolean preference |
| `SettingsTile(leading, title, value)` | Read-only info (no chevron, no tap) |
| `CustomSettingsTile(child: …)` | Continuous control that must stay inline (slider, color picker grid). The child must use `OmnigramTypography` and respect the glass tint. |

Controls embedded in `CustomSettingsTile`:
- Sliders: theme-tinted track (primary), height 4px, no shadow
- Switches: `CupertinoSwitch`
- Dropdowns: `showGlassPopupMenu` or push a `ChoicePicker` page
- Chips: `GlassChip`

### L4. Rich form exception

A genuine form (`server_connection_page`, `ai_provider_detail_page`,
companion preview) may forgo the section-card pattern. It must still:

- Wear `AppGlassAppBar`
- Use `OmnigramTypography` for every label
- Use `CupertinoSwitch` instead of Material `Switch`
- Use glass primitives for buttons / chips (`GlassButton`,
  `GlassChip`)
- Group related field clusters with `GlassSurface` cards (one card per
  cluster: "Basic info", "Auth", "Models")

## Picker pages

When a `SettingsTile.navigation` opens a choice screen, use
`pushChoicePicker<T>` from
`lib/widgets/reading_page/more_settings/choice_picker_page.dart`. It
renders each option as a glass row with a check on the selected one
and pops the picked value. This is the only sanctioned single-choice
detail layout — do not hand-roll a new one.

For a single inline slider that needs a dedicated screen (e.g. column
threshold), use the `_SliderDetailPage` pattern from the same file:
big primary-tinted value at top, slider below, optional help text.

## Out of scope (kept as-is)

- `ai_chat_page` — chat is its own design language
- `developer/*` — hidden dev surfaces
- `log_page` content area — log lines stay monospace

## Rollout plan

| Phase | Target | Effort |
|-------|--------|-------|
| 0 | This spec | 0.5h |
| 1 | `home/settings_page.dart` (tab landing) | 1.5h |
| 2 | `companion_settings_page.dart` | 0.5h |
| 3 | `StyleSettings` + `OtherSettings` (inside `reading.dart`) | 1.5h |
| 4 | Rich pages (server / AI provider × 2 / narrate / more_settings) | 2h |
| 5 | Utility subpages (log / conflicts / fonts) polish | 1h |
| 6 | Global theme: `SliderThemeData`, `SwitchThemeData`, `DropdownMenuThemeData`, `DividerThemeData` | 1h |

Execution order: **0 → 1 → 2 → 3 → 6 → 4 → 5**
(theme polish before rich pages so we don't tweak control styles twice).

## Acceptance

A page is done when:
- All elements pass L1-L4
- Hot-reload screenshot looks visually continuous with the bottom
  tab bar and action pills (no Material green/blue accents leaking)
- `flutter analyze` clean on touched files
- `flutter test test/theme/liquid_glass/` 46/46 green
