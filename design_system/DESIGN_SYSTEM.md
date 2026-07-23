# Mirra — Design System Specification

> **Source of truth:** the Flutter implementation (`lib/`), not a Figma file.
> This spec was reverse-engineered from `mi_r_r_a_dev` v2.4.0+102 by inventorying every
> `Color`, `TextStyle`, `BorderRadius`, `EdgeInsets`, `BoxShadow`, size and opacity across
> **262 Dart files**. Every token below is grounded in values that already exist in the app.
> The goal is **consistency, scalability and maintainability** — not a visual redesign.
> The existing visual identity (Raleway type, blue/cream/peach palette, flat cards, rounded
> corners) is preserved.

---

## 0. Executive summary

Mirra ships a **single light theme** (`FlutterFlowTheme.of()` always returns `LightModeTheme`;
there is no dark mode) built on **Raleway** via `google_fonts`. FlutterFlow generated a clean
16-colour `ColorScheme`, a 10-step Material `TextTheme`, and — importantly — a **partial token
layer already exists** in [`flutter_flow_theme.dart`](../lib/flutter_flow/flutter_flow_theme.dart):
`FFDesignTokens` → `FFSpacing`, `FFRadius`, `FFShadows`.

**That token layer is dead code.** `designToken` is referenced **0 times** in the app. Every
screen and component instead hardcodes raw values, which is why the codebase now contains
**104 distinct colours, ~30 font sizes, ~20 corner radii, 7 button heights and ~25 opacity
values**. This spec formalises a token set that *absorbs* the existing values into a tight,
named scale and wires the (already-present) token layer into real usage.

---

## 1. Design principles

1. **One source of truth.** Every visual value comes from a named token in
   `flutter_flow_theme.dart`. No raw `Color(0x…)`, `fontSize:`, or `BorderRadius.circular(n)`
   literals in feature code.
2. **Semantic over literal.** Widgets reference intent (`error`, `surfaceMuted`, `radius.md`),
   not appearance (`Color(0xFFD32F2F)`, `circular(12)`).
3. **Preserve identity.** Recommendations consolidate to values *already in the app*; nothing
   is invented except where accessibility requires it (flagged explicitly).
4. **Flat & soft.** The app is deliberately near-flat (`elevation: 0` almost everywhere);
   depth is expressed through soft `BoxShadow` tokens and rounded corners, not Material elevation.
5. **Mobile-first, responsive-ready.** Typography already forks by `DeviceSize`
   (mobile/tablet/desktop); tokens keep that structure.
6. **Accessible by default.** Text/background pairings must meet WCAG AA (see §11).

---

## 2. Color palette

### 2.1 Brand & core (authoritative — from `LightModeTheme`)

| Token | Hex | Role | Notes |
|---|---|---|---|
| `primary` | `#5C85D9` | Primary blue (CTAs, links, active) | Also hardcoded 10× as `Color(0xFF5C85D9)` — dedupe to token |
| `primaryVariant` | `#3B6FCC` | Pressed/hover primary | Currently ad-hoc `#3B6FCC` (3×) |
| `secondary` | `#F2EBB4` | Cream accent | |
| `tertiary` | `#F4CFBC` | Peach accent | |
| `alternate` | `#FFFFFF` | Pure white surface | |
| `primaryBackground` | `#EBF0FC` | App background (blue tint) | |
| `secondaryBackground` | `#CBDDFE` | Raised background | |

### 2.2 Text

| Token | Hex | Usage count (incl. hardcoded dups) |
|---|---|---|
| `textPrimary` | `#1A1A1A` | theme + **19** hardcoded `Color(0xFF1A1A1A)` + 6 near-dup `#1A1A1D` |
| `textSecondary` | `#929292` | theme `secondaryText` |
| `textTertiary` | `#555555` | 7× — merge the mid-grey family (`#555555`, `#333333`, `#9E9E9E`) |
| `textDisabled` | `#AFAFB0` | 6× (`#AFAFB0`,`#AEAEAE`) |

### 2.3 Surfaces / borders / dividers (consolidated from a grey sprawl)

Current greys found: `#F3F4F6`(13), `#E0E0E0`(12), `#E6E6E6`(7), `#F5F8FF`(4), `#F2F2F2`(4),
`#F5F7FF`(2), `#E7E8EB`(3, = theme `info`).

