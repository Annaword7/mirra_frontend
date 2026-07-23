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
| 2 | Button system — `AppButton` (primary/secondary/outline/text/destructive, pill) | B1 | **Completed** | High | L |
| 3 | Accessibility pass — contrast, 12px floor, 44px targets, non-color cues | B3 | **Completed** | High | M |
| 4 | Semantic color + score system — `semanticScoreColor()`/`statusColor()`/legend | B2 | **In Progress** | High | M |
| 5 | Empty vs loading — `SkeletonGrid` + `MirraEmptyState` | B4 | Not Started | High | M |
| 6 | Sheets & dialogs — `MirraBottomSheet`/`MirraDialogCard`/`MirraDragHandle` | B5 | Not Started | High | M |
| 7 | Product surfaces — `ProductTile`/`MirraInfoCard`/`MirraChip`/`ScoreBadge` | B6 | Not Started | High | L |
| 8 | Confirmation & limit consolidation — `ConfirmationSheet`/`ConfirmDialog`/`LimitReached`; delete `makepubluc` | B7 | **In Progress (buttons only)** | High | S |
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

## Initiative 2 — Button system (`AppButton`)  ·  Status: ✅ Completed

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
- ✅ **2.5** `refactor(profile): migrate profile+edit_profile buttons to AppButton` — [branch `track2-design`] profile ×5 (anon Create account → **primary** [was cream `secondary` — approved brand change], Sign in → secondary, End session → text/sm, Log out → secondary, Delete account → text/sm [kept quiet, approved]) + edit_profile Save → primary. Removed orphaned `flutter_flow_widgets` imports. `flutter analyze`: **0 errors** project-wide. **Resolved:** C5·Profile·#8 (button height/radius mix), #4 (button-color part: `#E7E8EB` sign-in/out → secondary variant); Edit Profile·#8 (Save radius 50 → pill). **Note:** settings (countries/langs) have no buttons; routine deleted. Profile·#1 (settings-**row** pattern) is InkWell rows → Initiative 9.
- ✅ **2.6** `refactor(boards): migrate boards buttons to AppButton` — boards New board (40/24 → primary md, icon, `fullWidth:false`), albumslist Apply (55/30 → primary), newboardempty Create collection (52/24 → primary, icon), edit_album Save (→ primary) + **Delete (`tertiary`/peach → destructive/error)**, new_album Create (→ primary) + Cancel (`info` fill → secondary). 7 buttons; removed 5 orphaned `flutter_flow_widgets` imports. `flutter analyze`: **0 errors** project-wide. **Resolved:** C6·boards·#3, newboardempty·#3, new_album·#3 + #5 (Cancel `info` overload), edit_album·#3 (delete `tertiary`→destructive) + #4, albumslist·#4. **Left for I8:** edit_album's AlertDialog `TextButton`s (Cancel/Delete, hardcoded 'Delete' string + `#D32F2F`).
- ✅ **2.7** `refactor(search): migrate search buttons to AppButton` — the "AI" parse button (`ElevatedButton` r12/44, isParsing spinner → `AppButton` md pill, `loading:`, `fullWidth:false`) and the Search button (`ElevatedButton` r14/52, isSearching spinner → `AppButton` lg pill, `loading:`). Both loading states map to AppButton's `loading` param. `flutter analyze`: **0 errors** project-wide. **Resolved:** C3·Search·#7 (AI 44 / Search 52 button heights → pill). **Remains:** Search·#8 (two overlapping search triggers) is a UX-flow finding, not a button-style one.
- ✅ **2.8** `refactor(itemcard2+toprated): migrate anon-prompt + filter buttons to AppButton` — itemcard2 ×3 (anon-gate Create account → primary, Sign in `OutlinedButton` → outline, copy-login Sign in → primary), toprated filter-sheet Apply (`ElevatedButton` r14/52 → primary pill). `flutter analyze`: **0 errors** project-wide (pre-existing unused_element/null-aware warnings untouched). **Resolved:** C3·toprated·#3 (Apply button 52 → pill); itemcard2 anon-prompt CTAs consolidated. TextButton links in both left as-is.
- ✅ **2.9** `refactor(newblank): migrate CTA to AppButton + reformat` — added `AppButton.trailingIcon` (leading-icon sibling, for CTA arrows); newblank "Try free" CTA (`ElevatedButton` r30 + trailing arrow) → AppButton primary pill with `trailingIcon`. `dart format`ed the file (545 → 331 lines). Void `onPressed` so the guest-prefs sheet doesn't trigger the button spinner. `flutter analyze`: **No issues found**. **Resolved:** C8·newblank·#40 (button radius 30 → pill), #42 (FlutterFlow blank-line formatting). **Remains:** newblank·#39 (silent return on null context — UX/I3) and #41 (raw `Colors.black/white` — color/I4).

