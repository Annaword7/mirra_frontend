# Mirra — Design System Migration Plan

Goal: move from ~1,000 hardcoded literals to a token-driven UI **with minimal risk and zero
visual regression** the user would notice. Strategy: **absorb, don't redesign** — tokens are seeded
with the values already on screen, then references are swapped incrementally, screen by screen,
behind a lint gate.

Because Mirra is FlutterFlow-generated, the safe pattern is: **extend the existing
`FlutterFlowTheme`/`FFDesignTokens` (never fork it)**, so future FlutterFlow re-exports keep working.

---

## Guiding rules

1. **No visual change in Phase 0–2.** Tokens are set to *current* values; swaps are 1:1.
2. **One category per PR** (colors, then radius, then spacing…) — small, reviewable diffs.
3. **Screen-by-screen**, not big-bang. Each screen is verified against a before/after screenshot.
4. **Verify per the project's own guidance:** test new UI via **Xcode Run on device**, not
   TestFlight/IPA (per team convention).
5. Every changed line must trace to a token swap — no drive-by refactors.

---

## Phase 0 — Foundation (½–1 day) · risk: none

**Extend the token layer to full parity. Purely additive.**

1. In [`flutter_flow_theme.dart`](../lib/flutter_flow/flutter_flow_theme.dart):
   - `FFSpacing`: add `xxs=2`, `md=12`, `xl=20`, `xxl2=... ` → full scale `2/4/8/12/16/20/24/32/40/48/64`.
   - `FFRadius`: add `xs=4`, `md=12`, `xxl=32` → `4/8/12/16/24/32/full`.
   - Add `FFOpacity` (11-step) and `FFSizing` (icon/button/input/avatar) helper classes.
   - Add semantic color getters to `LightModeTheme`: `errorBg`, `successBg`, `warningBg`,
     `surfaceMuted`, `textTertiary`, `textDisabled`, `primaryVariant`.
2. Commit `design_system/tokens/*` (already generated) as the cross-platform source.
3. **Verify:** app compiles, `flutter analyze` clean. No UI change.

**→ verify:** build succeeds; zero visual diff.

---

## Phase 1 — Color consolidation (2–3 days) · risk: low

Highest-impact, mechanical. Do in sub-PRs:

1. **1a — Exact-duplicate swaps (quick win).** Find/replace theme-equal hardcodes:
   `Color(0xFF1A1A1A)`→`theme.primaryText` (19+6), `Color(0xFF5C85D9)`→`theme.primary` (10),
   `#E7E8EB`→`theme.info`. Pure dedupe, 0 visual change.
2. **1b — Semantic reds** → `theme.error`/`errorBg`. **Note:** this changes `#D32F2F`/`#FF5963`
   to one red — a *deliberate, tiny* hue shift. Screenshot-review each error surface.
3. **1c — Greens → `success`**, **1d — Ambers → `warning`**, **1e — Greys → surface/border/text**.
4. **1f — Overlays** → `overlay/08/10/20/27`.

**→ verify:** screenshot diff per screen; semantic colors reviewed by design owner; contrast of
`textSecondary` fixed to `#6B6B6B` (a11y).

---

## Phase 2 — Radius, spacing, shadows (2–3 days) · risk: low

1. Replace `BorderRadius.circular(<n>)` literals with `theme.radius.<token>` per the mapping in
   DESIGN_SYSTEM §5. `8`(133) and `16`(105) are already on-token — only the ~10 off-values move.
2. Replace `EdgeInsets`/`SizedBox` literals with `theme.space.<token>`; snap off-grid
   (`10→12`, `14→16`, `6→8`). These are ≤2px shifts — imperceptible.
3. Replace manual `BoxShadow` with `theme.shadow.<token>`.

**→ verify:** side-by-side per screen; confirm no layout reflow breaks (dense chip rows,
`ingredient_bubbles`).

---

## Phase 3 — Typography (1–2 days) · risk: low-medium

1. Replace off-scale `fontSize` overrides with the nearest role token (`13→bodyMedium`,
   `15→bodyLarge`, `11→bodySmall`, `26→headlineMedium`).
2. **Delete sub-12px** (`7.5/9/9.5`) — bump to 12 (a11y; may cause minor reflow — review).
3. Normalize `FontWeight.bold`→`w700` globally.
4. Add `20` and `28` roles to the type scale for the genuinely-missing sizes.

**→ verify:** visual review of dense/badge areas; confirm no truncation.

---

## Phase 4 — Component wrappers (3–5 days) · risk: medium

Build thin wrappers so future screens can't drift:

1. `AppButton` (wraps `FFButtonWidget`) — 3 sizes, 5 variants; migrate 56 call-sites.
2. `AppInput` (wraps `TextFormField`) — one height/border/fill.
3. `AppCard`, `AppBottomSheet`, `AppDialog`, `AppChip`/`AppBadge`, `EmptyState`.
4. **Merge duplicates:** `item_card`+`itemcard2`→`ItemCard`;
   `makepublic`/`makepubluc`(typo)/`makeprivate`→`VisibilityToggle`;
   `empty_gallery`(+animation)/`no_images`→`EmptyState`.

**→ verify:** each wrapper covered by a widget test; migrate call-sites incrementally.

---

## Phase 5 — Guardrails (½ day) · risk: none

1. Add `analysis_options.yaml` custom lint / CI grep gate that **fails** on:
   raw `Color(0x` in `lib/pages` & `lib/components`, numeric `fontSize:`, literal
   `BorderRadius.circular(<number>)`, `FontWeight.bold`.
2. Document token usage in `CLAUDE.md` so future generated/hand code conforms.
3. Decide dark mode: implement `DarkModeTheme` or remove `light_dark_toggle`.

**→ verify:** CI blocks a test PR that reintroduces a raw literal.

---

## Sequencing & effort summary

| Phase | Scope | Effort | Risk | Visual change |
|---|---|---|---|---|
| 0 | Extend token layer | ½–1 d | none | none |
| 1 | Colors | 2–3 d | low | tiny (semantic hues) |
| 2 | Radius/spacing/shadow | 2–3 d | low | ≤2px |
| 3 | Typography | 1–2 d | low-med | minor (a11y bumps) |
| 4 | Component wrappers + merges | 3–5 d | med | none (behaviour-preserving) |
| 5 | Guardrails | ½ d | none | none |

**Total: ~10–15 developer-days**, fully incremental — shippable after every phase, no big-bang.

## Migration complexity: **Medium**

- **In our favour:** single theme, one font, a token layer already scaffolded, FlutterFlow's
  consistent structure, and the two most-used radii (8/16) already on-token.
- **Against us:** ~1,000 literal sites and semantic-color decisions that need a design sign-off.
- **Rollback:** each phase is an independent PR; revert is trivial. No data/schema involved.