| Token | Hex | Replaces |
|---|---|---|
| `surface` | `#FFFFFF` | `alternate` |
| `surfaceMuted` | `#F3F4F6` | `#F2F2F2`, `#F5F7FF`, `#F5F8FF` |
| `border` | `#E0E0E0` | `#E6E6E6`, `#E7E8EB` |
| `divider` | `#E6E6E6` | inline hairlines |

### 2.4 Semantic (⚠ biggest color problem — see AUDIT §2)

The app currently uses **3 different error reds, 4 greens, and 6+ ambers**. Consolidate:

| Token | Hex | Consolidates (with counts) |
|---|---|---|
| `success` | `#048178` | theme value — but greens `#1B5E20`(6), `#2E7D32`(4), `#43A047`(4) are used as "success" in practice → pick ONE. **Recommend `#2E7D32`** as the visible success green (theme `#048178` is teal, reads as a different hue). |
| `successBg` | `#E8F5E9` | green tint backgrounds |
| `warning` | `#F9A825` | replaces `#FFB300`(5), `#FBBF23`(5), `#F9A825`(3), `#E07A00`(4), `#FF7043`(4), `#E65100`(2) |
| `warningBg` | `#FFF3E0` | amber tint |
| `error` | `#E53935` | theme `#FF5963`(9) + `#D32F2F`(8) + `#E53935`(3) → **one red** |
| `errorBg` | `#FFEBEE` | `#FFE0E0`,`#FFEEEE`,`#FFEBEE` |
| `info` | `#5C85D9` | reuse primary (current `info`=`#E7E8EB` is a grey mislabelled as info) |

> **Identity note:** theme `success=#048178` (teal) and `warning=#FCDC0C` (acid yellow) are the
> FlutterFlow defaults and barely appear in real screens; the hand-written greens/ambers are the
> *de-facto* semantic colours. Recommendation adopts the de-facto values to preserve what users
> actually see.

### 2.5 Overlays & scrims (for shadows/modals)

| Token | Value | Count |
|---|---|---|
| `overlay/08` | `#14000000` (rgba 0,0,0,.08) | 3 |
| `overlay/10` | `#1A000000` (.10) | 9 |
| `overlay/20` | `#33000000` (.20) | 13 |
| `overlay/27` | `#44000000` (.27) | 3 |

Standardise all scrims/manual shadows onto this 4-step black-alpha ramp (see §5).

---

## 3. Typography

**Family:** `Raleway` (Google Fonts) — universal, no exceptions.
**Scale (canonical, already in theme):**

| Token | Size | Weight | Line-height | Mapped role |
|---|---|---|---|---|
| `displayLarge` | 57 | 400 | 1.1 | Splash only |
| `displayMedium` | 45 | 400 | 1.1 | — |
| `displaySmall` | 36 | 600 | 1.1 | Onboarding hero |
| `headlineLarge` | 32 | 400 | 1.15 | Page hero |
| `headlineMedium` | 24 | 500 | 1.2 | Screen title |
| `headlineSmall` | 22 | 700 | 1.2 | Section title |
| `titleLarge` | 22 | 500 | 1.2 | — |
| `titleMedium` | 18 | 500 | 1.3 | Card title |
| `titleSmall` | 16 | 500 | 1.3 | Subtitle |
| `bodyLarge` | 16 | 400 | 1.5 | Body |
| `bodyMedium` | 14 | 400 | 1.5 | Body default |
| `bodySmall` | 12 | 400 | 1.4 | Meta |
| `labelLarge` | 16 | 500 | 1.2 | Button label |
| `labelMedium` | 14 | 500 | 1.2 | Chip/tag |
| `labelSmall` | 12 | 500 | 1.2 | Caption/badge |

### 3.1 Off-scale sizes to eliminate

| Found | Count | → Token |
|---|---|---|
| 13 | 29 | `bodyMedium` (14) |
| 15 | 17 | `bodyLarge` (16) |
| 11 | 9 | `bodySmall`/`labelSmall` (12) |
| 17 | 2 | `titleSmall` (16) or `titleMedium` (18) |
| 20 | 5 | **add `titleLarge`@20** or map to 22 |
| 21 | 3 | 22 |
| 26 | 6 | `headlineMedium` (24) |
| 28 | 2 | **add** or 32 |
| 34 | 1 | 36 |
| 9 / 9.5 / 7.5 | 4/2/2 | 12 (never below 12 — a11y) |