### Initiative 2 — completion summary
**Delivered:** `AppButton` (pill; 5 variants, 3 sizes, loading spinner, leading + `trailingIcon`) + `onPrimary` token, consumed by **~30 buttons across 15 screens** (auth ×4, onboarding ×8, home/capture ×4, profile+edit ×6, boards ×7, search ×2, itemcard2 ×3, toprated, newblank).
**Findings resolved:** Log In #7,#8 · Forgot Password #5(CTA) · Onboarding Quiz #4 · Home #7 · capture #4,#2 · Search #7 · Profile #8,#4(btn) · Edit Profile #8 · boards #3 · newboardempty #3 · new_album #3,#5 · edit_album #3,#4 · albumslist #4 · toprated #3 · newblank #40,#42.
**Excluded (owned by later initiatives, will consume AppButton):** Apple sign-in buttons (branded) · paywall PlanCard/ProPill → I10 · confirmation/limit surfaces (limit_out, out_of_generations, make*/copyitem/hidenavailability, deleteitem, markasspam, delete_confirmation, edit_album AlertDialog) → I8 · error_popup + takeor_upload info-dialog → I6 · navbar FAB stays bespoke · startanalys print() stub → I12 · TextButton link-style actions left as-is.

- ✅ **2.10** `refactor(sheets): migrate simple sheet CTAs to AppButton` — follow-up after a review noted the `link_telegram` "Привязать" button still looked different (rounded-rect r14 among pills). Pulled the button-part of the simple sheet CTAs forward from I6: **link_telegram** (Привязать, `loading:_submitting`), **guest_prefs** (Continue, `loading:_saving`) — both were `ElevatedButton` r14 rectangles; **leave_review** (Send) + **negative_feedback** (submit) — `FFButtonWidget` r50. All → `AppButton` primary pill. Removed 2 orphaned `flutter_flow_widgets` imports. `flutter analyze`: **0 errors**. **Resolved:** C8·Group A·#1 (button part), Group B·#11 (button-shape r14/r50 → unified pill). The **sheet shells** (radius/handle/padding/dialog structure) still land in I6.

---

## Initiative 8 — Confirmation & limits  ·  Status: In Progress (button-only pass)

**Scope decision (approved):** **button-only** — migrate the remaining CTAs in confirmation
dialogs / visibility sheets / limit surfaces to `AppButton` to finish the button consistency.
**Consolidation is deferred** (one `ConfirmationSheet`/`ConfirmDialog`/`LimitReached`, deleting
`makepubluc`, rewriting call-sites) — a separate dedicated effort, since `topratings` is the team's
active area. Layout is preserved; only the button widgets change.

