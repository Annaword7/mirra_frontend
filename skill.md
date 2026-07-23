# Mirra UI design system (onboarding & settings)

Single source of truth for the light, neutral, left-aligned look used across
onboarding (`onboarding_quiz`, `onboarding_profile`, `newblank`), the
quick-setup sheet, and settings screens (`langs`, `countries`). Apply these
verbatim when restyling a screen.

## Surface
- **Background:** white — `Colors.white`.
- No coloured (blue) app-bar / hero headers. App bars are white, flat
  (`elevation: 0`), with a black back icon.

## Text
- **Always black** — `Color(0xFF1A1A1A)` (the `_ink` token). No grey text
  anywhere. Grey (`Color(0xFF555555)`) is allowed **only for icons** and for
  **disabled / "max reached"** states — never for readable copy.
- **Exactly three sizes** (no others):
  - **Title** — `24`, `FontWeight.w700` — the large step / screen title.
  - **Body** — `16` — primary text, option/answer labels, field text, buttons.
  - **Sub** — `13` — secondary / helper / caption text.
- App-bar / screen header title: black, **not bold** (`w500`), size `24`,
  left-aligned.

## Fields & selectable cards
- **Fill:** neutral grey `Color(0xFFF3F4F6)`.
- **Radius:** `12`. **Elevation:** `0`.
- **Selected state:** `2px` primary (blue) border — `Border.all(color:
  selected ? primary : Colors.transparent, width: 2)`. Do not use a coloured
  check icon to signal selection; the border does it.
- Selection / trailing icons: neutral grey `Color(0xFF555555)`.
- On a white sheet a white field needs a `1.5px` `Color(0xFFE0E0E0)` outline to
  stay visible (otherwise prefer the grey fill above).

## Layout / spacing
- **Horizontal inset:** `16` on the left (and right) for all content.
- **Between blocks (sections):** `24`.
- **Within a group (items in a list):** `12`.
- **Label → control:** `10`.
- All content **left-aligned** (`CrossAxisAlignment.start`, `TextAlign` left).
  Centered text/elements are only for transient confirm modals.

## Buttons (one standard everywhere)
- **Shape:** full width (`width: double.infinity`), **height 52**, corner
  **radius 14**, `elevation: 0`. Same radius/height for primary & secondary.
- **Text:** **16**, `FontWeight.w600`, centred, no letter spacing.
- **Internal padding:** vertical `14`, horizontal `24` (or rely on the fixed
  52 height + centered label). Leading icon: size `20`, `8` gap to the label.
- **Primary (CTA):** fill = theme `primary`, text white. Disabled = primary @
  60% opacity. This is the only place colour is used.
- **Secondary:** white fill + `1.5px` `Color(0xFFE0E0E0)` border, text black
  (or `primary`), same height/radius.
- **Text / link button:** no fill, text `16`, `primary` or black.
- **Spacing:** `8` between stacked buttons; buttons sit inside the 16px inset.
- Do NOT mix pill (radius 50), 30, 28… — always `14`.

## Accents
- Primary CTA buttons keep the theme `primary` fill with white text — this is
  the only place colour is used. Secondary text links may keep `primary`.
