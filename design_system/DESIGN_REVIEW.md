# Mirra — Design Review (Track 2)

> **Purpose:** a screen-by-screen UX + design-system review of the whole app, to scope the
> *intentional visual improvements* track. **This document proposes; it changes no code.**
> It is the input to the design-system project, distinct from the completed mechanical
> tokenization (Track 1).
>
> **Scope:** ~74 screens/components. **Method:** 8 parallel read-only reviews grounded in the
> token layer landed in Phase 0. Findings cite `file:line`; each carries a priority
> (High / Medium / Low) and a no-code proposed solution.
>
> _Reviewed against: single light theme (permanent), Raleway, and the token set in
> `lib/flutter_flow/flutter_flow_theme.dart`._

## Executive summary

The app's screens are individually competent but were built **screen-by-screen with no shared
component layer**, so the same element is re-invented everywhere with slightly different values.
The mechanical tokenization (Track 1) fixed *where colors come from* for a subset of literals; this
review is about the **structural** debt that only a design pass can resolve: one button system, one
sheet, one card, one score-color scale, real empty states, and an accessibility baseline.

**Six systemic themes account for the large majority of findings:**

1. **Button chaos (High).** Across the app, primary buttons appear at heights **35 / 40 / 44 / 50 /
   52 / 54 / 55 / 56 / 62 / 65** and radii **8 / 12 / 14 / 18 / 20 / 24 / 26 / 28 / 30 / 36 / 40 /
   50**, built as `FFButtonWidget`, `ElevatedButton`, and hand-rolled `Ink` pills — often several on
   one screen. → **`PrimaryButton` / `SecondaryButton` / `PillButton` / `DestructiveButton`.**

2. **No semantic color system (High).** "Good vs bad" is drawn differently on every screen: the
   **score→color** logic exists in **3 incompatible band sets** (3-band fit card, 6-band tiles,
   6-stop share card) and the **dose-status** palette *contradicts itself* — "working" is **green**
   in the radar but **amber** in the bubbles. Ingredient good/bad, conflict severity, quota-exhausted
   red, and warning-amber each appear as 3–6 ad-hoc hexes. → **`semanticScoreColor()` +
   `statusColor()` + `StatusLegend` + semantic `success/warning/error(+Bg)` tokens.**

3. **Duplicated components (High).** Whole features exist twice: **`item_card` vs `itemcard2`**;
   **`imagedetailed_main` vs `imagedetailed_top_raited`** (literal twins); **`makepublic` vs
   `makepubluc`** (a *misspelling*); **6 loaders** + **4–5 empty states** that are the *same fade-tile
   grid* (~2,000 lines, incl. one 1,200-line file); **2 confirm dialogs**, **2 limit surfaces**,
   **2 account-creation flows**, **2 bottom-sheet shells**, **3 drag-handle designs**. → a shared
   component library is the single highest-leverage investment.

4. **Empty-vs-loading conflation (High).** The "empty gallery" states are message-less gray skeleton
   grids — *the same code as the loaders* — so an empty screen reads as perpetual loading and offers
   no "Scan a product" action. → **`SkeletonGrid`** for loading, **`MirraEmptyState`** (icon + copy +
   CTA) for empty.

5. **Accessibility baseline (High).** `secondaryText #929292` is used for body copy app-wide and
   **fails WCAG AA (~2.8:1)**; text drops to **7.0–9.5px** in scoring/share/radar UIs; tap targets
   fall below 44–48px (password toggles, chips, avatars, nav labels, step rows); and good/bad meaning
   is frequently **color-only** (score rings, ingredient highlights, status dots). → contrast fix +
   12px floor + 44px min targets + non-color status cues.

6. **Tokens bypassed locally (Medium).** Three onboarding files and `routine_calendar` re-declare
   private palettes (`_ink/_muted/_card`, `_kTextPrimary`, purple disabled colors) and raw
   `Colors.black/white`; several widgets use **raw `TextStyle` with no `fontFamily`, so they don't
   render in Raleway** (feature cards, quota bars, pipeline, loaders). → route through theme roles.

**Also recurring:** every bottom sheet/dialog hardcodes its own radius/scrim/handle/padding
(Medium); localization gaps — hardcoded EN/RU strings, inline ternaries, and inline maps duplicating
`FFLocalizations`, with weekday labels missing Spanish (Medium); and **dead code** — `light_dark_toggle`,
navbar & product_card_v2 dark-mode branches, `score_card` stub, `startanalys` `print()` button, dead
gradients (report-only, not for deletion here).

### Priority tally (findings across 74 screens)

| Priority | Count (approx) | Nature |
|---|---|---|
| **High** | ~55 | Duplication that blocks reuse; accessibility failures; broken/decorative states |
| **Medium** | ~90 | Token bypasses, inconsistent radii/heights, localization gaps, UX-flow fragility |
| **Low** | ~40 | Polish, dead helpers, formatting |

### Prioritized backlog (cross-cutting initiatives)

These bundle the per-screen findings into shippable design-system workstreams. Effort: S ≤2d · M 3–5d · L 1–2wk.

| # | Initiative | Priority | Effort | Kills |
|---|---|---|---|---|
| B1 | **Button system** — `PrimaryButton`/`Secondary`/`Pill`/`Destructive` with height+radius+on-primary tokens; migrate all call-sites | High | L | ~10 heights, ~12 radii, 3 button classes |
| B2 | **Semantic color + score system** — `semanticScoreColor()`, `statusColor()`, `StatusLegend`, `success/warning/error(+Bg)` tokens | High | M | 3 score-band systems, contradictory status palettes, quota/severity reds |
| B3 | **Accessibility pass** — `secondaryText`→AA-compliant body token, 12px floor, 44px min targets, non-color status cues | High | M | contrast fails, sub-12 text, tiny tap targets, color-only meaning |
| B4 | **Empty vs loading** — `SkeletonGrid` (loading) + `MirraEmptyState` (icon+copy+CTA) | High | M | 6 loaders + 4–5 empty states (~2,000 lines) |
| B5 | **Sheets & dialogs** — `MirraBottomSheet` + `MirraDialogCard` + `MirraDragHandle` | High | M | 2 sheet shells, 3 handles, per-sheet radius/scrim drift |
| B6 | **Product surfaces** — `ProductTile` (merge tiles), `MirraInfoCard`, `MirraChip`/`Tag`, `ScoreBadge` | High | L | item_card/itemcard2 split, 3 info cards, chip reinventions |
| B7 | **Confirmation & limit consolidation** — `ConfirmationSheet`, `ConfirmDialog`, `LimitReached(variant)`; **delete `makepubluc`** | High | S | 5 visibility sheets, 2 confirm dialogs, 2 limit surfaces |
| B8 | **Settings & rows** — `SettingsRow`, `SelectableRow`/`SettingsList`, `SettingsScaffold` | Medium | M | 7 Profile rows, Langs/Countries duplication |
| B9 | **Paywall** — `PlanCard`, `FeatureRow` (data-driven), `ProPill`, paywall dark palette tokens | Medium | M | twin plan cards, 8+4 feature rows, 3 PRO badges |
| B10 | **Inputs** — `AppTextField` with a **visible focus border** (fixes invisible-focus everywhere) | High | S | 4+ divergent field decorations, missing focus states |
| B11 | **Typography hygiene** — route raw `TextStyle` through roles (Raleway), remove local type scales, add `displayXS` 24–26 role | Medium | M | non-Raleway text, `fontSize:26` overrides, 3 private scales |
| B12 | **Localization & dead-code cleanup** — move inline strings/maps to `FFLocalizations`, add Spanish weekdays; remove `light_dark_toggle` + dark branches | Medium | S | i18n gaps, dead code |
| B13 | **Layout constants** — `kNavBarHeight` + spacing tokens for the magic 64/108/120/140/320 offsets | Low | S | uncoordinated navbar offsets |

**Suggested sequence:** B10 + B1 + B3 first (highest ratio of screens-touched to effort, and unblock
everything visual), then B2 + B4 + B5 (the biggest dedup wins), then B6–B9 feature surfaces, then
B11–B13 hygiene. Each ships behind screen-by-screen verification (Xcode on device).

### Consolidated reusable-component catalog

Union of all clusters (each replaces the noted duplication):

**Foundational:** `PrimaryButton` · `SecondaryButton` · `PillButton` · `DestructiveButton` ·
`AppTextField` (visible focus) · `MirraChip`/`MirraTag` · `BackIconButton` · `MirraDragHandle` ·
`SectionHeader` · `LinkText` · `Avatar(size,url)` · `ProductThumb`.
**Structural:** `MirraBottomSheet` · `MirraDialogCard`+`MirraDialogIcon` · `ConfirmDialog` ·
`ConfirmationSheet` · `MirraInfoCard` · `SettingsScaffold`/`SettingsRow`/`SelectableRow`/`SettingsList`.
**Product/score:** `ProductTile` (merge tiles A+B) · `ScoreBadge`/`ScoreRing` · `ScoreBar` ·
`StatusLegend` · `SeverityTile` · `semanticScoreColor()`+`statusColor()` · `SegmentedToggle`.
**States:** `SkeletonGrid`/`SkeletonTile` · `MirraEmptyState` · `RetryError` · `LoadingSpinner`.
**Feature/paywall:** `PlanCard` · `PriceApproxRow` · `FeatureRow` · `ProPill` · `LimitReached` ·
`FeatureCarouselCard` · `ChecklistItem`.
**Onboarding:** `SelectableChip` · `SelectableOptionCard` · `TermsFooter` · `WeekdayPicker`/`WeekdayCell`.
**Non-UI utilities:** `runAnalysis(source)` pipeline · `formatPrice(amount,code)` · `inciSplit()` ·
`resetLabel()` · `countryName(row,locale)` · `weekdayLabels(locale)` · `kNavBarHeight`.

### New design tokens this review surfaces (beyond Phase 0)

`onPrimary` (on-blue/on-dark text) · semantic `success`/`warning`/`error` **foreground** (Phase 0
added only the `*Bg` tints) · `danger` (destructive) · a **primary-tint ladder** (6/12/20%) ·
`progressTrack`/`skeletonBase` · `navInactive` · a **paywall dark-surface palette** · a `displayXS`
(24–26) type role · standardized grid spacing + a single card radius.

