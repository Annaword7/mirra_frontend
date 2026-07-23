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
| 5 | Empty vs loading — `SkeletonGrid` + `MirraEmptyState` | B4 | Not Started | High | M |
| 6 | Sheets & dialogs — `MirraBottomSheet`/`MirraDialogCard`/`MirraDragHandle` | B5 | Not Started | High | M |
| 7 | Product surfaces — `ProductTile`/`MirraInfoCard`/`MirraChip`/`ScoreBadge` | B6 | Not Started | High | L |
| 8 | Confirmation & limit consolidation — `ConfirmationSheet`/`ConfirmDialog`/`LimitReached`; delete `makepubluc` | B7 | Not Started | High | S |
| 9 | Settings & rows — `SettingsRow`/`SelectableRow`/`SettingsList` | B8 | Not Started | Medium | M |
| 10 | Paywall — `PlanCard`/`FeatureRow`/`ProPill`/dark palette | B9 | Not Started | Medium | M |
| 11 | Typography hygiene — roles over raw TextStyle, `displayXS`, kill local scales | B11 | Not Started | Medium | M |
| 12 | Localization & dead-code cleanup — inline strings→FFLocalizations, remove dead code | B12 | Not Started | Medium | S |
| 13 | Layout constants — `kNavBarHeight`, spacing tokens for magic offsets | B13 | Not Started | Low | S |

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
