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
| 1 | **Inputs** — `AppTextField` (visible focus, one fill/border/radius, password toggle) | B10 | **In Progress (planning)** | High | S–M |
| 2 | Button system — `PrimaryButton`/`Secondary`/`Pill`/`Destructive` | B1 | Not Started | High | L |
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

## Initiative 1 — Inputs (`AppTextField`)  ·  Status: In Progress (planning)

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

**Deferred within this initiative (tracked, not dropped):** Search bar (C3·Search·#1) → future `AppSearchField`; `guest_prefs` dropdown → future dropdown component. Password-toggle label localization → Initiative 12.
