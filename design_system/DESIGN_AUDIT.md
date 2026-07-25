# Mirra — Design Audit

Reverse-engineered from the implementation (`mi_r_r_a_dev` v2.4.0+102). All counts are exact
`grep` frequencies across **262 Dart files** (excluding `internationalization.dart` and the theme
definition). Priorities: **Critical** (breaks consistency at scale / a11y), **High**, **Medium**, **Low**.

---

## UI Health Score: **38 / 100**

| Dimension | Score | Why |
|---|---|---|
| Token adoption | 10/25 | A token layer exists (`FFDesignTokens`) but is used **0 times**; everything hardcoded |
| Color consistency | 6/20 | 104 distinct hex values; 3 error reds, 4 greens, 6+ ambers |
| Type consistency | 9/20 | Good base scale, but ~30 sizes in practice incl. sub-12 px |
| Spacing/radius | 6/15 | ~20 radii, off-scale spacing everywhere |
| Component reuse | 5/12 | Duplicated card/sheet patterns, `makepublic`/`makepubluc`/`makepublc` triplicate |
| Accessibility | 2/8 | Sub-12px text, low-contrast secondary text, single theme w/ dead dark toggle |

The base FlutterFlow scaffold is sound; the debt is **entirely** in hand-written feature code that
bypassed the theme. This is highly recoverable (see MIGRATION_PLAN).

---

## Biggest problems

1. **The design-token layer is dead code.** `FFDesignTokens`/`FFSpacing`/`FFRadius`/`FFShadows`
   exist in [`flutter_flow_theme.dart`](../lib/flutter_flow/flutter_flow_theme.dart) but
   `designToken` is referenced **0×**. Every value is inlined.
2. **Color sprawl:** 104 distinct hardcoded colors / 297 occurrences vs 16 theme tokens.
3. **Semantic color ambiguity:** no single error/success/warning — the meaning is smeared across
   many near-identical hexes.
4. **Type-size sprawl incl. illegible sizes** (7.5, 9, 9.5 px).
5. **Radius/spacing chaos:** 20 radii, off-grid spacing (10 px used 46×, off the token scale).

## Quick wins (≤ 1 day each)

- Replace 19× `Color(0xFF1A1A1A)` + 6× `#1A1A1D` → `theme.primaryText`.
- Replace 10× `Color(0xFF5C85D9)` → `theme.primary`.
- Normalize `FontWeight.bold` → `FontWeight.w700` (single spelling).
- Delete unused `light_dark_toggle` OR gate it (no `DarkModeTheme` exists).
- Add `12` and `20` to `FFSpacing`; add `4`, `12`, `32` to `FFRadius` (unblocks migration).

## High-impact improvements

- Wire `FFDesignTokens` into feature code (lint rule bans raw literals).
- Collapse semantic colors to one token each (`error/success/warning` + `*Bg`).
- Consolidate 7 button heights → 3 sizes via a single `AppButton` wrapper.

---

## Inconsistency register

### 1. Dead token layer — **Critical**
- **Current:** `FFDesignTokens` defined, `designToken` used 0×; ~1,000+ raw literals instead.
- **Recommended:** all feature code reads tokens; add analyzer rule forbidding raw `Color(0x…)`,
  `fontSize:` numeric, `BorderRadius.circular(<literal>)`.
- **Affected:** entire `lib/pages/**`, `lib/components/**`, and custom widget dirs.
- **Effort:** L (foundational; enables everything else).

### 2. Color proliferation — **Critical**
- **Current:** 104 distinct hex / 297 occurrences.
- **Recommended:** ~28-token palette (DESIGN_SYSTEM §2).
- **Top offenders:** `#1A1A1A`(19), `#F3F4F6`(13), `#33000000`(13), `#E0E0E0`(12),
  `#5C85D9`(10), `#FF5963`(9), `#D32F2F`(8).
- **Affected:** all screens.
- **Effort:** L.

### 3. Three error reds — **Critical (semantic)**
- **Current:** `#FF5963`(9, theme), `#D32F2F`(8), `#E53935`(3) + backgrounds `#FFE0E0`/`#FFEEEE`/`#FFEBEE`.
- **Recommended:** one `error` (`#E53935`) + `errorBg` (`#FFEBEE`).
- **Affected:** `error_popup`, `delete_confirmation`, paywall, validation states.
- **Effort:** M.

### 4. Six+ warning/amber tones — **High**
- **Current:** `#FFB300`,`#FBBF23`,`#F9A825`,`#E07A00`,`#FF7043`,`#E65100`,`#FFF3E0`.
- **Recommended:** `warning #F9A825` + `warningBg #FFF3E0`.
- **Affected:** score/rating chips, low-confidence prompts, badges.
- **Effort:** M.

### 5. Four success greens — **High**
- **Current:** theme `#048178` (teal, rarely used) vs `#1B5E20`(6),`#2E7D32`(4),`#43A047`(4).
- **Recommended:** `success #2E7D32` + `successBg #E8F5E9`.
- **Affected:** compatibility result, "safe/good" states.
- **Effort:** M.