**Commits:**
- ✅ **8.1** `refactor(dialogs): confirm-dialog buttons → AppButton` — deleteitem (Delete → **destructive**, Cancel → text), markasspam (Cancel → secondary, Hide `#1976D2` → **primary**; both wrapped in `Expanded` to fix the fixed-140 overflow), delete_confirmation (Delete `tertiary` → **destructive**, Cancel `info` → secondary; nested error `AlertDialog` preserved). Removed 2 orphaned `flutter_flow_widgets` imports. `flutter analyze`: **0 errors**. **Resolved (button parts):** C3·deleteitem·#2,#4; markasspam·#1 (blue→primary),#4 (Expanded); delete_confirmation·#15 (destructive now red). **Not done (button-only scope):** dialog **consolidation** (deleteitem+markasspam+delete_confirmation → one `ConfirmDialog`); markasspam·#5 copy comment; delete_confirmation·#14 (null-success bug → UX/I12).
- ✅ **8.2** `refactor(topratings): visibility-sheet buttons → AppButton` — makepublic / makepubluc / makeprivate (single «Ok» → primary md), hidenavailability («Go PRO» → primary md), copyitem (Cancel → secondary, Copy → primary + `loading:_isLoading`). All `fullWidth:false` (centered). Removed 5 orphaned `flutter_flow_widgets` imports. `flutter analyze`: **0 errors**. **Resolved (button parts):** the 140×44/r8 buttons → pill md across all 5 sheets. **Not done (button-only scope):** consolidation into one `ConfirmationSheet` + **deleting the `makepubluc` twin** (still present) — deferred.
- ✅ **8.3** `refactor(limits): limit_out + out_of_generations buttons → AppButton` — limit_out (Pro «Got it» + non-Pro «Upgrade to Pro», both → primary), out_of_generations («Got it» → primary, page-load animation preserved). Removed 2 orphaned `flutter_flow_widgets` imports. `flutter analyze`: **0 errors**. **Resolved (button parts):** limit_out·#2 (two identical buttons now consistent). **Not done:** merging limit_out + out_of_generations into one `LimitReached` — deferred (button-only scope).
- ✅ **8.4 / I6.1** `refactor(popups): dialog buttons → AppButton` — error_popup (4 dialog CTAs across its 3 dialogs: OK/Analyze → primary, Close/Continue-anyway → secondary), takeor_upload info-dialog («button» → primary). All `SizedBox`+`ElevatedButton` r14 → AppButton pill. `flutter analyze`: **0 errors**. **Resolved (button parts):** C8·Group B·#11 (dialog button shape) for these; the I6 **shells** (`MirraDialogCard`/`MirraBottomSheet`/drag-handle) remain.

### I6/I8 button-only pass — summary
Every remaining sheet/dialog/confirmation/limit **CTA** is now `AppButton` (pill): confirm dialogs, topratings visibility sheets, limits, error_popup, info-dialog, + the 2.10 sheet CTAs. **No old-styled buttons remain** except the intentional exclusions: **paywall** (→ I10 `PlanCard`/`ProPill`), **startanalys** print()-stub (→ I12), **Apple** sign-in (branded), **navbar FAB** (bespoke). Structural work still owed by I6 (shells) and I8 (consolidation + delete `makepubluc`).

---

## Initiative 3 — Accessibility  ·  Status: ✅ Completed

**Goal:** meet a baseline: AA text contrast, a ≥12px type floor, ≥44–48px tap targets, and
non-color status cues. Source: DESIGN_REVIEW cluster **B3** + per-screen a11y rows.

**Scope boundaries (agreed):** pure-a11y only. **Deferred to owning initiatives** (tracked, not
skipped): **non-color status cues** (score rings / ingredient highlights / status dots) → **I4**
(built with `statusColor`/`ScoreRing`/`StatusLegend`); **painter-embedded sub-12** (radar 9.5/9/8,
share-card 7.5px mini-bars) → **I4** (painters rebuilt there); **untranslated strings** → I12; field
**focus states** → already delivered in Initiative 1.

**Commit plan:** 3.1 contrast (secondaryText token) · 3.2 12px floor (simple `Text`) ·
3.3 min tap targets (44–48px) · 3.4 behavior a11y (autofocus).