> **Recommended additions to the scale:** `20` (heavily used, no current slot) and `28`.
> **Weights:** keep `400/500/600/700`. Note `FontWeight.bold` **is** `w700` — the codebase mixes
> both spellings (67× `bold`, 27× `w700`); pick `w700` everywhere. `w600` (semibold) is the most
> common weight (145×) — it deserves a first-class role (emphasis/buttons).

---

## 4. Spacing scale

**Recommended (4-based, extends the existing `FFSpacing`):**

```
xxs  2      xs  4      sm  8      md  12
lg   16     xl  20     2xl 24     3xl 32
4xl  40     5xl 48     6xl 64
```

Current `FFSpacing` only defines `4/8/16/24/32` and **skips 12 and 20**, which are two of the
most-used gaps in the app (`SizedBox(width:12)` 44×, `EdgeInsets…12` 56×, gap `20` 40×+).
The scale above adds them. Off-scale values to snap:

| Found | Count | → Token |
|---|---|---|
| 6 | ~20 | `sm` (8) |
| 10 | ~46 | `md` (12) |
| 14 | ~28 | `lg` (16) |
| 15 / 18 | few | 16 / 20 |
| 5 / 3 / 7 / 9 | few | 4 / 8 |
| 26 / 28 | few | 24 / 32 |
| 60 / 100 | few | keep as layout one-offs, not spacing tokens |

---

## 5. Radius scale

**Recommended:**

| Token | Value | Replaces (count) |
|---|---|---|
| `radius.xs` | 4 | `4`(20), `2`(9), `3`, `6` |
| `radius.sm` | 8 | `8`(133) ✅ dominant |
| `radius.md` | 12 | `12`(56), `10`(8), `14`(32) |
| `radius.lg` | 16 | `16`(105) ✅ |
| `radius.xl` | 24 | `20`(30), `24`(38), `26`, `28`, `30` |
| `radius.2xl` | 32 | `32`, `36`, `40` |
| `radius.full` | 9999 | `50`(26), `240`, `280` (pills/circles) |

Existing `FFRadius` defines `8/16/24/full` — **add `4`, `12`, `32`**. `12` alone appears 56×.

---

## 6. Shadows & elevation

Material `elevation` is effectively unused (`elevation: 0` in 158 places). Depth = manual
`BoxShadow`. Adopt the **already-defined** `FFShadows` (color `#1A000000`, y-offset ramp):

| Token | blur | y-offset | color |
|---|---|---|---|
| `shadow.sm` | 3 | 1 | `#1A000000` |
| `shadow.md` | 6 | 3 | `#1A000000` |
| `shadow.lg` | 15 | 8 | `#1A000000` |
| `shadow.xl` | 25 | 16 | `#1A000000` |

Real `blurRadius` values found (12, 6, 24, 16, 8, 20, 10, 4, 32) snap to the nearest token.
One backdrop blur exists (`ImageFilter.blur sigma 18`) — token `blur.backdrop = 18`.

---

## 7. Opacity scale

~25 distinct opacities (0.06–0.92) collapse to an 11-step ramp:

```
0 · 0.04 · 0.08 · 0.12 · 0.16 · 0.24 · 0.32 · 0.48 · 0.64 · 0.80 · 0.92
```

Map: `.06→.04/.08`, `.1/.11→.12`, `.14/.15→.16`, `.18/.2→.16/.24`, `.25→.24`, `.3/.35→.32`,
`.4/.45→.48`, `.5/.55→.48`, `.6/.7→.64`, `.75/.8/.85→.80`, `.9/.92→.92`.

---

## 8. Component specifications

### 8.1 Buttons (`FFButtonWidget`, 56 instances)

Consolidate 7 heights (35/40/44/50/52/54/55) → **3 sizes**:

| Size | Height | Radius | Text | Padding-x |
|---|---|---|---|---|
| `sm` | 36 | `md` (12) | `labelMedium` 14/500 | 16 |
| `md` (default) | 44 | `lg` (16) | `labelLarge` 16/600 | 20 |
| `lg` | 52 | `lg` (16) | `labelLarge` 16/700 | 24 |

Variants: **Primary** (`primary` fill / white text), **Secondary** (`surfaceMuted` fill /
`textPrimary`), **Outline** (1px `border`, transparent), **Text/Ghost** (no fill), **Destructive**
(`error` fill).

### 8.2 Icon buttons (`FlutterFlowIconButton`, 17 instances)

Sizes → **32 / 40 / 48** tap targets; icon glyph 20/24/28. Border radius `full` or `md`.