<!-- EXEC_SUMMARY_ANCHOR -->

---

## Cluster 1 — Auth & Onboarding

### Log In Page — `lib/pages/log_in_page/log_in_page_widget.dart`
_Tabbed Login / Create-account screen with animated feature-card carousel background._

| # | Category | Finding (file:line) | Priority | Proposed solution (no code) |
|---|----------|---------------------|----------|-----------------------------|
| 1 | Duplication | The register tab (`_registerForm`, 504–633) duplicates the standalone `CreateAccountPageWidget`; two sign-up flows with divergent styling (`alternate` fill vs `primaryBackground`). | High | Pick one canonical account-creation surface; delete/redirect the other. |
| 2 | Color | Input `focusedBorder` uses `secondaryBackground` (142) while `enabledBorder` uses `alternate` (135) — both white on a white field → **no visible focus state**. | High | Give focus a real token (`primary`, 1.5px), distinct from enabled. |
| 3 | Color | Button label `Colors.white` hardcoded (426, 614); Apple button text uses `primaryBackground` (315) — borrowed unrelated token. | Medium | Introduce `onPrimary` text token; replace raw white. |
| 4 | Accessibility | Password-visibility toggle icon `size:18` (183) in an `InkWell` with no min tap target — hit area well under 44–48px. Repeats on all auth screens. | High | 44×44 min-constrained tap target. |
| 5 | Inconsistency | Back-button here `buttonSize:60/radius:30/icon:30` (652–661) vs ForgotPassword `40/20/24` — two back-button specs in one cluster. | Medium | One standard back-button component. |
| 6 | Duplication | `_termsFooter()` (188–273) near-verbatim copy of CreateAccountPage's (127–208), same hardcoded EULA/privacy URLs. | Medium | Shared `TermsFooter` widget taking the two URLs. |
| 7 | Spacing | Radius soup: inputs 16, buttons 50, tab pill/indicator 30, icon button 30 — four radii, none from `t.radii`. | Low | Map to radius scale (input=16, pill/button=full). |
| 8 | Inconsistency | Button height `55` hardcoded on every FFButton (309, 418, 604) — the "7 button heights" issue. | Medium | Reference one button-height token. |
| 9 | UX-flow | Login form `autovalidateMode: disabled` (335); Log-in button (401) never calls `formKey.validate()` before submit (register does) — invalid input hits network with no inline feedback. | Medium | Validate login form before `signInWithEmail`. |

### Login Feature Cards — `lib/pages/log_in_page/login_feature_cards.dart`
_Three animated marketing cards (score / scan / ingredients) used as carousel items._

| # | Category | Finding (file:line) | Priority | Proposed solution (no code) |
|---|----------|---------------------|----------|-----------------------------|
| 1 | Color | File-local palette bypasses theme: `_kCardBg #F5F8FF`(8), `_kTextPrimary #1A1F2E`(9, a *different* near-black), `_kTextSecondary #6B7280`(10), `_scoreColor #43A047`(44), `dark #3A5CB8`(160), literal `#5C85D9`(213, = theme primary), 3 pill colors (288–290). | High | Replace `#5C85D9`→`primary`; text→`primaryText`/`secondaryText`; promote score/pill colors to semantic tokens. |
| 2 | Typography | All card text is raw `TextStyle` sizes 26/13/11 with **no `fontFamily`** (98–121, 252–266, 326–375) → cards do **not render in Raleway** (default font fallback). | High | Use theme type roles so Raleway + tokens apply. |
| 3 | Accessibility | Sub-text `fontSize:11` (121, 266) and pill labels `11` (372) below the 12px floor. | Medium | Raise to ≥12 / `bodySmall`. |
| 4 | Inconsistency | `_kTextPrimary #1A1F2E` vs `#1A1A1A` elsewhere — two near-identical "blacks". | Medium | Collapse to `primaryText`. |