**Commits:**
- ✅ **3.1** `fix(a11y): secondaryText #929292 → #6B6B6B (WCAG AA)` — darkened the single
  `secondaryText` token in `LightModeTheme` from `#929292` (~2.8:1 on white, **fails AA**) to
  **`#6B6B6B`** (~4.9:1, **passes AA** for normal text). One-line token change; all ~70
  `.secondaryText` sites (body copy, hints, chevrons, and `secondaryText.withOpacity(0.5)`
  placeholders) inherit the fix. `flutter analyze`: **0 errors / 0 warnings**. **Resolved:** B3
  contrast; C1·Log In (helper #6), Search·#301 (faded placeholder), Profile/settings chevron-label
  rows, forgot-password body #6 — the app-wide body-copy contrast failure. **Note:** this is an
  intentional global visual change (all secondary text darkens) — approved.
- ✅ **3.2** `fix(a11y): raise sub-12 Text to 12px floor` — bumped `fontSize:11 → 12` on 7 plain leaf
  `Text` widgets: search selection-count chip (487), imagedetailed SPF badge (190), ingridients
  status label (193), login_feature_cards score `94/100` (120) + scan subtitle (265) + pill label
  (373), profile env badge (136), ingredient_bubbles legend status-label (394) + concentration (404).
  1px bumps, no layout risk. `flutter analyze`: **0 errors / 0 warnings**. **Resolved (font-size
  part):** C·ingredient_bubbles legend, feature-card sub-12, search count. **Excluded/deferred:**
  **paywall** 587 → I10; **startanalys** 253 → **I12** (widget is unrouted/dead — no route or
  external instantiation); **share_card** (7.5/9) + **score_breakdown** (8/9/9.5) → **I4** (text
  inside `CustomPaint`/`TextPainter` — rebuilt with the score system, changing size now risks
  painter layout). Non-color status cue on the ingredient_bubbles label stays for **I4**.
- ✅ **3.3** `fix(a11y): enforce >=44-48px tap targets` — (a) **app-bar icon-button fleet**: all
  `FlutterFlowIconButton buttonSize:40 → 48` (+ `borderRadius:20 → 24` to keep the circle), 7 buttons
  across 5 files (langs, countries, imagesby_album ×2, forgot_password, edit_profile ×2) — Material
  48 floor. (b) **shareproduct** back: bare `InkWell`+`Icon(24)` → 44×44 `SizedBox` hit area
  (`Align.centerStart` keeps the arrow's visual position). (c) **search** filter chip (~32px) →
  `minHeight:44` + center. (d) **onboarding_profile** preset-avatar tile 44×44 → 48×48.
  `flutter analyze`: **0 errors / 0 warnings**; tests `+9 -1` (pre-existing boilerplate failure only).
  **Resolved:** B3 tap-target rows — Search·#302 (chip), Onboarding Profile·#187 (avatars),
  shareproduct/settings/albums back buttons·#450-type. **Excluded (verified):** share_card 45×45
  avatar is **non-interactive** (static share image — N/A); routine step rows → module deleted;
  navbar → team-modified (re-review); password toggles → already component-owned (Initiative 1).
- ✅ **3.4** `fix(a11y): create_account autofocus email only` — the password field
  (`AppTextField.password`) had `autofocus:true` alongside the email field's, so it silently won and
  the screen opened focused on **password**. Set the password field to `autofocus:false`; email now
  receives initial focus. `flutter analyze`: **0 errors / 0 warnings**. **Resolved:** Create
  Account·#5 (double autofocus — the behavior finding deferred back in Initiative 1.2).

### Initiative 3 — completion summary
**Delivered a11y baseline:** (1) **contrast** — `secondaryText` #929292→#6B6B6B (AA) app-wide;
(2) **12px floor** — 7 sub-12 leaf `Text` widgets bumped to 12; (3) **tap targets** — icon-button
fleet 40→48, shareproduct/search/onboarding hit areas to ≥44–48; (4) **behavior** — create_account
autofocus fixed. `flutter analyze` clean throughout; tests `+9 -1` (pre-existing boilerplate only).
**Findings resolved:** B3 (contrast, 12px floor, min tap targets) + Create Account·#5.
**Explicitly carried forward (tracked, not skipped):**
- **Non-color status cues** (score rings / ingredient-highlight / status dots = color-only) → **I4**
  (built with `statusColor`/`ScoreRing`/`StatusLegend`).
- **Painter-embedded sub-12** (share_card 7.5/9px, score_breakdown 8/9/9.5px, radar) → **I4**.
- **paywall** sub-12 → **I10**; **startanalys** sub-12 → **I12** (unrouted/dead).
- **Untranslated a11y strings** (`'Retry'`, `'Delete'`, `'Active'/'Issues'`, forgot-pw feedback) → **I12**.

---

## Initiative 4 — Semantic color + score system  ·  Status: In Progress

**Goal:** one score ramp + one status palette + non-color cues, replacing the copy-pasted and
**contradictory** score/status logic. Source: DESIGN_REVIEW cluster **B2** + score/status a11y rows
(incl. the non-color-cue + painter sub-12 items **deferred here from Initiative 3**).

**Contradictions found (evidence):**
- **Score ramp** — identical 5-tier `_scoreColor`(0–100) + A–F grade copy-pasted in **3 files**
  (share_card, imagedetailed_main, imagedetailed_top_raited): `≥75 #1B5E20 · ≥65 #43A047 · ≥55
  #C0CA33 · ≥45 #FFB300 · ≥35 #FF7043 · <35 #D32F2F`.
- **Status palette** — 3 mappings for the same `working`/`borderline`/`decorative`: product_card_v2
  (working **green**, borderline amber, decorative grey), score_breakdown painter (working **green**
  #2E7D32, amber #F9A825, grey #9E9E9E), ingredient_bubbles (working **amber** #FFB300, borderline
  steel #78909C, decorative muted #90A4AE) — ingredient_bubbles inverts the meaning.
- product_card_v2 `_fitColor` uses a different 3-tier cutoff (75/60) + dead dark-mode branches
  (app has no dark mode); painters add more ad-hoc greens/ambers/slate-blues.

**Decisions (approved):** adopt the **majority 5-tier ramp** as canonical; **status semantics:
working = good → GREEN**, borderline amber, decorative & unknown grey. Non-color cues: score uses
the **grade letter** (already redundant); status gets an **icon** (`statusIcon`). Single light-mode
palette (no dark branching). API lives in `lib/design_system/foundations/score_status.dart` as pure,
context-free functions (painters need it without `BuildContext`).

**Commit plan:** 4.1 foundation file · 4.2 migrate the 3 score-ramp sites · 4.3 reconcile status
palette (product_card_v2 + ingredient_bubbles) · 4.4 painters (score_breakdown / radar: shared colors
+ sub-12 fix) · 4.5 non-color status cues (icons).

**Commits:**
- ✅ **4.1** `feat(ds): add score_status foundation` — new
  `lib/design_system/foundations/score_status.dart`: `semanticScoreColor(score)` + `scoreGrade(score)`
  (5-tier canonical ramp, A–F), `statusColor(status)` + `statusIcon(status)` (working green / borderline
  amber / decorative & unknown grey), with `k*` const palette. Pure/context-free (single light mode).
  No migration yet — findings resolve as sites route through it in 4.2–4.5. `flutter analyze`: **No
  issues found** (file); project **0 errors / 0 warnings**.
- ✅ **4.2** `refactor(score): route 3 score-ramp sites through score_status` — replaced the copy-pasted
  ramp with the shared foundation: **share_card** (`_scoreColor`+`_scoreGrade` top-level fns deleted;
  `_miniBar`/badge call `semanticScoreColor`/`scoreGrade`), **imagedetailed_main** (`_scoreColor` fn
  deleted; bg-tint + badge + `_ScoreBadge._grade` getter now call the shared fns), **imagedetailed_top_raited**
  (`_ScoreBadge._color`/`_grade` getters collapsed to shared-fn one-liners). **Value-identical** — same
  thresholds (75/65/55/45/35) and colors, zero visual change; pure de-duplication. `flutter analyze`:
  **0 errors / 0 warnings**; tests `+9 -1` (pre-existing only). **Resolved:** B2 score-ramp
  duplication (3 sites → 1). **Note:** a separate `greenText #1B5E20` const in share_card (positive-delta
  text, not the ramp) is left untouched — belongs to the later share_card raw-hex cleanup.
- ✅ **4.3** `refactor(status): reconcile status palette via score_status` — routed both status
  surfaces through the shared `statusColor()`, resolving the 3-way contradiction. **ingredient_bubbles**:
  deleted local `_kWorking/_kBorderline/_kDecorative/_kUnknown` + `_statusColor` → bubbles now
  **working green (was amber), borderline amber (was steel), decorative grey** (intentional recolor per
  the approved decision). **product_card_v2**: deleted local `_statusColor`; dropped the dead
  brightness-aware branches (`_isDark` + dark variants — app has no dark mode), `_goodColor/_warnColor/
  _badColor` now light-only `static const` (value-identical, still feed `_fitColor` + severity), ring
  shadow opacity `_isDark?0.22:0.28 → 0.28`. Status dot (396) + label (761) call `statusColor()`.
  `flutter analyze`: **0 errors / 0 warnings**; tests `+9 -1`. **Resolved:** B2 status-palette
  contradiction (working=green everywhere). **Deferred to 4.5:** status **label text** is still colored
  by status (pre-existing amber-on-white + the decorative grey shifted #6B6B6B→#9E9E9E) — 4.5 switches
  status labels to legible ink + an icon cue, removing color-from-text. **Note:** `_fitColor`'s 3-tier
  75/60 cutoff is untouched (score-scale reconciliation, not status) — tracked for a later look.