### 8.3 Inputs (`TextFormField`, 22 · `OutlineInputBorder` 55)

| Prop | Value |
|---|---|
| Height | 52 |
| Radius | `lg` (16) |
| Border | 1px `border`; focus 1.5px `primary` |
| Fill | `surfaceMuted` (16 inputs already `filled:true`) |
| Text / hint | `bodyMedium` 14 / `textSecondary` |
| Content padding | 16 × 14 |

### 8.4 Cards (`product_card_v2`, `profile_summary_card`, item cards)

Radius `lg`/`xl` (16–24), `shadow.sm`/`md`, padding 16, `surface` fill, optional 1px `border`.

### 8.5 Navigation (`navbar` component)

Bottom tab bar: `surface` bg, `shadow.md` top, active = `primary`, inactive = `textSecondary`,
icon 24, label `labelSmall` 12/500.

### 8.6 Bottom sheets (`showModalBottomSheet`, 30 instances)

Top radius `xl` (24) both corners, `surface` bg, drag handle 40×4 `border`, content padding 16–24,
scrim `overlay/27`.

### 8.7 Dialogs (`showDialog`/`AlertDialog`, 9)

Radius `xl` (24), padding 24, `shadow.lg`, title `titleMedium`, body `bodyMedium`, actions =
Text + Primary button.

### 8.8 Chips / Tags / Badges (`ingredient_bubbles`, score chips)

Chip: height 32, radius `full`, padding-x 12, `labelMedium`. Badge: min 20, radius `full`,
`labelSmall` 12/600. Semantic-tinted (`successBg`/`warningBg`/`errorBg` + matching text).

### 8.9 Avatars

Radii/diameters → **24 / 32 / 40 / 56 / 80**, always `radius.full`.

---

## 9. Icon sizes

`16 · 20 · 24 (default) · 28 · 32 · 48`. Snap 22→24, 26→24/28, 15→16, 18→20, 30→32, 36→32, 40→48.

## 10. Border widths

`hairline = 1` (74× — dominant), `thick = 2`. Eliminate `1.5` (12×) → snap to 1 or 2 by context
(focus rings use 2).

---

## 11. Accessibility recommendations

- **Minimum text size 12** — remove the `7.5 / 9 / 9.5` occurrences (illegible; fail a11y).
- **Contrast:** verify `textSecondary #929292` on `#EBF0FC`/`#F3F4F6` — it is **~2.8:1**, below
  WCAG AA (4.5:1) for body text. Darken to `#6B6B6B` for small text, or reserve `#929292` for
  large/decorative only.
- **Tap targets ≥ 44×44** — button `sm` (36) and 32-px icon buttons need 44 px hit area
  (padding, not visual size).
- Single light theme: ensure the `light_dark_toggle` component isn't implying a dark mode that
  doesn't exist (there is only `LightModeTheme`). Either build a real `DarkModeTheme` or remove
  the toggle.

---

## 12. Design tokens & naming conventions

**Naming:** `category.role.variant` in code, `--ff-category-role` in CSS, kebab in JSON.

- Colors: `color.brand.primary`, `color.text.primary`, `color.semantic.error`, `color.surface.muted`
- Type: `type.headlineMedium` (keep Material role names already in `FlutterFlowTheme`)
- Spacing: `space.md` (12)
- Radius: `radius.lg` (16)
- Shadow: `shadow.md`
- Opacity: `opacity.32`

Machine-readable exports live in [`tokens/`](tokens/):
- `tokens.json` — W3C Design Tokens format
- `tokens.css` — CSS custom properties
- `tailwind.theme.js` — Tailwind theme extension (for any web surface / marketing site)

The **Dart** binding already exists as `FFDesignTokens` — §MIGRATION_PLAN extends it to full
parity so Flutter code consumes the same token names.

---

## 13. Component library (target inventory)

Primary Button · Secondary Button · Outline Button · Text Button · Destructive Button ·
Icon Button · Filled Input · Search Bar · Card · List Item · Dialog · Bottom Sheet · Snackbar/Toast ·
Tabs (top) · Tab Bar (bottom nav) · Segmented Control · Checkbox · Switch · Radio · Dropdown
(`FlutterFlowDropDown`) · Chip · Tag · Badge · Avatar · Progress Indicator · Skeleton Loader
(already present: `*_loading_component` ×5) · Empty State (`empty_gallery`, `no_images`) ·
Country/Language Selector · Paywall Card · Score Breakdown · Ingredient Bubble.
