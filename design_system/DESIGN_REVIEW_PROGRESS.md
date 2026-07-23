# Design Review — Track 2 Progress

Governs execution of [DESIGN_REVIEW.md](DESIGN_REVIEW.md) (the source of truth). Work proceeds
**one initiative at a time**; each is planned and approved before implementation, then lands in small,
analyze-verified commits. Every Design Review finding must end as **implemented**, **intentionally
rejected (with justification)**, or **superseded by another implemented change** — nothing skipped.

**Legend:** Status = Not Started / In Progress / Completed. Findings are referenced as
`C<cluster>·<Screen>·#<row>` (e.g. `C1·Log In·#2`).

## Initiatives (planned order)

| # | Initiative | Backlog | Status | Priority | Est. effort |
|---|---|---|---|---|---|
| 1 | **Inputs** — `AppTextField` (visible focus, one fill/border/radius, password toggle) | B10 | **Completed** | High | S–M |
| 2 | Button system — `AppButton` (primary/secondary/outline/text/destructive, pill) | B1 | **In Progress** | High | L |
| 3 | Accessibility pass — contrast, 12px floor, 44px targets, non-color cues | B3 | Not Started | High | M |
| 4 | Semantic color + score system — `semanticScoreColor()`/`statusColor()`/legend | B2 | Not Started | High | M |
| 5 | Empty vs loading — `SkeletonGrid` + `MirraEmptyState` | B4 | **Completed** | High | M |
| 6 | Sheets & dialogs — `MirraBottomSheet`/`MirraDialogCard`/`MirraDragHandle` | B5 | **In Progress** | High | M |
| 7 | Product surfaces — `ProductTile`/`MirraInfoCard`/`MirraChip`/`ScoreBadge` | B6 | Not Started | High | L |
| 8 | Confirmation & limit consolidation — `ConfirmationSheet`/`ConfirmDialog`/`LimitReached`; delete `makepubluc` | B7 | Not Started | High | S |
| 9 | Settings & rows — `SettingsRow`/`SelectableRow`/`SettingsList` | B8 | Not Started | Medium | M |
| 10 | Paywall — `PlanCard`/`FeatureRow`/`ProPill`/dark palette | B9 | Not Started | Medium | M |
| 11 | Typography hygiene — roles over raw TextStyle, `displayXS`, kill local scales | B11 | Not Started | Medium | M |
| 12 | Localization & dead-code cleanup — inline strings→FFLocalizations, remove dead code | B12 | Not Started | Medium | S |
| 13 | Layout constants — `kNavBarHeight`, spacing tokens for magic offsets | B13 | Not Started | Low | S |

## ⚠ Repo change — modules deleted (commit `12de10f`, 2026-07-23)
Four experimental modules were removed by the team mid-Track-2. Their Design Review findings are
**OBSOLETE (module deleted)** — not to be implemented:
- **`compatibility_result`** → Cluster 4 findings #1–#7 obsolete (score ring, conflict severity, etc.).
- **`cosmetic_bag`** + **`cosmetic_bag_intro`** → Cluster 6 findings for those two screens obsolete.
- **`routine_calendar`** → Cluster 5 routine findings obsolete.
- **`home_pipeline_widget`** → Cluster 2 pipeline findings obsolete.
- `navbar_widget` was also heavily modified by the team — re-review before touching (Cluster 2 navbar findings may be stale).

Also: commit `5f59d40` landed the previously-uncommitted in-flight work (search / guest_prefs /
ingredient_bubbles), so those files are now **unblocked** for migration.

## Coverage note
Each initiative's detail section (added as it starts) enumerates the exact findings it resolves.
A finding touched by an earlier initiative is marked **superseded** in the later one rather than
re-done. The Design Review's **report-only flags** (dead code, null-success bugs, `print()` stubs)
are tracked under Initiative 12 for a resolve/reject decision — none are silently dropped.

---

## Initiative 1 — Inputs (`AppTextField`)  ·  Status: ✅ Completed

**Goal:** one text-field component with a **visible focus state**, consistent fill/border/radius,
and a built-in password-visibility toggle with a 44px tap target. Replaces the divergent inline
`InputDecoration`s and fixes the app-wide invisible-focus bug.