### Create Account Page — `lib/pages/create_account_page/create_account_page_widget.dart`
_Standalone email/password + Apple sign-up (duplicate of the login page's register tab)._

| # | Category | Finding (file:line) | Priority | Proposed solution (no code) |
|---|----------|---------------------|----------|-----------------------------|
| 1 | Duplication | Whole screen duplicates LogInPage's register tab; ~230 lines of inlined `InputDecoration` (377–573) instead of a shared helper. | High | Consolidate the two flows; extract shared input decoration. |
| 2 | Color | Input fill + all borders use `primaryBackground` (401/411/441) — enabled == focused → **no focus state**; also diverges from the login variant's white fill. | High | Unify field styling; give focus a distinct color. |
| 3 | Color | Dead gradient `alternate → alternate` (254–258) — identical stops, no-op. | Low | Remove the gradient. |
| 4 | UX-flow | Page-level `InkWell` over the whole form (321–333) with an `onTap` that only delays 600ms + haptics — stray no-op. | Medium | Remove the meaningless wrapper. |
| 5 | Inconsistency | `autofocus:true` on **both** email and password (370, 479) — password wins; screen opens focused on password. | Medium | Autofocus email only. |
| 6 | Spacing | Deep nesting with per-widget hardcoded paddings (24/16/8/12); same 55 height / 50 radius. | Low | Flatten; adopt tokens. |
| 7 | Duplication | Second copy of `_termsFooter()` (127–208), same hardcoded URLs. | Medium | Shared `TermsFooter`. |

### Forgot Password — `lib/pages/forgot_password/forgot_password_widget.dart`
_Single-field email entry that sends a reset link._

| # | Category | Finding (file:line) | Priority | Proposed solution (no code) |
|---|----------|---------------------|----------|-----------------------------|
| 1 | Color | Fill + enabled/focused borders all `alternate` (179/186/206) → invisible border + no focus state. | Medium | Visible resting `border` token + `primary` focus. |
| 2 | Accessibility | Feedback strings `'Email required!'`(240), `'Success! Check your inbox…'`(253) are **not localized** (unlike the rest of the screen). | High | Move both into the localization table. |
| 3 | UX-flow | Redundant empty-email guard (236–245) after `formKey.validate()`(232); success SnackBar shows even if `resetPassword` throws (no error handling ~246). | Medium | Drop redundant guard; surface reset failures. |
| 4 | Color | SnackBar `theme.info` text on `theme.primary` bg (259/268) — untokenized pairing, unverified contrast. | Low | On-primary text token. |
| 5 | Inconsistency | Back button `40/20/24` vs LogInPage `60/30/30`; 55 height / 50 radius repeat. | Medium | Standardize back-button + button tokens. |
| 6 | Accessibility | Body helper uses `secondaryText #929292` (142) — ~2.8:1, FAILS WCAG AA. | Medium | Darker token for body copy. |

### Onboarding Profile — `lib/pages/onboarding_profile/onboarding_profile_widget.dart`
_Post-signup profile setup: avatar, name, username suggestions, language/country._

| # | Category | Finding (file:line) | Priority | Proposed solution (no code) |
|---|----------|---------------------|----------|-----------------------------|
| 1 | Typography | Local type scale `_fsTitle 24/_fsBody 16/_fsSub 13` (39–41) applied via `.override(fontSize:)` everywhere; `_fsSub 13` off-scale. | Medium | Use theme title/body/label roles; drop local constants. |
| 2 | Color | Hardcoded `Colors.white` (589/180/299); `Colors.black.withOpacity(0.05)` shadow (183) not `t.shadow`; `accent1` selected chip (508) — undocumented token. | Medium | Route to `alternate`/`primaryBackground` + `t.shadow`; confirm `accent1`. |
| 3 | Inconsistency | Card radius 20 (180), input radius 14 (225/237) — neither matches the 16 used elsewhere nor `t.radii`. | Medium | One input-radius token app-wide. |
| 4 | Accessibility | `_sectionLabel` 13px all-caps `letterSpacing 0.8` (197–203); preset-avatar tiles 44×44 (320) at the tap floor with 10px gaps → mis-taps. | Low | ≥12 non-condensed label; ≥48px avatar targets. |
| 5 | Inconsistency | `surfaceMuted` field (220) vs `alternate` avatar/chips (269/508) — three neutral greys on white with low separation. | Low | Rationalize neutral layering. |
| 6 | UX-flow | Continue button hidden entirely when keyboard visible (649) — small screens may show no way to proceed. | Low | Keep an accessible submit affordance. |
| 7 | Duplication | Avatar picker + preset-grid + chip pattern resemble the quiz's — reimplemented locally. | Low | Extract shared chip + avatar-tile. |

### Onboarding Quiz — `lib/pages/onboarding_quiz/onboarding_quiz_widget.dart`
_8-step skin-profile stepper with a "not sure" sub-quiz._

| # | Category | Finding (file:line) | Priority | Proposed solution (no code) |
|---|----------|---------------------|----------|-----------------------------|
| 1 | Color | A *third* private palette: `_ink #1A1A1A`, `_muted #6B7280`, `_card #F3F4F6`, `_border #E6E6E9` (74–77) — duplicates `primaryText`/`surfaceMuted`/secondary/`divider`; applied via `.override(color:)` on nearly every style. | High | Replace all four with tokens — biggest single tokenization win in the cluster. |
| 2 | Typography | Duplicated local `_fsTitle/_fsBody/_fsSub` 24/16/13 (79–81); pervasive size overrides; `_fsSub 13` off-scale. | Medium | Share one type scale with OnboardingProfile; prefer roles. |
| 3 | Reusable-component | `_optionCard`, `ChoiceChip` styling copy-pasted **3×** (determine miniRow, goals, optional pillRow), `_primaryBtn`/`_secondaryBtn`, progress bar — all local. | High | Extract `SelectableChip` + `SelectableOptionCard` + shared button variants. |
| 4 | Inconsistency | Button heights 55/52/46/46 via one builder; input radius 12 (935) vs card 16 vs dialog 28 (303). | Medium | Constrain to button-height + radius tokens. |
| 5 | Accessibility | Brands autocomplete `TextField` (921–938) `border: BorderSide.none` + fill only → **no focus**; header close icon `_muted #6B7280` (447) low-contrast. | Medium | Add focus border; higher-contrast dismiss. |
| 6 | Inconsistency | Titles use mismatched roles (displaySmall/headlineSmall) all force-overridden to 24 — role choice cosmetic. | Low | One title role, no size override. |
| 7 | Color | Selected-chip/button text hardcodes `Colors.white` (641/819/851/1113). | Low | `onPrimary` token. |

**Reusable components this cluster suggests:** `AuthTextField` (one InputDecoration: 16 radius, `surfaceMuted`/`alternate` fill, visible `primary` focus, built-in 44px password toggle) · `PrimaryButton`/`SecondaryButton`/`AppleButton` (fixed height + `full` radius + `onPrimary` text) · `SelectableChip` + `SelectableOptionCard` · `BackIconButton` (one size/radius/icon) · `TermsFooter` · theme-routed `FeatureCarouselCard` · shared `OnboardingScale` (kills the **three** duplicated private palettes that re-encode existing tokens).

> Cross-cutting in this cluster: **invisible text-field focus states** and **sub-44px password toggles** on every auth screen; **three separate files redefine `#1A1A1A`-ish/grey palettes locally** instead of using tokens.

---

## Cluster 2 — Home, Capture & Navigation

### Home — `lib/home/home/home_widget.dart`
_Main dashboard: greeting, PRO CTA, onboarding pipeline, quota bar, filter chips, product grid._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color | Raw `Colors.white` for surfaces/borders/text (392, 441–444, 526, 643, 764, 949); Home scaffold white but capture uses `theme.alternate` for the same white — inconsistent sourcing. | Medium | One token for white surface + a dedicated on-blue text token. |
| 2 | Color | Quota bar hardcodes `Colors.black` (1155, 1193, 1207) and `Colors.red.shade400/.shade300` exhausted state (1177, 1193). | High | Semantic `error` + `onSurface` tokens; "exhausted" red recurs untokenized in 3 files. |
| 3 | Color | Progress track uses `secondaryBackground` here but `Colors.white24` in startanalys — two track colors for one component. | Medium | One `trackMuted` token. |
| 4 | Typography | Hardcoded sizes bypass roles: greeting 28 (580/609), "My Products" 21 (688), chip 13 (762), quota 12/13. Greeting 28 duplicates displaySmall but applied to bodyMedium. | High | Map to Material roles; stop overriding `fontSize` on bodyMedium. |
| 5 | Duplication | `_HomeQuotaBar` (1123–1229) near-clone of startanalys `_QuotaStatusBar`; `_resetLabel` verbatim in both. | High | Shared `QuotaBar` + `resetLabel()` util. |
| 6 | Duplication | Error+Retry and loading spinner written twice in one widget (400–429 and 791–826); nested FutureBuilders on same future. | Medium | Extract `RetryError`/`LoadingSpinner`; inner FutureBuilder likely redundant. |
| 7 | Reusable-component | PRO CTA (490–540), empty CTA (920–963), capture buttons all bespoke with heights 35/50/65, radii 18/50/36. | High | Single `PrimaryButton`/`PillButton` with tokens. |
| 8 | Spacing | Magic paddings: top 64 (473), chip 18/8 (730), section 27 top (670), grid 10 (1004). | Medium | `t.space` steps; top offset via safe-area not fixed 64. |
| 9 | Accessibility | Avatar 45×45 (632–647) and ~34px chips (729) below 48 min tap target. | High | Enforce 48×48 hit area. |
| 10 | Accessibility | `'Retry'` (410, 805) hardcoded English, not localized. | Medium | Move to translations. |
| 11 | Radii | Chip 20, PRO 18, empty CTA 50, progress 4/6 — four radii. | Medium | Snap to `t.radii`. |
| 12 | UX-flow | Auto-scroll ticker machinery (93–125) has no visible toggle — dead/unreachable. | Low | Confirm intent (flag, don't delete). |
| 13 | Color | Selected-chip text `Colors.white`, empty-subtitle `secondaryText` (fails AA). | Medium | Tokenize on-primary; darken secondary body. |

### Start Analysis card — `lib/home/startanalys/startanalys_widget.dart`
_Gradient "Scan a Product" promo card with quota bar + Start button._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | UX-flow | **Start button does nothing** — `onPressed` is `print(...)` (148); header says "New Component Gen", not imported by Home → likely orphaned. | High | Confirm live/orphaned; wire to capture or flag for removal. |
| 2 | Color | Gradient hardcodes `#A7B6CC` (76); on-gradient text `Colors.white/70/54/24` (94–264). | High | Tokenize gradient pair + on-primary opacity ramp. |
| 3 | Duplication | `_QuotaStatusBar` (194–273) duplicates Home's; `_resetLabel` (44–56) duplicated. | High | Shared `QuotaBar`. |
| 4 | Typography | Quota text raw `TextStyle(fontSize:12/11)` (218/242/251), no font family → Raleway not guaranteed. | High | Use theme roles. |
| 5 | Color | Exhausted `Colors.red[200]/[300]` — a third distinct red. | Medium | One `error` token. |
| 6 | Inconsistency | Start button 54/28 vs capture 65/36 vs Home CTA 50/50 — no shared CTA spec. | Medium | One primary-button spec. |
| 7 | Accessibility | white70/54 quota text on mid-blue gradient, low contrast at 11–12px. | Medium | Raise opacity/size or solid on-primary. |

### Take or Upload (Capture) — `lib/home/takeor_upload_page/takeor_upload_page_widget.dart`
_Camera/gallery capture + animated scanner + hint card + analysis pipeline._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | Camera `onPressed` (869–1348, ~480 lines) and gallery chain (190–572) near-identical branch-for-branch. | High | Extract one `runAnalysis(source)` pipeline. |
| 2 | Color | CTAs use `#D25C85D9`/`#D15C85D9` — alpha-baked `primary` instead of `primary.withOpacity`. | High | `primary` with opacity token. |
| 3 | Color | Many raw hex: dialog `#E3F2FD`/`#1565C0`, hint `#FFF9EB`/`#FBBF23`, scanner `#3A5CB8`/`#5C85D9`. | High | Tokenize accent-amber, info-blue; reuse `primary` for scanner. |
| 4 | Inconsistency | CTA 65/36 vs dialog button 50/14 (`ElevatedButton` not `FFButtonWidget`) — three button systems. | Medium | Unify button component + tokens. |
| 5 | Typography | Hardcoded 18/15/16/14; dialog button raw `TextStyle` (no font family). | Medium | Type roles; ensure Raleway. |
| 6 | Reusable-component | Hand-rolled info `Dialog` (94–186) duplicates `ErrorPopupWidget` pattern. | Medium | Extract `InfoDialog`/reuse ErrorPopup shell. |
| 7 | Spacing | `bottom:320` illustration + `bottom:100+safeArea` action zone — magic offsets coupled to navbar height (108). | Medium | Derive from shared navbar-height constant. |
| 8 | Accessibility | Hint image no semantics; amber check on cream low contrast. | Low | Add semantics; verify contrast. |
| 9 | UX-flow | Failure branches → generic popups + Telegram tech msgs (Russian internal strings); camera vs gallery error UX diverges. | Low | Centralize error mapping. |
| 10 | Duplication | Reset-date logic a third time (`_resetDateString`, 833–842), slightly divergent. | Medium | Fold into shared reset-label util. |

### Home Pipeline checklist — `lib/components/home_pipeline_widget.dart`
_3-step onboarding checklist (profile/bag/routine), self-hides once complete._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color | Raw `Colors.black/black54/white` (107, 173–199); border `#E6E6E6` (96) = `divider` value hardcoded. | Medium | Use `divider`/`primaryText`/`secondaryText`. |
| 2 | Typography | Step number/label raw `TextStyle` (180–195), no font family. | Medium | Theme roles. |
| 3 | Reusable-component | Numbered/checked step circle (167–186) + strike-through row = generic checklist item. | Low | Extract `ChecklistItem`. |
| 4 | Spacing | Card radius 16 + padding 16 + gaps 6/12 — mixed scale. | Low | Align to `t.space`/`t.radii`. |
| 5 | Accessibility | Step rows ≈38px tap targets (164–170), below 48. | Medium | ≥48px hit area. |

### Navbar — `lib/components/navbar/navbar_widget.dart`
_Floating frosted-glass bottom nav (4 tabs) + center scan FAB._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color | Inactive tab `#2C2C2E` hardcoded (108); glass fill/border raw opacities; widget branches on `Brightness.dark` (170) — dead dark-mode code. | Medium | Tokenize nav-inactive + glass; remove dark branch. |
| 2 | Inconsistency | Dead dark-mode branching (170–177) contradicts single-light-theme rule. | Medium | Remove/flag dead branch. |
| 3 | Typography | Tab label forced `fontSize:11` (137) — below 12px floor. | High | ≥12 / label role. |
| 4 | Accessibility | Active/inactive is color+weight only (11px) — weak for color-blind; center FAB 62×62 at align -0.72, verify no overlap. | Medium | Consistent filled/outline active-icon swap. |
| 5 | Inconsistency | Explore tab lacks `activeIconData` (225) while other three have one — active state differs. | Medium | Give Explore a filled active icon. |
| 6 | Spacing | Magic: nav height 108, FAB align -0.72, radius 30, inset 28, blur 18; nav height implicitly depended on by capture offsets. | Medium | Shared nav-height + radius constants. |
| 7 | Color | Inline shadow specs (`primary` alpha .40, black .10) not `t.shadow`. | Low | Shadow token. |
| 8 | UX-flow | Center FAB uses 0ms fade "transition" — boilerplate noise. | Low | Real fade or plain push. |

**Reusable components this cluster suggests:** `QuotaBar` (+ `resetLabel()` util, reimplemented 3×) · `PrimaryButton`/`PillButton` (collapses 35/50/54/65px zoo) · `RetryError` + `LoadingSpinner` · non-UI `AnalysisPipeline` (`runAnalysis(source)`, ~900 duplicated lines) · `InfoDialog` (fold into ErrorPopup) · `ChecklistItem`/`StepIndicator` · semantic tokens forced out: `error`, on-primary opacity ramp, accent-amber, info-blue, `navInactive`, `progressTrack` · shared `kNavBarHeight` constant.

> Non-design flags (report only): `startanalys` Start button is a `print()` stub / likely orphaned; navbar ships dead dark-mode branches.

---

## Cluster 3 — Search & Item Cards

### Search — `lib/search/search_widget.dart`
_Faceted + natural-language search with chip filters, sort, results list._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color | Hardcoded `#F3F4F6` (359/534), `#E0E0E0` (537), `#1A1A1A` (545) despite existing tokens. | High | Swap for `surfaceMuted`/`border`/`primaryText`. |
| 2 | Typography | Sub-12/ad-hoc: count 11 (494), chips 13 (544), "not parsed" 12 (414). | Medium | Type scale; enforce ≥12. |
| 3 | Accessibility | Hint at `secondaryText.withOpacity(0.5)` (354) — well below AA (secondary already fails). | High | Darker placeholder; never fade a borderline grey. |
| 4 | Accessibility | Chip ≈34px (532) + 18px clear icon — below 44px. | Medium | ≥44px hit area. |
| 5 | Reusable-component | `_chip()` (522) reinvented as best-for/SPF pills in itemcard2 & product_card_v2. | High | One `MirraChip`/`MirraTag`. |
| 6 | Inconsistency | Four radii: input 12, chips 20, search 14, load-more 12 / remove 10. | Medium | Collapse to `t.radii`. |
| 7 | Inconsistency | Button heights AI 44 / Search 52 / Load-more 48. | Medium | Standardize primary/secondary. |
| 8 | UX-flow | Two overlapping search triggers (AI parse auto-runs + separate Search button). | Medium | Merge affordances / clarify. |
| 9 | Reusable-component | Results reuse `ImagedetailedMainWidget` (300px grid tile w/ unused stars) inside a list → nested scrollables, empty star gap. | High | Use a compact list-row card. |
| 10 | Duplication | Inline 11-language label maps (57–119) duplicate `FFLocalizations`. | Low | Move to i18n table. |

### Product detail (itemcard2) — `lib/itemcard2/itemcard2_widget.dart`
_Full product detail page: hero, fit card, SPF/price/how-to, INCI, SpeedDial of actions._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Reusable-component | Three info cards rebuilt inline w/ own bg+radius+shadow: SPF `#E8F4FD` r20, Price `#F5F8FF` r20, How-to `#F5F8FF` r24; same shadow copied 3×. | High | One `MirraInfoCard(bg, child)`. |
| 2 | Color | Hardcoded hues `#A7B6CC`, `#1565C0`/`#2E7D32`, glass whites, back-button `#2B5C85D9` (hand-tinted primary). | High | Tokenize; derive tints from `primary` opacity. |
| 3 | Inconsistency | Hero score chip shows ingredient-recognition % next to flask — reads as a product score competing with the real fit score. | High | Relabel/move; don't headline "% recognized". |
| 4 | Accessibility | best-for tags white on 38% white pills over photo; hero text over arbitrary image w/ only top gradient. | Medium | Solid tag chips; bottom scrim behind hero text. |
| 5 | Duplication | Currency logic (228–250) a third copy of the symbol map. | Medium | Single `formatPrice`. |
| 6 | Spacing | Every block re-declares `fromSTEB(16,16,16,0)`. | Low | Drive from `t.space`. |
| 7 | Typography | Hero 16/20, SPF/how-to 16/18, price 22 — bypass scale. | Medium | Material roles. |
| 8 | UX-flow | ~11 actions in one SpeedDial, all same style — no grouping of destructive vs benign. | Medium | Group/color destructive; consider sheet. |
| 9 | Inconsistency | Hand-built circular back button vs plain IconButton in search. | Low | Shared back button. |

### Fit card (ProductCardV2) — `lib/components/product_card_v2/product_card_v2_widget.dart`
_"Answer-first" analysis card: verdict + fit ring, skin-type matrix, actives, warnings, claims, pro layer._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Inconsistency | Score→color uses 3 bands (105–109) but tiles use 6 bands — same score, different color per screen. | High | One shared `scoreColor(score)`. |
| 2 | Color | Dead `_isDark` branch (97–103) in a light-only app; hardcodes `#1B5E20`/`#FFB300`/`#D32F2F` not tokens. | Medium | Drop dark branch; use semantic tokens. |
| 3 | Reusable-component | Section header re-declared 6× (280/376/479/558/662/738). | Low | `_SectionHeader(label)`. |
| 4 | Reusable-component | Traffic-light dot/label overlaps warnings icon + INCI legend — three status systems. | Medium | Unify status color/legend. |
| 5 | Color | Card uses `alternate` as surface, matrix bar `primaryBackground` — semantic mismatch. | Low | Real `surface`/`card` token. |
| 6 | Accessibility | Fixed `width:130` label + `width:28` score column clip long de/ru labels. | Low | Flexible width/wrap. |

### Grid tiles A & B — `imagedetailed_main` + `imagedetailed_top_raited`
_Two product tiles; A adds stars/SPF/gradient, B is stripped._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | **A and B are the same card** — duplicate `_scoreColor`, `_grade`, `_formatCardPrice`, `_ScoreBadge`, image block. | High | Merge into one `ProductTile(showStars, showSpf, variant)`; delete B. |
| 2 | Inconsistency | Root is a `ListView` to render one non-scrolling card → nests scrollables. | Medium | Use `Column`. |
| 3 | Color | Score palette `#1B5E20…#D32F2F` (third copy); SPF `#1565C0`, price `#333333`. | High | Shared `scoreColor` + tokens. |
| 4 | Inconsistency | B's shadow differs from A (4-blur vs 8-blur+glow) — "same" card looks different. | Medium | One shadow token. |
| 5 | Accessibility | Stars = 5 copy-pasted Icon blocks, no semantics; grade color-only. | Low | Rating widget + semantics + text. |
| 6 | Inconsistency | Radii 24/16/16/8 on one tile. | Low | Token set. |

### INCI list (Ingridients) — `lib/item_card/ingridients/ingridients_widget.dart`
_Ingredient list highlighting active (green) / problem (red) inline._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color | `#1B5E20`/`#E8F5E9`/`#B71C1C`/`#FFEBEE` (27–30) — a 4th status palette. | High | Shared `success`/`error` + `*Bg`. |
| 2 | Inconsistency | Exact-string comma split breaks "1,2-Hexanediol" where fit card uses regex split. | Medium | Reuse shared INCI-split util. |
| 3 | Typography | Body `fontSize*0.8` ≈ 11px; `letterSpacing:1.0` on a paragraph. | Medium | ≥12 role; drop wide tracking. |
| 4 | Accessibility | "Active"/"Issues" hardcoded English. | Medium | Localize. |
| 5 | Accessibility | Highlight is background-color only (not colorblind-safe). | Low | Add icon/underline; verify contrast. |

### Confirm dialogs — `deleteitem` + `markasspam`
_Two destructive-confirm modals with incompatible styling._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | Two confirm dialogs, incompatible: deleteitem center `ElevatedButton` r20/r14 red `#D32F2F`; markasspam `FFButtonWidget` r16/r8 side-by-side. | High | One `ConfirmDialog(title, body, confirmLabel, destructive)`. |
| 2 | Color | deleteitem `#FFEEEE`/`#D32F2F`; markasspam confirm `#1976D2` (NOT app primary), text `info` on blue. | High | Tokenize destructive; use `primary` for hide. |
| 3 | UX-flow | deleteitem stacks destructive on top (most prominent), Cancel a ghost below. | Medium | De-emphasize destructive / Cancel first. |
| 4 | Inconsistency | markasspam fixed `width:140` in spaceBetween row overflows long labels. | Medium | Use `Expanded`. |

> **item_card vs itemcard2 vs product_card_v2:** `item_card/` is a grab-bag of the old page's sub-parts (2 tiles, INCI, 2 dialogs); `itemcard2/` is the current detail page but still composes `item_card/ingridients` + dialogs and delegates analysis to `product_card_v2` — so the "v2" split is half-done. Three independent score→color systems (tile 6-band, fit 3-band, INCI) mean one product shows different colors on the search tile vs the fit card.

**Reusable components this cluster suggests:** `ProductTile` (merge tiles A+B, grid/list variants) · `ScoreBadge` + `scoreColor(score)` + `gradeFor(score)` · `MirraChip`/`MirraTag` · `MirraInfoCard` · `ConfirmDialog` · `formatPrice(amount, code)` · `inciSplit()` + INCI-highlight tokens · `SectionHeader` + shared `BackButton`. Token gaps: real `surface`/`card` (today `alternate` overloaded), semantic `success/warning/error(+Bg)`, remove dead dark branch in product_card_v2.

---

## Cluster 4 — Scoring, Compatibility & Sharing

> **Cluster headline:** four mutually-contradictory good/bad color scales and three different score scales — the same "this is good/bad" concept is drawn in a different color on every screen.

### Compatibility Result — `lib/pages/compatibility_result/compatibility_result_widget.dart`
_Routine analysis: score ring + summary + conflicts + AM/PM routine (Pro)._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color | Score ring uses `theme.primary` (blue) for ALL scores 0–10 (680–697) — a 2/10 and 9/10 render identical. No good/bad signal. | High | Shared semantic score-color drives the ring. |
| 2 | Color/a11y | Conflict severity by icon tint alone: `#D9534F`/`#E07A5F`/`black54` (571–575) — color-only, hues match no other file. | High | Add severity label/shape; pull red/amber from tokens. |
| 3 | Color | Pervasive `Colors.black/black54` for text; `#E6E6E6` border + ring track duplicate `divider`. | Medium | Tokens; black54 body → `secondaryText`. |
| 4 | Typography | Day chip 11px (549); ring overrides displaySmall to 34 + `.bold` (703–704). | Medium | `t.size` scale; min 12; `w700`. |
| 5 | Inconsistency | Score scale 0–10 here; radar & share card 0–100. | Medium | Standardize on one scale. |
| 6 | Reusable-component | `_ScoreRing`, `_SectionTitle`, `_ConflictTile`, `_GapTile`, day-pill all bespoke. | Medium | Extract ScoreRing/SectionHeader/SeverityTile. |
| 7 | Spacing | `circular(25/14/10)` — no `t.radii`. | Low | Map to radius tokens. |

### Score Breakdown (Radar) — `lib/components/score_breakdown/score_breakdown_widget.dart`
_5-axis radar with ingredient dots._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color/Inconsistency | Status palette green `#2E7D32`/amber `#F9A825`/grey `#9E9E9E` (372–386) — bubbles use working=amber `#FFB300`, borderline=steel `#78909C` for the SAME statuses. Contradictory legends. | High | Single shared `statusColor(status)`. |
| 2 | Color | Issue dots two reds (`#C62828`/`#E53935`, 407); legend shows only `#E53935`; polygon `#3B6FCC` ≠ app primary. | High | One error token + severity size; align polygon to `primary`. |
| 3 | Typography/a11y | Extreme sub-12: axis label 9.5, score 9, 1% label 8, legend 9.5. | High | ≥11–12 or move scores out of painter. |
| 4 | Color | Label ink `#445588`/`#667799` ad-hoc slate-blues; grid `#14000000`/`#1A000000`. | Medium | Tokenize to `secondaryText`/`border`. |
| 5 | a11y | Dot meaning color+fill only; legend is the only key. | Medium | Add shape/pattern differentiation. |
| 6 | Duplication | `_drawCentered` defined but unused. | Low | Flag for removal. |

### Ingredient Bubbles — `lib/components/ingredient_bubbles/ingredient_bubbles_widget.dart`
_Animated floating bubbles per top ingredient, colored by dose status._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color/Inconsistency | Palette `#FFB300`/`#78909C`/`#90A4AE`/`#BDBDBD` (7–10) conflicts with radar's green/amber for identical statuses. | High | Unify on shared `statusColor`. |
| 2 | a11y | Status by bubble color only; tooltip label also color-coded. | High | Pair color with icon/label; check tooltip contrast. |
| 3 | Typography | Label shrinks to 7.0px floor (308); tooltip 12/11; conc `#888888` 11. | Medium | Raise floor; conc → `secondaryText`. |
| 4 | Inconsistency | Deprecated `.withOpacity()` while siblings use `.withValues`. | Low | Align on `withValues`. |
| 5 | Color | Ink via `Color.lerp(bubbleColor, #1A1A1A, 0.7)` — hardcoded near-black. | Low | Lerp target `primaryText`. |

### Score Card (custom_code) — `lib/custom_code/widgets/score_card.dart`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | Dead code | Entire widget stub: `build` returns empty `Container()` (35–37); all params unused. | Medium | Confirm unused / repurpose as home for shared ScoreRing (flag only). |

### Share Card (render) — `lib/custom_code/widgets/share_card_widget.dart`
_Renders shareable image: score badge + grade + 5 mini-bars + highlighted INCI._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color/Inconsistency | `_scoreColor` is a **6-stop** ramp `#1B5E20…#D32F2F` (34–41) — a third distinct ramp. | High | Base on the one shared semantic scale. |
| 2 | a11y | INCI highlights use red-bg vs green-bg only (306–309) — classic red/green colorblind failure. | High | Add ✓/! marker or underline. |
| 3 | Typography | Mini-bar label/value 7.5px (259/288), footer/badge 9. | High | Raise to ≥9–10; rely on export scale. |
| 4 | Color | `primary #5C85D9`/`#F5F7FF` re-declared as consts in 3 classes (justified: no context during capture). | Medium | Single shared `MirraBrand` const. |
| 5 | Reusable-component | Score badge + mini-bar reusable on the in-app product page. | Medium | Extract ScoreBadge/ScoreBar. |
| 6 | Color | Ad-hoc greys `#BBBBBB`/`#888888`, `black.withOpacity(0.4)`. | Low | Tokenize. |

### Share Card Sheet — `lib/components/share_card_sheet_widget.dart`
_Bottom sheet: Story/Square toggle + live preview._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | UX-flow/Duplication | Sheet passes only a subset to `ShareCardWidget` (222–251) — omits topIngredients/issues/stability/verdict/lang; page passes all. Two entry points render materially different cards. | High | One shared data-loading path so both render identical complete cards. |
| 2 | Color | Selected toggle uses `#1A1A1D` (130–188) — near-miss of `primaryText #1A1A1A`. | Medium | Use `primaryText`. |
| 3 | Reusable-component | Story/Square selector = duplicated 40-line InkWell blocks. | Medium | `SegmentedToggle`. |
| 4 | Color | Sheet surface uses `alternate` where others use `surfaceMuted`. | Low | Confirm surface token. |

### Share Product (page) — `lib/shareproduct/shareproduct_widget.dart`
_Full-screen share page: back button + complete card._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | Hosts same `ShareCardWidget` w/ full params; ~40 lines of `valueOrDefault` wiring duplicated vs sheet. | Medium | Shared builder both call. |
| 2 | Color/Spacing | Card shadow `black.withOpacity(0.12)` + `circular(20)` duplicates score_breakdown/tooltip. | Medium | Map to shadow/radius tokens. |
| 3 | Accessibility | Back is bare `Icon` in InkWell, no min target/semantics. | Low | `IconButton` 48px + tooltip. |

**Reusable components this cluster suggests:** `semanticScoreColor(score, scale)` + `statusColor(status)` (ONE ramp + ONE dose palette — kills the contradictions) · `ScoreRing`/`ScoreBadge` · `ScoreBar` · `SeverityTile` · `SectionHeader` · `SegmentedToggle` · `StatusLegend` (fed by shared statusColor) · shared `ShareCard` data-builder · brand constants. Cross-cutting: standardize score scale (0–10 vs 0–100), kill sub-12 text (7.5px mini-bars, 8–9.5px radar), replace color-only good/bad with icon/label cues.

---

## Cluster 5 — Profile, Routine & Settings

### Profile — `lib/pages/profile/profile_widget.dart`
_Account hub: avatar/name, premium & settings rows, language/region links, session actions._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Reusable-component | Settings-row pattern hand-copied 6× + a 7th variant (~300 lines, 217–810). | High | One `SettingsRow(icon, label, onTap, {trailingValue})` fed from a list. |
| 2 | Inconsistency | "Your Region" row (749–796) nested Expanded+Column while siblings are flat Text — taller/misaligned. | Medium | Normalize to `SettingsRow`. |
| 3 | UX-flow | Region/Language rows never show current selection. | Medium | Show current value as trailing text. |
| 4 | Color | Hardcoded env badge `#CCFF6B00`, anon `Colors.black`, sign-in/out `#E7E8EB`, dev buttons `#FFE0E0`/`#FF5963`. | High | Tokens; gate dev buttons behind a debug constant. |
| 5 | Inconsistency | Row border = same color as fill (`primaryBackground`) — no-op border repeated. | Low | Drop or use `border` intentionally. |
| 6 | Accessibility | `secondaryText` chevrons/labels fail AA; 11px env badge sub-12. | Medium | `textTertiary`/`primaryText`; badge ≥12. |
| 7 | Spacing | Magic `top:64`, `addToEnd(140)`, avatar clip radius 240. | Low | `SafeArea` + named navbar-inset; `t.radii.full`. |
| 8 | Inconsistency | Avatar 120 vs anon 96; button heights 55/35; radii 16/30/50/6. | Medium | Standardize avatar/button/radius. |

### Edit Profile — `lib/pages/edit_profile/edit_profile_widget.dart`
_Edit avatar (upload/preset) + first/last name._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | 8 preset-avatar InkWells copy-pasted (~18 lines each, 441–752), differ only by URL. | High | Map over a URL list into `AvatarChoice`. |
| 2 | Duplication | First/last name fields duplicate ~120 lines of `InputDecoration` (770–1027). | High | Shared `ProfileTextField`. |
| 3 | Typography | Title forces `GoogleFonts.roboto` 18px (168); picker uses `'Sora'` (282) — both violate single-Raleway. | High | Use titleLarge (Raleway); pass Raleway to picker. |
| 4 | Inconsistency | Save differs by field: focus-listener vs onFieldSubmitted vs Save — three paths. | Medium | Single save path. |
| 5 | Accessibility | Hint uses `primaryText` (no distinction); focus border `secondaryBackground` (near-invisible). | Medium | Hint→`secondaryText`; focus→`primary`. |
| 6 | UX-flow/Bug | Back calls `pushNamed(Profile)` not `safePop` (stacks Profiles); dead 1px transparent share button `print`s. | Medium | `safePop`; delete placeholder. |
| 7 | Color/Dead | `Colors.white` Save text; empty Material→ClipRRect→Container renders nothing. | Low | Tokenize; remove dead block. |
| 8 | Inconsistency | Field radius 16 vs Save 50; avatar clip 280 vs Profile 240. | Low | Align radii + shared Avatar. |

### Routine Calendar — `lib/pages/routine_calendar/routine_calendar_widget.dart`
_Pro routine: weekday selector + AM/PM sections w/ per-part time & push toggle; add/edit sheets._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color | Almost entirely bypasses tokens: `Colors.white/black`, `#E6E6E6`, `#F4F4F4`, `#AEAEAE`, `#F2F2F2`, `#F7F7F7`, black54/38/26, `#E53935`, plus disabled purples `#B0A6C9`/`#9A8FBF` (not brand blue). | High | Re-map to `border`/`surfaceMuted`/`textDisabled`/`error`; purple → primary-derived tint. |
| 2 | Reusable-component/Inconsistency | Two weekday selectors coexist: `_DaySelector` (40×48, r14, #E6E6E6) and `_DayChip` (38×40, r12, #F4F4F4). | High | One `WeekdayCell` (selected/idle). |
| 3 | Duplication | Weekday-chip row + select-all/clear duplicated in `_EditReminderSheet` and `_AddFromBagSheet`. | High | Extract `WeekdayPicker`. |
| 4 | Duplication | 44×44 `spa_outlined` thumb appears in `_DaySection` + `_EditReminderSheet`. | Medium | Shared `ProductThumb`. |
| 5 | Typography | Sub-12/near-12: howTo 12.5, step 12, chips/selector 13 — raw `TextStyle`. | High | Theme roles ≥12; 12.5 off-scale. |
| 6 | Accessibility | Idle chip `#AEAEAE` on `#F4F4F4` + black26/38 icons fail AA; push is a custom checkbox not `Switch`; time-pill has no affordance label. | Medium | Darken idle to `textTertiary`; real `Switch`; add edit affordance. |
| 7 | Inconsistency | Primary button 52 here vs 55 elsewhere; radii 26/14/12/10/8; raw `ElevatedButton`. | Medium | One primary-button + radius scale. |
| 8 | i18n/UX-flow | Weekday labels hardcoded ru-vs-else (35–38) — Spanish shows English; title style differs from settings. | Medium | Localize weekday labels; unify title. |

### Countries — `lib/settings/countries/countries_widget.dart`
_Region picker; writes country_id on tap._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Reusable-component | Selectable row structurally identical to Langs. | High | Shared `SelectableRow`. |
| 2 | Color | Radio/check icons `#555555` (296/304) = `textTertiary` value hardcoded. | Medium | Use `textTertiary`; selected check → `primary`. |
| 3 | Accessibility/UX | Selected state = same-grey check + 2px border — weak. | Medium | `primary` selected check. |
| 4 | Typography | Title `GoogleFonts.sora` 24 (105) — Raleway violation; body `fontSize:16` overrides ×3. | Medium | Title→Raleway role; drop overrides. |
| 5 | Inconsistency | Raw `Colors.white` scaffold (82–84) vs Edit Profile `primaryBackground`; has an intro line Langs lacks. | Low | Unify background + header. |
| 6 | Duplication | Locale→country-name branch duplicated; also in CountrySelector. | Low | Extract `countryName(row, locale)`. |

### Langs — `lib/settings/langs/langs_widget.dart`
_Interface-language picker over kAppLanguages._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | Row markup near-verbatim copy of Countries (129–174). | High | Same shared `SelectableRow`. |
| 2 | Inconsistency | Countries uses SingleChildScrollView+ListView.separated; Langs uses Expanded+ListView.divide — two idioms for identical screens. | Medium | One `SettingsList` wrapper. |
| 3 | Color | Selected check `#555555` not `primary`. | Medium | `primary` selected. |
| 4 | Typography | Title Sora 24; label 16 override. | Medium | Single settings-title (Raleway). |
| 5 | Inconsistency | No intro line where Countries has one. | Low | Shared header pattern. |

### Country Selector (component) — `lib/components/countryselector/countryselector_widget.dart`
_Searchable region dropdown used outside settings._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | Second region-picker UI; re-implements ru/es/else name mapping. | Medium | Share `countryName`; consider one picker. |
| 2 | Inconsistency | Height 50/radius 16/elevation 2 differ from settings rows (r12, no elevation). | Low | Align radius/height. |
| 3 | Reusable-component | 8 style-override params added for one caller. | Low | Named variant instead of speculative flexibility. |
| 4 | Color | Fallback strings hardcoded; `textColor` may resolve null. | Low | Default `primaryText`; fallbacks in translations. |

**Reusable components this cluster suggests:** `SettingsRow` (collapses 7 Profile rows, surfaces current values) · `SelectableRow` + `SettingsList` (Langs/Countries) · `SettingsScaffold`/shared title style · `WeekdayPicker` + `WeekdayCell` · `ProductThumb` · `Avatar(size, url)` · `PrimaryButton` (one height/radius/disabled state, kills off-brand purple) · helpers `countryName(row, locale)` and localized `weekdayLabels(locale)`.

---

## Cluster 6 — Cosmetic Bag & Boards

### Cosmetic Bag — `lib/pages/cosmetic_bag/cosmetic_bag_widget.dart`
_Persistent grid of product slots with a cached compatibility-score header._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Color | Hardcoded `Colors.white/black/black54` (212–455) bypass tokens. | High | Route through tokens; keep raw white only for on-primary label. |
| 2 | Color | Warning/stale `#E07A00` repeated 4× (345–487) for two meanings (stale + not-in-calendar). | High | Introduce `warning` token; reuse. |
| 3 | Accessibility | Stale-compat text 12px raw `TextStyle` (351–354). | Medium | `bodySmall` ≥12; check `#E07A00` contrast. |
| 4 | Reusable-component | `_AddSlotTile`/`_BagTile` bespoke square cells (r16, primary border) — same family as Boards `_AlbumCard` and intro `_SlotCard`, each re-implemented. | High | Shared `ProductGridTile` (filled/empty/add). |
| 5 | Inconsistency | Grid aspect 0.82 vs Boards 0.87 vs Masonry; spacing 14 vs 12. | Medium | Standardize grid spacing + aspect. |
| 6 | Spacing | Magic `SizedBox(height:120)` navbar clearance. | Low | Shared bottom-inset constant. |
| 7 | Typography | Radius literals 20/16/56 mixed. | Medium | Map to `t.radii`. |
| 8 | Color | Score circle `primary` alpha .12 vs newboardempty .06/.11 vs full primary — inconsistent tint ladder. | Low | Fixed primary-tint scale (6/12/20%). |

### Cosmetic Bag Intro — `lib/pages/cosmetic_bag_intro/cosmetic_bag_intro_widget.dart`
_Onboarding: 3 placeholder slot cards + scan CTA, then compatibility teaser._

| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | `_SlotCard` (299–381) is a row variant of the grid tiles — duplicated slot concept. | High | Fold into shared slot component w/ layout prop. |
| 2 | Color | Hardcoded `Colors.black/black54`, `#E6E6E6` (divider value). | High | `divider`/`secondaryText`. |
| 3 | Typography | `fontSize:24/15/16` overrides. | Medium | Roles without overrides. |
| 4 | Inconsistency | CTA `ElevatedButton` 56/30 vs siblings' `FFButtonWidget` 55/50/30/24 — three button systems. | High | One button component/height/radius. |
| 5 | Accessibility | Empty-slot border `#E6E6E6` 1px near-invisible; verify black54 contrast. | Medium | Thicken/darken affordance. |
| 6 | Spacing | Slot height 84, avatar 60, gaps 14/12 — differ from main bag. | Low | Share metrics via component. |

### Albums List (sheet) — `lib/boards/albumslist/albumslist_widget.dart`
| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Reusable-component | Sheet chrome (r24 top, 100×5 handle on `info`, 16/12/16/32 padding) copy-pasted across albumslist/edit_album/new_album. | High | `BottomSheetScaffold`. |
| 2 | Inconsistency | `check_box` here vs no-selection elsewhere vs `check_circle` in intro — selection iconography differs app-wide. | Medium | One selected/unselected icon pair. |
| 3 | Accessibility | Untranslated `'Untitled'` (150). | Low | Localize. |
| 4 | Color | Selected border toggles primary/transparent; row 52; Apply 55/30 — untokenized. | Medium | Spacing/radius tokens. |
| 5 | Inconsistency | Opaque FF hash localization keys with no comment (boards screen comments them). | Low | Add label comments. |

### Boards (grid) — `lib/boards/boards/boards_widget.dart`
| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | Query blocks duplicated in `initState` and `_refresh` (37–58). | Medium | `_buildFutures()` helper. |
| 2 | Reusable-component | `_AlbumCard` + 4-cell mosaic (r12, 2.5/9px gutters) — separate grid system from bag tiles. | High | `AlbumCoverCard`, unify with `ProductGridTile`. |
| 3 | Inconsistency | New-board button 40/24 vs NewAlbum 55/50 vs newboardempty 52/24 — same action, three styles. | High | One primary-button spec. |
| 4 | Spacing | Hardcoded `top:64` instead of `SafeArea`; magic mosaic gutters. | Medium | `SafeArea`; gutter from spacing token. |
| 5 | Empty-state | Renders `NewboardemptyWidget` — one of FOUR empty-state variants. | High | Consolidate into one `EmptyState`. |
| 6 | Color | `Colors.white`/transparent overrides; inlined 50×50 spinner. | Low | Tokenize spinner size. |
| 7 | Duplication | `GestureDetector` unfocus wrapper repeated here + imagesby_album. | Low | Shared `DismissKeyboard`. |

### Edit Album (sheet) — `lib/boards/edit_album/edit_album_widget.dart`
| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | Input decoration near-identical to new_album (r16 vs r24) — divergent copies. | High | Shared `AppTextField` factory. |
| 2 | Inconsistency | Field radius 16 here vs 24 in new_album. | Medium | One input radius token. |
| 3 | Accessibility | Hardcoded `'Delete'` (83) + `#D32F2F` (84); delete button uses `theme.tertiary` (destructive via unrelated token). | High | Localize; `error`/`danger` token. |
| 4 | Reusable-component | Same sheet chrome as albumslist/new_album; two full-width buttons 55/50. | High | Shared sheet scaffold + button pair. |
| 5 | UX-flow | `safePop()` then `Navigator.pop()` both called — double pop. | Medium | Single dismissal path. |
| 6 | Typography | Title 20 / dialog title 17 override headlineSmall inconsistently. | Low | Role sizes. |

### Images by Album — `lib/boards/imagesby_album/imagesby_album_widget.dart`
| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Accessibility | Back/edit icons + title colored `primaryBackground` (119/142/166) — white-on-white risk (inverted-token bug). | High | Use `primaryText` on white AppBar. |
| 2 | Empty-state | Inline bespoke empty state (233–265) — a FIFTH pattern. | High | Consolidated `EmptyState`. |
| 3 | Inconsistency | Masonry spacing 10 vs Boards 12 vs bag 14. | Medium | Standardize image-grid spacing. |
| 4 | Duplication | 50×50 spinner block appears 3×. | Low | Shared `LoadingSpinner`. |
| 5 | UX-flow | Edit sheet nests two tap-to-pop GestureDetectors — fragile. | Low | Use built-in barrier dismiss. |
| 6 | Spacing | `toolbarHeight:80` + `maxWidth:600` only here. | Low | Tokenize; document max-width. |

### New Board Empty — `lib/boards/newboardempty/newboardempty_widget.dart`
| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Empty-state | One of 4/5 variants; full illustrated + CTA vs imagesby_album's minimal — inconsistent richness. | High | One `EmptyState` with optional CTA slot. |
| 2 | Color | Deprecated `.withOpacity(0.06/0.11)`; tint ladder differs from bag 0.12. | Medium | `withValues`; align tint tokens. |
| 3 | Inconsistency | CTA 52/24/w500 vs new_album 55/50/w600 — same action, different button. | High | One primary-button spec. |
| 4 | Reusable-component | Concentric-circle icon hero — reusable motif. | Low | Extract `IllustratedIcon`. |

### New Album (sheet) — `lib/components/new_album/new_album_widget.dart`
| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | UX-flow | Hardcoded depositphotos.com stock URL as default cover (205) — external/watermarked image in prod data. | High | Bundled asset or null cover. |
| 2 | Duplication | Same sheet chrome + input as edit_album (r24 vs r16; focus `primaryBackground` vs `primary`). | High | Shared scaffold + input factory. |
| 3 | Inconsistency | Two stacked buttons 55/50; Cancel `info` fill+border — a fourth button treatment. | Medium | Primary/secondary variants once. |
| 4 | Typography | Title 26 w700 override; `lineHeight:1.1`. | Low | Role scale. |
| 5 | Color | `info` used as both field bg and button bg — semantic overload. | Medium | Use `surfaceMuted`/`border`. |

### Blank Album — `lib/components/blank_album/blank_album_widget.dart`
| # | Category | Finding (file:line) | Priority | Proposed solution |
|---|----------|---------------------|----------|--------------------|
| 1 | Duplication | 8 grid items fully copy-pasted (176–329), ~150 lines that should be ~15. | High | `List.generate(8, ...)` + computed delay. |
| 2 | Empty-state | A FOURTH empty variant; looping fade reads as loading not empty. | High | Consolidate; decide loading vs empty. |
| 3 | Inconsistency | Card radius 8 vs boards 12 vs bag 16; fixed 100×150 in a flexible masonry. | Medium | One placeholder radius; let grid size. |
| 4 | UX-flow | `loop:true` animations run indefinitely — battery cost on a static screen. | Medium | Play once / drop loop. |
| 5 | Accessibility | `titleLarge` label over 0.4-opacity animated cards — no contrast guarantee. | Low | Solid backdrop/scrim. |

**Reusable components this cluster suggests:** `BottomSheetScaffold` (r24 top + 100×5 handle + standard padding) · `AppTextField`/InputDecoration factory · `PrimaryButton`/`SecondaryButton` (replaces 5 treatments: h56/r30, h55/r50, h40/r24, h52/r24, h55/r30) · `ProductGridTile`/`SlotCard` (grid+row) · `AlbumCoverCard` + mosaic · `EmptyState` (replaces newboardempty, blank_album, imagesby_album inline, empty_gallery, no_images) · `LoadingSpinner` · missing tokens: `warning #E07A00`, `danger/error #D32F2F`, primary-tint ladder (6/11/12%), standardized grid spacing + card radii.

---

## Cluster 7 — Top-Ratings & Paywall

### Toprated (feed) — `lib/topratings/toprated/toprated_widget.dart`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | Color | `Scaffold`/sheet `Colors.white` (465/176) hardcoded. | High | Theme background tokens. |
| 2 | Inconsistency | Facet/sort/empty labels are inline `lang=='ru'?…:…` ternaries while the app uses `FFLocalizations` — two localization systems in one file. | High | Move sheet strings into `kTranslationsMap`. |
| 3 | Spacing/Radii | New radii 24/20/14 + button 52; chip 14×8 — not shared with confirmation sheets. | Medium | Adopt `t.radii`/`t.space`; reuse chip + button spec. |
| 4 | Reusable-component | Filter-chip written twice in one sheet (facets vs sort). | Medium | One `FilterChip`. |
| 5 | Accessibility | Filter icon-only button no semantics; color-only selection. | Medium | Semantics label; non-color affordance. |
| 6 | Color | Selected-chip/Apply text `Colors.white`; handle `secondaryText.withOpacity(0.3)`. | Low | On-primary token. |

### TopRatedProductsPage (banner) — `lib/topratings/topratedproductspage/topratedproductspage_widget.dart`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | Color | `#FFF4E6` well + `Colors.orange` icon (60/67) — off-palette warm tones in a blue app. | High | `warningBg`/tokenized accent. |
| 2 | Inconsistency | Card r24 + icon r20; `alternate` surface — differs from sibling cards (`secondaryBackground`/r16). | Medium | Align radius + surface token. |
| 3 | Reusable-component | Icon-well + title + subtitle = same hero as emptytopfindings/out_of_generations. | Low | Extract `InfoHero`. |

### EmptyTopFindings — `lib/topratings/emptytopfindings/emptytopfindings_widget.dart`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | Color | Body copy in `primary` blue (51) — brand color as paragraph text, low readability. | Medium | `secondaryText`/`textTertiary`. |
| 2 | Duplication | Third distinct "empty top findings" message (toprated also has inline `xtop_empty` + `No results found`). | Medium | One empty-state component + string. |

### Confirmation/visibility sheets (GROUPED) — `copyitem`, `hidenavailability`, `makeprivate`, `makepublic`, `makepubluc`
_Five near-clone modal cards; identical shell (r16 container, `#33000000` shadow, headlineSmall title + bodyMedium body, 140×44 r8 button)._

| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | **Duplication (critical)** | **`makepublic` and `makepubluc` are the same screen** — identical title/body/button keys and layout; `makepubluc` is a misspelling of "public", a redundant copy. | High | Delete `makepubluc`; keep one `makepublic`; fix the typo. |
| 2 | Duplication | make/hide/copy are ~99% identical single-button sheets differing by 2 string keys. | High | One `ConfirmationSheet({title, message, primaryLabel, onPrimary, secondaryLabel?, onSecondary?})` — kills ~5×120 lines. |
| 3 | UX-flow | Dismiss inconsistent: `hidenavailability` has a barrier tap-dismiss; the other four don't. | Medium | Standardize dismiss in the shared component. |
| 4 | Color | `copyitem` hardcodes `Colors.white`/`Colors.black`/`#757575`; siblings correctly use `secondaryBackground`/`secondaryText`. | High | Tokenize (the merge removes drift). |
| 5 | Accessibility | `secondaryText` body fails AA; copyitem cancel `#757575` on `border` low contrast. | Medium | `textTertiary` body; readable cancel. |
| 6 | Inconsistency | Docstring "popup for item deleting confirmation" pasted onto all though none delete. | Low | Fix comments. |
| 7 | Reusable-component | `makepubluc`/`makeprivate` declare unused `imageid` param. | Low | Drop dead params in the merge. |
| 8 | Spacing/Radii | Button 140×44 r8 here vs 52/55-high r14/50 elsewhere. | Medium | Single button spec. |

### PaywallPage — `lib/paywall/paywallpage/paywallpage_widget.dart`
_Full-screen dark subscription page (the app's only dark surface)._

| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | **Duplication** | Weekly card (191–533) & annual card (537–993) ~380 lines near-identical; the two `Continue` handlers (410–476/859–930) copy-paste. | High | One `PlanCard({package, isSelected, badge?, onSelect, onPurchase})`; hoist purchase to one method. |
| 2 | Duplication | `≈ /month` sub-row rendered 3× identical. | Medium | One `PriceApproxRow`. |
| 3 | Color | Hardcoded darks `#060D1E`/`#0C1A35`/`#132444` + white-opacity ladder 0.09–0.80. | High | Define an explicit paywall dark palette (tokens), not inline hex. |
| 4 | Accessibility | Disclaimer `white.withOpacity(0.45/0.35)` at 12px on dark fails AA; pricing accents borderline. | High | ≥0.6 opacity / legibility-checked muted-on-dark token. |
| 5 | Typography | Annual badge `labelSmall` 11px — sub-12. | Medium | Floor at 12. |
| 6 | Inconsistency | Three PRO/badge treatments (this pill / paywall_confirmation / upgrade). | Medium | One `ProBadge`/`ProPill`. |
| 7 | UX-flow | Card selection is decorative — non-selected card's button still purchases. | Medium | Single CTA driven by selection, or remove per-card buttons. |
| 8 | Reusable-component | Privacy/Terms/Restore links are three hand-built `InkWell(Text)`. | Low | Extract `LinkText`. |

### Upgrade (CTA) — `lib/paywall/upgrade/upgrade_widget.dart`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | Typography | Copy "Update a Pro" (76) — likely "Upgrade to Pro". | Medium | Fix string. |
| 2 | Typography | Leading icon `size:14` vs 16–20 elsewhere. | Low | Standardize icon sizing. |
| 3 | Inconsistency | 55-high r40 pill duplicates PRO-pill; border == fill (no-op). | Low | Reuse `ProPill`; drop border. |

### PremiumFeaturesList — `lib/components/premium_features_list/premium_features_list_widget.dart`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | **Duplication** | 8 hand-repeated feature rows (47–382), differ only by icon+string. | High | Data-drive `FeatureRow` (~340 → ~40 lines). |
| 2 | Duplication | Same row exists again in `paywall_confirmation` with `secondaryText` color. | High | Share one `FeatureRow({iconColor, textColor})`. |
| 3 | Accessibility | The confirmation variant's `secondaryText` row — verify AA. | Medium | Readable body token. |
| 4 | Inconsistency | Mixed icon sources/sizes (Material + FaIcon 18 vs 20). | Low | Normalize icon set/size. |

### PaywallConfirmation — `lib/components/paywall_confirmation/paywall_confirmation_widget.dart`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | Duplication | Shares the exact bottom-sheet shell (`alternate`, r24 top, 100×5 handle, 55-high r50 CTA) with `out_of_generations`. | High | `BottomSheetScaffold`. |
| 2 | Duplication | 4 feature rows duplicate `PremiumFeaturesList`. | High | Reuse `FeatureRow`. |
| 3 | Typography | Title `fontSize:26` override (same magic 26 in out_of_generations). | Medium | Add a `displayXS` 24–26 role. |
| 4 | Color | CTA text `Colors.white`; siblings use `info`/`alternate` inconsistently. | Medium | One on-primary token. |
| 5 | Inconsistency | PRO pill = 3rd badge variant. | Medium | Reuse `ProPill`. |

### OutOfGenerations — `lib/components/out_of_generations/out_of_generations_widget.dart`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | **Duplication** | Second "Limit reached" surface alongside `limit_out` (different keys/layout: sheet vs card). | High | One limit component with a variant prop. |
| 2 | Duplication | Sheet shell + CTA identical to `paywall_confirmation`. | High | Shared `BottomSheetScaffold`. |
| 3 | Typography | Title `fontSize:26` magic override. | Medium | Shared title role. |
| 4 | Accessibility | Body `secondaryText` 16px fails AA. | Medium | `textTertiary`. |
| 5 | UX-flow | Pushes paywall THEN pops sheet — fragile ordering. | Low | Pop first, then navigate. |

### LimitOut — `lib/limits/limit_out/limit_out_widget.dart`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | Color | Local `const _ink = #1A1A1A` re-hardcodes `primaryText`; card `Colors.white`. | High | Use `primaryText`/`secondaryBackground` tokens. |
| 2 | Duplication | Two `FFButtonWidget`s identical except label+route (Pro vs non-Pro). | Medium | One button, compute from `isPro`. |
| 3 | Duplication | Second "Limit reached" impl (r20/h52 vs sheets 16/44). | High | Merge limit surfaces. |
| 4 | Spacing/Radii | Card r20 / button r14 / h52 — yet another combination. | Medium | Converge on token scale. |

**Reusable components this cluster suggests:** `ConfirmationSheet` (replaces make*/hide/copy incl. the misspelled `makepubluc`) · `BottomSheetScaffold` · `FeatureRow` (data-driven; 8+4 rows) · `PlanCard` + `PriceApproxRow` · `ProPill` · `LimitReached` (variant) · paywall dark-surface palette tokens · `displayXS` 24–26 role.

---

## Cluster 8 — Dialogs, Empty & Loading States, Misc

### Bottom Sheets — Group A (token-aware) — `guest_prefs_sheet`, `link_telegram_sheet`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 1 | Duplication | Both repeat the same shell (white, top-r24, 40×4 handle, `fromLTRB(24,16,24,32+inset)`, 52-high r14 button + spinner) — ~70 duplicated lines. | High | `MirraBottomSheet` + `MirraPrimaryButton`. |
| 2 | Inconsistency | Handle color differs: guest hardcodes `#E0E0E0`, telegram uses `border` token. | Medium | Route both through `border`. |
| 3 | Inconsistency | Title differs: guest 20/w600/`Colors.black`; telegram 24/w700/`#1A1A1A`. | Medium | One sheet-title token. |
| 4 | Color | Raw hex vs tokens (`Colors.black`, `#F2F2F2`, `#555555`, `#E0E0E0`, `#4CAF50`). | Medium | `primaryText`/`surfaceMuted`/`textTertiary`/`border`/success. |
| 5 | Inconsistency | Button r14 vs field/chip r12/r36 — three radii per sheet. | Low | Adopt `t.radii`. |
| 6 | Accessibility | Handle no semantics; long dropdown can overflow small devices. | Low | Semantics label; verify scroll. |
| 7 | UX-flow | Guest `_save()` pops `true` in `finally` even on null sign-in — "show error" never fires. | Medium | Failure path keeps sheet open + toasts. |
| 8 | i18n | Guest uses inline translation maps; telegram uses `FFLocalizations`. | Low | Consolidate on `FFLocalizations`. |

### Bottom Sheets — Group B (FF legacy) — `delete_confirmation`, `leave_review`, `negative_feedback`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 9 | Duplication | Second sheet shell (`alternate`, top-r24, 100×5 handle, `fromSTEB(16,12,16,32)`) — differs from Group A. | High | Unify onto `MirraBottomSheet`. |
| 10 | Inconsistency | **Drag handle inconsistent app-wide**: 40×4 `border` vs 100×5 `info` vs `info`+redundant border. Three handle designs. | High | One canonical `MirraDragHandle`. |
| 11 | Inconsistency | Button shape clashes: Group A r14 rectangle vs Group B `FFButtonWidget` r50 pill. | High | One primary-button shape token. |
| 12 | Color | review/negative misuse `info` as field fill+border; delete uses `info` for handle+Cancel. | Medium | `surfaceMuted` fills; reserve `info` for accents. |
| 13 | Reusable-component | review + negative duplicate keyboard-visibility + Form + 5-border field decoration (~120 lines). | High | `MirraFeedbackField` + `KeyboardAwareSubmitButton`. |
| 14 | UX-flow | delete treats `succeeded ?? true` as success; error path = hardcoded English `AlertDialog`, unlocalized. | High | Default to failure on null; use `ErrorPopupWidget`. |
| 15 | Accessibility | Destructive delete styled `tertiary` (no red); Cancel equally prominent — indistinguishable. | Medium | Error-tint destructive; de-emphasize Cancel. |
| 16 | Typography | Group B titles headlineSmall→26; errors 18; guest 20; telegram 24 — five sheet-title sizes. | Medium | Two title roles (dialog vs sheet). |
| 17 | Spacing | review/negative hand-roll full-screen scrims instead of the modal barrier. | Low | Rely on modal barrier. |

### Dialogs — `error_popup` (+ 2 private), `feedback_collector`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 18 | Duplication | error_popup's 3 dialogs repeat the same shell (transparent, inset 24, white r20, `#1A000000` blur-24 shadow, 56×56 icon, r14 buttons). | Medium | `MirraDialogCard` + `MirraDialogIcon(56)`. |
| 19 | Color | Icon palettes hardcoded Material hex (`#FFF3E0/#E65100`, `#F3E5F5/#7B1FA2`); feedback_collector CTA gradient uses `#5C85D9` (= primary) as a literal. | Medium | Route status-icon palette to tokens; `theme.primary` for CTA. |
| 20 | Inconsistency | Dialog r20 vs sheet r24 vs feedback card r28; button r14, height 50. | Medium | Consolidate radius + button-height tokens. |
| 21 | Inconsistency | error_popup flat `ElevatedButton` r14 vs feedback_collector gradient pill r50 — two CTA languages. | Medium | One primary-button treatment. |
| 22 | Accessibility | `_IngredientsInputDialog` hint hardcoded English; emoji-only icons no semantics. | Medium | Localize hint; add semantics. |
| 23 | UX-flow | feedback_collector positive path calls both `requestReview()` AND `openStoreListing()` — can double-prompt on iOS. | Low | Gate store listing on review unavailability. |
| 24 | Typography | Dialog titles 18 vs feedback 22 vs negative 26 — three "dialog heading" sizes. | Low | Single dialog-title role. |

### Empty States — `empty_gallery`, `empty_gallery_with_animation`, `no_images`, `nounsorteditems`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 25 | Duplication | `empty_gallery` and `empty_gallery_with_animation` are the same widget; the animated one is a strict superset. | High | Keep one with an `animate` flag. |
| 26 | Duplication | `no_images` is the animated variant scaled to 8 tiles with 8 hand-declared `AnimationInfo` + inline switch. | High | Collapse into `SkeletonGrid(count, aspectRatio, animate)`. |
| 27 | UX-flow | **None of the three "empty gallery" widgets have text/icon/CTA** — pure gray skeletons that read as perpetual loading. | High | Real empty-state (icon + localized headline + CTA); reserve gray grids for loading. |
| 28 | Inconsistency | Tile opacity 0.3 vs 0.4, radius 16 vs 8, spacing 8 vs 12 — 3 skeleton-tile variants. | Medium | One skeleton-tile token. |
| 29 | Reusable-component | `nounsorteditems` is the only real empty-state with copy, but its text ("no products") contradicts its name/comment ("no unsorted items"). | Medium | Canonical `MirraEmptyState`; fix mismatched copy/name. |
| 30 | Color | Text pill uses `primary` for body text on `secondaryBackground`. | Low | `secondaryText`. |

### Loading Skeletons — `analysis_loading`, `loading_recent`, `loading_styles`, `gallery_loading_component`, `gallery_image_loading_component`, `album_list_loading_component`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 31 | Duplication | Five loaders are the same fade-tile at different counts/columns. | High | One `SkeletonGrid`/`SkeletonTile`. |
| 32 | Duplication | `album_list_loading` declares **32 `AnimationInfo` by hand** + unrolled 8× grid ≈ **1,200 lines** expressing "8 identical 4-tile cards". | High | `List.generate`; file should be ~40 lines. |
| 33 | Duplication | `no_images` (empty) shares the exact fade-tile skeleton — empty and loading code are physically the same. | High | One `SkeletonGrid` backs both; distinguish by message overlay. |
| 34 | Inconsistency | Tile params drift: radius 8 vs 16 vs 4/8; fill `alternate` vs `secondaryBackground`; spacing 8/10/12. | Medium | `skeletonBase` token + spec. |
| 35 | Inconsistency | Two loading idioms coexist (fade tiles vs spinner) with no rule. | Medium | Guideline: skeleton for grids, spinner for actions. |
| 36 | Reusable-component | `analysis_loading._StepIcon` + rotating-fact block are good/unique — keep; only hoist the repeated `screenH*0.55`. | Low | Hoist the fraction. |
| 37 | Color | Redundant `Colors.transparent` `Material` wrappers around every tile — dead nesting repeated hundreds of times. | Low | Drop the wrapper in the shared tile. |

### Misc / Page — `light_dark_toggle`, `newblank`
| # | Category | Finding | Priority | Proposed solution |
|---|----------|---------|----------|--------------------|
| 38 | Duplication (dead) | `light_dark_toggle` is fully dead — switch drives nothing (single light theme). | High | Delete widget + model; confirm no references. |
| 39 | UX-flow | `newblank._tryAnonymously` silently `return`s if context null — failed sign-in leaves user with no feedback. | Medium | Failure toast/retry. |
| 40 | Inconsistency | `newblank` CTA radius **30** — a fourth primary-button radius (vs 14/50/14). | High | One primary-button token. |
| 41 | Color | `newblank` hardcodes `Colors.black`/`Colors.white`; deprecated `.withOpacity`. | Low | Tokens; `withValues`. |
| 42 | Typography | `newblank` FlutterFlow blank-line formatting — mixed provenance signal. | Low | `dart format` on next touch. |

**Reusable components this cluster suggests:** `MirraBottomSheet` (one scaffold, 2 competing shells → 1) · `MirraDialogCard` + `MirraDialogIcon` · `MirraPrimaryButton` (+ secondary/destructive) · `SkeletonGrid`/`SkeletonTile` (collapses ~2,000 lines incl. album_list's 1,200) · `MirraEmptyState` · `MirraFeedbackField` + `KeyboardAwareSubmitButton` · `MirraDragHandle` (resolves 3 handle variants) · **delete `light_dark_toggle`**.

<!-- APPEND_ANCHOR -->