### 6. Grey family sprawl — **High**
- **Current:** `#F3F4F6`,`#F2F2F2`,`#F5F7FF`,`#F5F8FF` (surfaces); `#E0E0E0`,`#E6E6E6`,`#E7E8EB`
  (borders); `#555555`,`#333333`,`#9E9E9E`,`#AFAFB0`,`#AEAEAE` (text).
- **Recommended:** `surfaceMuted #F3F4F6`, `border #E0E0E0`, `textTertiary #555555`,
  `textDisabled #AFAFB0`.
- **Affected:** cards, dividers, secondary labels everywhere.
- **Effort:** M.

### 7. Font-size sprawl incl. sub-legible — **Critical (a11y)**
- **Current:** ~30 sizes; `13`(29),`15`(17),`11`(9) off-scale; `9`(4),`9.5`(2),`7.5`(2) illegible.
- **Recommended:** 12–57 scale (DESIGN_SYSTEM §3) + add `20`,`28`; delete <12.
- **Affected:** badges, meta text, dense chips.
- **Effort:** M.

### 8. Weight spelling `bold` vs `w700` — **Low**
- **Current:** `FontWeight.bold`(67) and `FontWeight.w700`(27) — identical value, two spellings.
- **Recommended:** `w700` everywhere.
- **Affected:** global.
- **Effort:** S (find/replace).

### 9. Corner-radius chaos — **High**
- **Current:** ~20 radii — `8`(133),`16`(105),`12`(56),`24`(38),`50`(26),`14`(32),`20`(30),`4`(20),
  plus `2/6/10/26/28/30/36/40/240/280`.
- **Recommended:** `4/8/12/16/24/32/full` (7 steps).
- **Affected:** every card/button/input/sheet.
- **Effort:** M.

### 10. Off-grid spacing — **High**
- **Current:** `10`(46), `14`(28), `6`(20), plus `3/5/7/9/15/18/26/28`.
- **Recommended:** snap to `2/4/8/12/16/20/24/32/40/48/64`.
- **Affected:** all layouts (`EdgeInsets`, `SizedBox` gaps).
- **Effort:** M.

### 11. Seven button heights — **High**
- **Current:** `55`,`54`,`52`,`50`,`44`,`40`,`35` across 56 `FFButtonWidget`.
- **Recommended:** 3 sizes — 36 / 44 / 52.
- **Affected:** every CTA screen (paywall, onboarding, auth, profile).
- **Effort:** M (wrap in `AppButton`).

### 12. Opacity sprawl — **Medium**
- **Current:** ~25 distinct `withOpacity` values 0.06→0.92.
- **Recommended:** 11-step ramp (DESIGN_SYSTEM §7).
- **Affected:** overlays, disabled states, scrims, tints.
- **Effort:** M.

### 13. Manual shadows vs token shadows — **Medium**
- **Current:** `blurRadius` 12/6/24/16/8/20/10/4/32 with 4 different alpha-black colors; `FFShadows` unused.
- **Recommended:** `shadow.sm/md/lg/xl`.
- **Affected:** cards, sheets, floating actions.
- **Effort:** M.

### 14. Icon-size sprawl — **Medium**
- **Current:** `24`(dominant),`20`,`22`,`18`,`16`,`14`,`28`,`26`,`48`,`40`,`30`,`36`,`56`,`64`,`52`,`15`.
- **Recommended:** `16/20/24/28/32/48`.
- **Affected:** nav, list items, buttons.
- **Effort:** M.

### 15. Border widths — **Low**
- **Current:** `1.0`(74), `1.5`(12), `2`.
- **Recommended:** `1` (hairline), `2` (focus/emphasis); drop `1.5`.
- **Affected:** inputs, cards, dividers.
- **Effort:** S.

### 16. Duplicated / typo'd components — **Medium**
- **Current:** `topratings/makepublic`, `makepubluc`, `makepublc`(?) and `makeprivate` variants;
  `item_card` vs `itemcard2`; `empty_gallery` vs `empty_gallery_with_animation`; `no_images`.
- **Recommended:** merge to single parameterised components (`VisibilityToggle`, `ItemCard`,
  `EmptyState`); the `makepubluc` spelling is a typo of `makepublic`.
- **Affected:** top-ratings flow, gallery.
- **Effort:** M–L.

### 17. Dead dark-mode affordance — **Medium (a11y/UX)**
- **Current:** `light_dark_toggle` component exists; only `LightModeTheme` is ever returned.
- **Recommended:** implement `DarkModeTheme` OR remove the toggle.
- **Affected:** settings.
- **Effort:** S (remove) / L (implement).

### 18. Low-contrast secondary text — **High (a11y)**
- **Current:** `textSecondary #929292` on light tint ≈ 2.8:1 (< AA 4.5:1).
- **Recommended:** `#6B6B6B` for small text.
- **Affected:** captions, meta, hints across all screens.
- **Effort:** S.

---

## Effort legend
S = <½ day · M = ½–2 days · L = multi-day / cross-cutting.