**Decision (approved):** start with Inputs; canonical style = **filled + focus ring** (`surfaceMuted`
fill, 1px `border` resting, **1.5px `primary` focus**, radius 16, hint `secondaryText`).

**Commit plan:** 1.1 create component · 1.2 auth (log_in, create_account, forgot_password) ·
1.3 onboarding (onboarding_profile, onboarding_quiz) · 1.4 profile & albums (edit_profile,
edit_album, new_album) · 1.5 sheet field (link_telegram).

**Commits:**
- ✅ **1.1** `feat(ds): add AppTextField component` — new `lib/design_system/components/app_text_field.dart`. No migration. `flutter analyze`: clean. Resolves nothing yet (component only; findings resolve as sites migrate in 1.2–1.5).
- ✅ **1.2** `refactor(auth): migrate auth forms to AppTextField` — log_in (4 fields, incl. removing the `_inputDecoration`/`_inputTextStyle`/`_visibilityIcon` helpers), create_account (2), forgot_password (1). 7 fields → AppTextField. `flutter analyze`: 0 new issues (2 pre-existing `dart:math` unused_import left untouched). **Resolved:** C1·Log In·#2, #4; Create Account·#1, #2; Forgot Password·#1. **Superseded:** password-toggle tap-target (now the component's job). **Still open (not this commit):** Create Account·#5 (double autofocus — behavior, deferred to a11y/UX); Forgot Password·#2,#3,#4,#5,#6 (non-input findings).
- ✅ **1.3** `refactor(onboarding): migrate onboarding fields to AppTextField` — onboarding_profile (firstName/lastName via `nameField` helper + nickname; removed `_fieldDecoration` + orphaned `theme` local), onboarding_quiz (brands autocomplete field). Also extended AppTextField: **input text → 16px `bodyLarge`** (canonical; makes all inputs consistent — auth create_account/forgot were 14, now 16, log_in already 16), plus `maxLengthEnforcement` + `showCounter` for the nickname's hidden counter. `flutter analyze`: 0 new issues. **Resolved:** C1·Onboarding Profile·#3 (input radius 14→16); Onboarding Quiz·#5 (brands field had no focus). **Note:** Onboarding Profile·#3 also mentioned the section-card radius 20 (a card, not input) — remains for the cards/typography work.
- ✅ **1.4** `refactor(profile+albums): migrate to AppTextField` — edit_profile (firstName + lastName, preserving the lastName `onFieldSubmitted` DB-save and both capitalization formatters), edit_album (folder title, preserving unfocus-on-submit), new_album (album name). 4 fields. `flutter analyze`: **No issues found**. **Resolved:** C5·Edit Profile·#2 (duplicate decoration), #5 (invisible focus → primary; fill `alternate`→`surfaceMuted`); C6·Edit Album·#1 (decoration dup), #2 (radius 16 vs 24 — now unified 16); New Album·#2 (dup + focus `primaryBackground`→`primary`), #5 (`info` overloaded as field bg → `surfaceMuted`). **Note:** edit_profile·#4 (three-path save logic) is preserved as-is (behavior, out of scope).
- ✅ **1.5** `refactor(link-telegram): migrate field to AppTextField` — the code/link `TextField` (border: none, radius 12) → AppTextField (radius 16 + visible focus ring); `enabled`/`autofocus`/submit behaviour preserved. `flutter analyze`: **No issues found**. **Resolved:** C8·Group A·#4 (field part). **Note:** #4's non-field parts (raw-hex title/handle colors) and #1,#2,#3,#5,#6,#7,#8 (sheet shell, drag handle, button shape, i18n) belong to the Sheets initiative (#6).

### Initiative 1 — completion summary
**Delivered:** `AppTextField` (+ `.password`) consumed by **13 fields across 9 screens** (log_in ×4, create_account ×2, forgot_password, onboarding_profile ×2, onboarding_quiz, edit_profile ×2, edit_album, new_album, link_telegram). Every form field now has one filled style, a **visible focus ring**, 16px text, radius 16, and password toggles in a 44px target.
**Findings resolved:** C1 Log In #2,#4 · Create Account #1,#2 · Forgot Password #1 · Onboarding Profile #3 · Onboarding Quiz #5 · C5 Edit Profile #2,#5 · C6 Edit Album #1,#2 · New Album #2,#5 · C8 Group A #4 (field part). Password-toggle tap-target **superseded** (component-owned).
**Carried forward (tracked, not dropped):** search bar → future `AppSearchField`; `guest_prefs` dropdown → future dropdown component; Create Account #5 (double autofocus) & Edit Profile #4 (three-path save) → Initiative 3 (a11y/UX); password-toggle a11y label localization → Initiative 12.

**Deferred within this initiative (tracked, not dropped):** Search bar (C3·Search·#1) → future `AppSearchField`; `guest_prefs` dropdown → future dropdown component. Password-toggle label localization → Initiative 12.

---

## Initiative 2 — Button system (`AppButton`)  ·  Status: In Progress

**Decision (approved):** canonical shape = **Pill (radius full / StadiumBorder)**. Variants
primary/secondary/outline/text/destructive; sizes sm 36 / md 44 / lg 52; built-in loading spinner;
new `onPrimary` token (white).

**Scope:** all standalone page/form buttons (56 FFButtonWidget, 48 ElevatedButton, 21 TextButton,
6 OutlinedButton across ~40 files). **Excluded (consume AppButton in their own initiative):** paywall
`PlanCard`/`ProPill` (→ I10), confirmation-sheet consolidation (→ I8), sheet/dialog shells (→ I6);
navbar center FAB stays bespoke.

**Findings:** C1·Log In #7,#8 · Onboarding Quiz #4 · C2·Home #7 · startanalys #6 · capture #4 ·
C3·Search #7 · C5·Profile #8 · Edit Profile #8 · Routine #7 · C6·boards #3 · newboardempty #3 ·
new_album #3 · cosmetic_bag_intro #4 · C7·confirmation sheets #8 · limit_out #4 · C8·Group A #1(btn) ·
Group B #11 · dialogs #21 · newblank #40.

**Commit plan:** 2.1 component + token · 2.2 auth · 2.3 onboarding · 2.4 home/capture/search ·
2.5 profile/routine/settings · 2.6 bag/boards · 2.7 limits + standalone dialog/sheet CTAs · 2.8 misc.
(Split auth vs onboarding for reviewability — onboarding_quiz has 7 buttons via `_primaryBtn`/`_secondaryBtn` builders.)

**Apple sign-in buttons are intentionally excluded** (Apple HIG requires their own branded style) — kept as `FFButtonWidget`; tracked for a future dedicated `AppleButton` if desired.

**Commits:**
- ✅ **2.1** `feat(ds): add AppButton component + onPrimary token` — new `lib/design_system/components/app_button.dart` (pill, 5 variants, 3 sizes, loading); added `onPrimary` (white) field to `LightModeTheme`. No migration. `flutter analyze`: **No issues found**. Resolves nothing yet (findings resolve as buttons migrate).
- ✅ **2.2** `refactor(auth): migrate auth CTAs to AppButton` — log_in (Log in + Create account), create_account (Create account), forgot_password (Send reset). 4 primary CTAs: height 55 → lg (52), radius 50 → pill token; async `onPressed` + loading preserved (`FFButtonWidget` default `showLoadingIndicator: true` ≙ AppButton spinner). Removed the orphaned `flutter_flow_widgets` import in forgot_password. `flutter analyze`: 0 new issues (2 pre-existing `dart:math` untouched). **Resolved (button parts):** C1·Log In·#8 (height 55) and #7 (button radius 50 → pill; the tab-pill/icon-button radii remain — not button-family); Forgot Password·#5 (the 55/50 CTA part; back button remains for an icon-button pass). **Excluded:** Apple sign-in buttons (branded).
- ✅ **2.3** `refactor(onboarding): migrate onboarding buttons to AppButton` — onboarding_quiz (7 buttons: consolidated the `_primaryBtn`/`_secondaryBtn` FFButtonOptions builders — heights 52/46/55 → lg/md, `_secondaryBtn` → outline variant, disabled-goals via null onPressed) + onboarding_profile (Continue). Removed both builders and the orphaned `flutter_flow_widgets` imports. `flutter analyze`: 0 new issues (1 pre-existing `withOpacity` info). **Resolved:** C1·Onboarding Quiz·#4 (button-height proliferation → lg/md). **Left as-is:** the step "skip/none/change" `TextButton`s are link-style secondary actions (not FFButtonWidget, not a specific finding) — a future `AppButton.text` pass could adopt them.
- ✅ **2.4** `refactor(home+capture): migrate CTAs to AppButton` — home (PRO chip: 35/18 → `sm` pill w/ crown icon, `fullWidth:false`; empty-state CTA: 50/50 → pill, nav via void onPressed to avoid a spinner-during-navigation regression), takeor_upload (Take a photo + Choose from gallery capture CTAs: 65/36 → pill lg, dropping the alpha-baked `0xD25C85D9` fill → solid `primary`). `flutter analyze`: **0 errors** project-wide (isolated-file analysis shows false package-import errors — verified against full analyze). **Resolved:** C2·Home·#7 (button heights/radii), capture·#4 (capture CTAs) + #2 (alpha-baked primary → token). **Excluded/deferred:** `search_widget` (still your uncommitted in-flight work — deferred until it lands); `startanalys` (print() stub, likely orphaned → I12 dead-code); takeor_upload's info-dialog `ElevatedButton` → I6 (dialog shell); home `TextButton` links left as-is.

---

## Initiative 5 — Empty vs loading  ·  Status: ✅ Completed

**Goal:** one loading primitive (`SkeletonGrid`/`SkeletonTile`) + one empty primitive
(`MirraEmptyState`, icon+copy+CTA), fixing the core bug that **empty galleries render the same gray
skeleton as loaders** (so an empty screen reads as perpetual loading with no action). Source:
DESIGN_REVIEW **B4** + Cluster 8 rows 26–36 + Cluster 6 empty-state rows.

**Inventory (all 12 still exist, ~3,655 lines):** loaders — analysis_loading (335, *kept*: unique
step/facts UI), loading_recent (237), loading_styles (440), gallery_loading (193), gallery_image_loading
(179), **album_list_loading (1207 — 32 hand `AnimationInfo`)**; empties — empty_gallery (132),
empty_gallery_with_animation (202), no_images (337), nounsorteditems (78), newboardempty (164),
blank_album (351). Call sites: **1–2 each** → migrate by **thin-wrappering** (rewrite each widget's
`build()` to delegate; class/constructor unchanged, screens untouched).

**Decisions (approved):** scope = **everything now** (loaders + empty-state UX); skeleton animation =
**generated stagger** (loop-reverse fade, delay = index×100ms) replacing the hand-unrolled
`AnimationInfo` — static look identical, timing uniform.

**Commit plan:** 5.1 `SkeletonGrid`/`SkeletonTile` · 5.2 wrapper the 5 loaders · 5.3 `MirraEmptyState`
· 5.4–5.5 wrapper the 6 empty states (draft copy/CTA/icons → approve → add ×11 strings for the 3
text-less gallery empties).

**Commits:**
- ✅ **5.1** `feat(ds): add SkeletonGrid/SkeletonTile` — new
  `lib/design_system/components/skeleton_grid.dart`: parameterized loading grid (count, columns,
  aspectRatio, spacing, tileRadius, tileColor, padding, shrinkWrap, physics, animate) with the
  index-staggered loop-reverse fade generated via `GridView.builder`. Defaults match the common gallery
  loader (2 cols, square, 8px, `alternate`). No migration yet. `flutter analyze`: **No issues found**.
- ✅ **5.2** `refactor(loaders): flat-grid loaders → SkeletonGrid` — thin-wrappered the 3 flat-grid
  loaders to delegate to `SkeletonGrid` (class/constructor unchanged, call sites untouched; dropped the
  hand-written `AnimationInfo` + `flutter_flow_animations`/`flutter_animate` imports + unused
  `TickerProviderStateMixin`): **gallery_image_loading** (4 tiles, 2col, r16, `alternate`),
  **gallery_loading** (outer `secondaryBackground` r12 card + 4 tiles, 2col, r8), **loading_recent**
  (6 tiles, 3col spacing10, r8, `secondaryBackground` fill). Static look preserved per-site via params;
  pulse timing now the generated stagger. **−479/+26 lines** (3 files). `flutter analyze`: my files
  **No issues found** (0 errors/warnings project-wide); tests `+9 -1`. **Resolved (partial):** B4/C8·#31,#34
  for these 3. **Remaining loaders:** album_list_loading (mosaic list → 5.3), loading_styles (avatar-row
  skeleton, different shape → 5.4); analysis_loading kept (unique step/facts UI).
- ✅ **5.3** `refactor(loaders): album_list_loading → SkeletonGrid mosaic (1207→69)` — the worst
  offender: **32 hand-written `AnimationInfo` + an 8×-unrolled grid** rebuilt as
  `GridView.builder(itemCount: 8)` where each album-cover card = `secondaryBackground` r12 container +
  a `SkeletonGrid(count:4, columns:2, spacing:8, tileRadius:8)` 2×2 mosaic (outer grid 2col/spacing12,
  matching originals). **1207 → 69 lines.** Dropped `flutter_flow_animations`/`flutter_animate` +
  `TickerProviderStateMixin`. `flutter analyze`: **No issues found**; tests `+9 -1`. **Resolved:**
  B4/C8·#32 (the 1,200-line monster), #31/#34 for album_list.
- ✅ **5.4** `refactor(loaders): loading_styles dedup (440→114)` — the horizontal style-picker loader
  (4 identical cards = image tile + label pill) rebuilt with `List.generate(4)` + a local staggered
  `_pulse` (flutter_animate), dropping the 8 hand-written `AnimationInfo` + `flutter_flow_animations` +
  `TickerProviderStateMixin`. Exact shapes/radii/spacing preserved (`.divide(12)` + start/end 16).
  **440 → 114 lines.** `flutter analyze`: **No issues found**; tests `+9 -1`. **Note:** `SkeletonTile`
  wasn't a fit here (custom asymmetric radii + pill, not uniform tiles) — deduped internally instead.
  All 5 grid/list loaders now done; **analysis_loading kept** (unique step-icon + rotating-facts UI per
  review #36).
- ✅ **5.5** `feat(ds): add MirraEmptyState` — new
  `lib/design_system/components/mirra_empty_state.dart`: centered **icon (56, secondaryText) + headline
  (titleMedium) + optional body (bodyMedium secondaryText) + optional primary `AppButton` CTA**. The
  empty-state primitive that fixes the "empty reads as loading" bug — loading grids use `SkeletonGrid`,
  empty screens use this. No migration yet (6 empties wired in 5.6+, with copy/CTA/icons). `flutter
  analyze`: **No issues found**.

### ⚠ Scope correction (liveness check) — most empty/loading widgets are dead code
Reference-checking the current tree (the Design Review predates the team's refactor) found only **3
live** widgets: `album_list_loading` (boards, loading — done 5.3), `analysis_loading` (takeor, kept),
`newboardempty` (boards, empty). The **core B4 bug is already fixed live**: boards_widget branches
`!hasData → SkeletonGrid` vs `isEmpty → newboardempty` (lines 193/199). **Orphaned/dead (0 external
refs):** loaders `gallery_loading`, `gallery_image_loading`, `loading_recent`, `loading_styles`
(thin-wrappered in 5.2/5.4 before liveness was confirmed — now tiny, but dead) + empties `empty_gallery`,
`empty_gallery_with_animation`, `no_images`, `nounsorteditems`, `blank_album`. → The 5 text-less-empty
migrations + ×11 i18n strings are **moot** (dead code). **Decision (approved):** migrate the one live
empty, then delete the 9 dead widgets now.
- ✅ **5.6** `refactor(empty): newboardempty → MirraEmptyState` — reshaped `MirraEmptyState` to faithfully
  match the app's best empty state (the collections empty): layered **tinted icon badge**
  (`iconColor`/`tintedBadge`), `headlineMedium` headline, `bodyMedium` body, optional CTA with
  `ctaIcon`/`ctaFullWidth`. Then migrated **newboardempty** to consume it (164→78 lines) — reuses its
  existing keys `95giorwg`/`d37etdgk`/`o1bipgy8` (**no new i18n**), preserves the create-collection
  modal + `onBoardCreated`. CTA `FFButtonWidget` r24 → standardized **`AppButton` pill** (I2 gain).
  `flutter analyze`: **No issues found**; tests `+9 -1`. **Resolved:** B4/C6·#581 (newboardempty is now
  the canonical `MirraEmptyState`); C8·#27 fix (real empty vs loading) — confirmed already correct live.
- ✅ **5.7** `chore: delete 9 orphaned empty/loading widgets` — removed the provably-dead widgets +
  models (18 files): loaders **gallery_loading**, **gallery_image_loading**, **loading_recent**,
  **loading_styles**; empties **empty_gallery**, **empty_gallery_with_animation**, **no_images**,
  **nounsorteditems**, **blank_album**. Verified 0 external references before deletion (the only hits
  were a substring false-positive and an i18n comment). `flutter analyze`: **0 errors / 0 warnings**;
  tests `+9 -1`. **Resolved:** B4/C8·#26,#28,#33 + C6·#599,#608,#626 (the duplicate empty/loading
  variants) — by deletion (dead) rather than migration. **Note:** unused i18n keys for the deleted
  widgets (e.g. `gzohwfxg`) remain in `internationalization.dart` → **I12** string cleanup.

### Initiative 5 — completion summary
**Delivered:** `SkeletonGrid`/`SkeletonTile` (loading) + `MirraEmptyState` (empty, modeled on the
collections empty). **Live** surfaces: album_list_loading → SkeletonGrid mosaic (**1207→69**);
newboardempty → MirraEmptyState (**164→78**, CTA now AppButton pill). **analysis_loading** kept
(unique). **Dead code removed:** 9 orphaned widgets (18 files). Net: **~2,700 lines deleted/collapsed**.
**Key finding:** the B4 "empty-reads-as-loading" bug was already fixed in the live app (boards branches
skeleton vs empty) — the offending widgets were vestigial. **Findings resolved:** B4 (SkeletonGrid +
MirraEmptyState delivered; loaders deduped; empties consolidated/deleted); C8 #26,#27,#28,#31,#32,#33,#34;
C6 #581,#599,#608,#626. **Carried forward:** unused i18n keys for deleted widgets → **I12**.

---

## Initiative 6 — Sheets & dialogs  ·  Status: In Progress

**Goal:** one bottom-sheet scaffold (`MirraBottomSheet`), one canonical drag handle
(`MirraDragHandle`), one dialog shell (`MirraDialogCard`/`MirraDialogIcon`), replacing the 2 divergent
sheet shells + 3 handle designs + hand-rolled dialog cards. Source: DESIGN_REVIEW **B5** + Cluster 8
Group A/B + Cluster 6 sheet rows.

**Inventory (~11 live sheets, all verified live):** Group A (white / 40×4 `border` handle):
link_telegram_sheet, guest_prefs_sheet; Group B (`alternate` / 100×5 `info` handle): new_album,
edit_album, albumslist, delete_confirmation, leave_review, negative_feedback, out_of_generations,
paywall_confirmation, share_card_sheet. Dialogs: error_popup (3 hand-rolled dialog cards).

**Decision (approved):** canonical handle = **40×4, grey `border`, fully rounded** (the wide blue
100×5 `info` bars become this). Sheet surface unified to `secondaryBackground`.

**Commit plan:** 6.1 `MirraDragHandle` + `MirraBottomSheet` · 6.2 `MirraDialogCard`/`MirraDialogIcon`
· 6.3 migrate Group A sheets · 6.4 migrate Group B sheets · 6.5 error_popup → `MirraDialogCard`.

**Commits:**
- ✅ **6.1** `feat(ds): add MirraDragHandle + MirraBottomSheet` — new `mirra_drag_handle.dart` (canonical
  40×4 `border` handle) + `mirra_bottom_sheet.dart` (top-r24 `secondaryBackground` surface + centered
  handle + standard `fromLTRB(24,16,24,32)` padding + keyboard-inset add; params for surface/padding/
  handle/alignment). Modeled on the clean link_telegram shell. No migration yet. `flutter analyze`:
  **No issues found**.
- ✅ **6.2** `feat(ds): add MirraDialogCard + MirraDialogIcon` — new `mirra_dialog_card.dart`:
  `MirraDialogIcon` (56×56 circle, `color.withValues(alpha:.12)` tint + full-color icon) +
  `MirraDialogCard` (transparent `Dialog`, inset 24, r20 `secondaryBackground` surface + soft shadow,
  padding `fromLTRB(24,28,24,24)`, optional top icon). Modeled on error_popup's shell. No migration
  yet. `flutter analyze`: **No issues found**.
