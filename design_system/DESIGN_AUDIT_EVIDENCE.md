# Mirra — Raw Audit Evidence (validation pass)

Every hit is a real `grep -n` match in `lib/` (excluding `internationalization.dart` and `flutter_flow_theme.dart`), across 262 Dart files.
Format: `file:line: source line`. Widget/class = the primary class in that file (FlutterFlow convention: `foo_widget.dart` → `FooWidget`/`_FooWidgetState`; `foo.dart` → the class it declares).
Generated 2026-07-22 against v2.4.0+102.

---
## 1. Dead token layer (Critical)

`designToken`/`FFDesignTokens`/`FFSpacing`/`FFRadius`/`FFShadows` referenced **0 times** outside their own definition in `flutter_flow_theme.dart`:
```
$ grep -rn 'designToken|FFDesignTokens|FFSpacing|FFRadius|FFShadows' lib/**/*.dart | grep -v flutter_flow_theme.dart
(no output above = zero usage in feature code)
```
→ The token layer exists but every widget hardcodes values instead. Root cause of everything below.

---
## 2. Color inconsistencies

### 2a. textPrimary duplicated as literal Color(0xFF1A1A1A)

**Occurrences:** 19 · **Why replace:** Exact value of theme.primaryText — reference the token, do not re-declare it.

```
search/search_widget.dart:545: color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
settings/langs/langs_widget.dart:60: color: const Color(0xFF1A1A1A),
settings/langs/langs_widget.dart:75: color: const Color(0xFF1A1A1A),
settings/langs/langs_widget.dart:156: color: const Color(0xFF1A1A1A),
settings/countries/countries_widget.dart:91: color: const Color(0xFF1A1A1A),
settings/countries/countries_widget.dart:106: color: const Color(0xFF1A1A1A),
settings/countries/countries_widget.dart:144: const Color(0xFF1A1A1A),
settings/countries/countries_widget.dart:241: const Color(0xFF1A1A1A),
settings/countries/countries_widget.dart:278: const Color(0xFF1A1A1A),
home/home/home_widget.dart:765: : const Color(0xFF1A1A1A),
limits/limit_out/limit_out_widget.dart:9:const _ink = Color(0xFF1A1A1A);
topratings/toprated/toprated_widget.dart:250: color: sel ? Colors.white : const Color(0xFF1A1A1A),
topratings/toprated/toprated_widget.dart:286: color: sel ? Colors.white : const Color(0xFF1A1A1A),
pages/onboarding_quiz/onboarding_quiz_widget.dart:74: static const Color _ink = Color(0xFF1A1A1A); // black-ish text
components/ingredient_bubbles/ingredient_bubbles_widget.dart:284: final ink = Color.lerp(bubbleColor, const Color(0xFF1A1A1A), 0.7)!;
components/ingredient_bubbles/ingredient_bubbles_widget.dart:374: color: Color(0xFF1A1A1A),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:45: color: Color(0xFF1A1A1A),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:167: color: const Color(0xFF1A1A1A),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:179: color: const Color(0xFF1A1A1A),
```

### 2b. Near-duplicate near-black Color(0xFF1A1A1D)

**Occurrences:** 6 · **Why replace:** 3-unit variant of primaryText (#1A1A1A); a hue nobody chose — collapse to textPrimary.

```
components/share_card_sheet_widget.dart:129: ? Color(0xFF1A1A1D)
components/share_card_sheet_widget.dart:131: Color(0xFF1A1A1D),
components/share_card_sheet_widget.dart:137: ? Color(0xFF1A1A1D)
components/share_card_sheet_widget.dart:139: Color(0xFF1A1A1D),
components/share_card_sheet_widget.dart:180: : Color(0xFF1A1A1D),
components/share_card_sheet_widget.dart:188: : Color(0xFF1A1A1D),
```

### 2c. primary blue duplicated Color(0xFF5C85D9)

**Occurrences:** 10 · **Why replace:** Exact value of theme.primary — reference the token.

```
home/takeor_upload_page/takeor_upload_page_widget.dart:1676: colors: [Color(0xFF5C85D9), dark],
custom_code/widgets/share_card_widget.dart:381: const primary = Color(0xFF5C85D9);
custom_code/widgets/share_card_widget.dart:509: static const _primary = Color(0xFF5C85D9);
custom_code/widgets/share_card_widget.dart:613: static const _primary = Color(0xFF5C85D9);
custom_code/widgets/share_card_widget.dart:710: static const _primary = Color(0xFF5C85D9);
custom_code/widgets/animated_paywall_bg.dart:101: color: const Color(0xFF5C85D9).withOpacity(0.18),
pages/log_in_page/login_feature_cards.dart:213: colors: [Color(0xFF5C85D9), dark],
pages/log_in_page/login_feature_cards.dart:289: (label: 'Hyaluronic Acid', color: Color(0xFF5C85D9)),
components/feedback_collector/feedback_collector_widget.dart:175: const Color(0xFF5C85D9),
components/feedback_collector/feedback_collector_widget.dart:182: color: const Color(0xFF5C85D9).withAlpha(80),
```

### 2d. primaryVariant ad-hoc Color(0xFF3B6FCC)

**Occurrences:** 3 · **Why replace:** Pressed-blue defined inline; promote to a primaryVariant token.

```
components/score_breakdown/score_breakdown_widget.dart:96: ..color = const Color(0xFF3B6FCC)
components/score_breakdown/score_breakdown_widget.dart:111: final vtxP = Paint()..color = const Color(0xFF3B6FCC);
components/score_breakdown/score_breakdown_widget.dart:261: border: Border.all(color: const Color(0xFF3B6FCC), width: 1.4),
```

### 2e. Three competing ERROR reds (semantic ambiguity — no single error token)

###   red #FF5963 (= theme.error, hardcoded)

**Occurrences:** 9 · **Why replace:** Duplicates theme.error; should reference it.

```
pages/profile/profile_widget.dart:837: border: Border.all(color: const Color(0xFFFF5963)),
pages/profile/profile_widget.dart:844: const Icon(Icons.replay_rounded, color: Color(0xFFFF5963), size: 24.0),
pages/profile/profile_widget.dart:850: color: const Color(0xFFFF5963),
pages/profile/profile_widget.dart:887: border: Border.all(color: const Color(0xFFFF5963)),
pages/profile/profile_widget.dart:894: const Icon(Icons.rate_review_outlined, color: Color(0xFFFF5963), size: 24.0),
pages/profile/profile_widget.dart:900: color: const Color(0xFFFF5963),
pages/profile/profile_widget.dart:933: border: Border.all(color: const Color(0xFFFF5963)),
pages/profile/profile_widget.dart:940: const Icon(Icons.visibility_outlined, color: Color(0xFFFF5963), size: 24.0),
pages/profile/profile_widget.dart:946: color: const Color(0xFFFF5963),
```

###   red #D32F2F (second red, same meaning)

**Occurrences:** 8 · **Why replace:** A different red for the SAME error/destructive meaning — collapse to one error token.

```
custom_code/widgets/share_card_widget.dart:40: return const Color(0xFFD32F2F);
boards/edit_album/edit_album_widget.dart:84: style: TextStyle(color: Color(0xFFD32F2F)),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:51: return const Color(0xFFD32F2F);
item_card/deleteitem/deleteitem_widget.dart:79: color: Color(0xFFD32F2F),
item_card/deleteitem/deleteitem_widget.dart:133: backgroundColor: const Color(0xFFD32F2F),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:224: return const Color(0xFFD32F2F);
components/product_card_v2/product_card_v2_widget.dart:103: _isDark ? const Color(0xFFEF5350) : const Color(0xFFD32F2F);
components/error_popup/error_popup_widget.dart:86: iconColor: const Color(0xFFD32F2F),
```

###   red #E53935 (third red, same meaning)

**Occurrences:** 3 · **Why replace:** A third red for error/destructive — collapse.

```
pages/routine_calendar/routine_calendar_widget.dart:889: color: Color(0xFFE53935),
components/score_breakdown/score_breakdown_widget.dart:280: child: _dot(12, const Color(0xFFE53935), true),
components/score_breakdown/score_breakdown_widget.dart:407: color: high ? const Color(0xFFC62828) : const Color(0xFFE53935),
```

###   error-bg tints #FFE0E0 / #FFEEEE / #FFEBEE

**Occurrences:** 7 · **Why replace:** Three near-identical error backgrounds — collapse to errorBg.

```
custom_code/widgets/share_card_widget.dart:309: const redBg = Color(0xFFFFEBEE);
item_card/deleteitem/deleteitem_widget.dart:74: color: const Color(0xFFFFEEEE),
item_card/ingridients/ingridients_widget.dart:30: static const _redBg = Color(0xFFFFEBEE);
pages/profile/profile_widget.dart:835: color: const Color(0xFFFFE0E0),
pages/profile/profile_widget.dart:885: color: const Color(0xFFFFE0E0),
pages/profile/profile_widget.dart:931: color: const Color(0xFFFFE0E0),
components/error_popup/error_popup_widget.dart:85: iconBg: const Color(0xFFFFEEEE),
```

### 2f. Six+ WARNING/amber tones (no single warning token)

###   ambers #FFB300/#FBBF23/#F9A825/#E07A00/#FF7043/#E65100

**Occurrences:** 23 · **Why replace:** Six ambers for the same 'caution' meaning — collapse to warning.

```
itemcard2/itemcard2_widget.dart:1715: ? const Color(0xFFFF7043).withOpacity(0.35)
home/takeor_upload_page/takeor_upload_page_widget.dart:1737: child: Icon(Icons.check_sharp, color: Color(0xFFFBBF23), size: 20),
home/takeor_upload_page/takeor_upload_page_widget.dart:1784: color: Color(0xFFFBBF23),
home/takeor_upload_page/takeor_upload_page_widget.dart:1810: color: Color(0xFFFBBF23),
home/takeor_upload_page/takeor_upload_page_widget.dart:1826: color: Color(0xFFFBBF23),
home/takeor_upload_page/takeor_upload_page_widget.dart:1855: color: Color(0xFFFBBF23),
custom_code/widgets/share_card_widget.dart:38: if (s >= 45) return const Color(0xFFFFB300);
custom_code/widgets/share_card_widget.dart:39: if (s >= 35) return const Color(0xFFFF7043);
item_card/imagedetailed_main/imagedetailed_main_widget.dart:49: if (score >= 45) return const Color(0xFFFFB300);
item_card/imagedetailed_main/imagedetailed_main_widget.dart:50: if (score >= 35) return const Color(0xFFFF7043);
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:222: if (s >= 45) return const Color(0xFFFFB300);
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:223: if (s >= 35) return const Color(0xFFFF7043);
pages/cosmetic_bag/cosmetic_bag_widget.dart:345: color: Color(0xFFE07A00), size: 14),
pages/cosmetic_bag/cosmetic_bag_widget.dart:352: color: Color(0xFFE07A00),
pages/cosmetic_bag/cosmetic_bag_widget.dart:374: color: stale ? const Color(0xFFE07A00) : Colors.black54,
pages/cosmetic_bag/cosmetic_bag_widget.dart:487: color: Color(0xFFE07A00),
components/product_card_v2/product_card_v2_widget.dart:101: _isDark ? const Color(0xFFFFCA28) : const Color(0xFFFFB300);
components/error_popup/error_popup_widget.dart:54: iconColor: const Color(0xFFE65100),
components/error_popup/error_popup_widget.dart:78: iconColor: const Color(0xFFF9A825),
components/error_popup/error_popup_widget.dart:463: color: Color(0xFFE65100),
components/ingredient_bubbles/ingredient_bubbles_widget.dart:7:const _kWorking = Color(0xFFFFB300); // amber — активно работает
components/score_breakdown/score_breakdown_widget.dart:272: child: _dot(12, const Color(0xFFF9A825), true),
components/score_breakdown/score_breakdown_widget.dart:377: c = const Color(0xFFF9A825);
```

###   warning-bg #FFF3E0

**Occurrences:** 2 · **Why replace:** Amber tint — promote to warningBg.

```
components/error_popup/error_popup_widget.dart:53: iconBg: const Color(0xFFFFF3E0),
components/error_popup/error_popup_widget.dart:458: color: Color(0xFFFFF3E0),
```

### 2g. Four SUCCESS greens (no single success token)

###   greens #1B5E20/#2E7D32/#43A047 (+ theme teal #048178)

**Occurrences:** 14 · **Why replace:** Four greens/teal for the same 'safe/success' meaning; theme teal rarely used.

```
itemcard2/itemcard2_widget.dart:1113: ? const Color(0xFF2E7D32)
custom_code/widgets/share_card_widget.dart:35: if (s >= 75) return const Color(0xFF1B5E20);
custom_code/widgets/share_card_widget.dart:36: if (s >= 65) return const Color(0xFF43A047);
custom_code/widgets/share_card_widget.dart:306: const greenText = Color(0xFF1B5E20);
item_card/imagedetailed_main/imagedetailed_main_widget.dart:46: if (score >= 75) return const Color(0xFF1B5E20);
item_card/imagedetailed_main/imagedetailed_main_widget.dart:47: if (score >= 65) return const Color(0xFF43A047);
item_card/ingridients/ingridients_widget.dart:27: static const _greenText = Color(0xFF1B5E20);
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:219: if (s >= 75) return const Color(0xFF1B5E20);
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:220: if (s >= 65) return const Color(0xFF43A047);
pages/log_in_page/login_feature_cards.dart:44: static const _scoreColor = Color(0xFF43A047);
components/product_card_v2/product_card_v2_widget.dart:99: _isDark ? const Color(0xFF66BB6A) : const Color(0xFF1B5E20);
components/score_breakdown/score_breakdown_widget.dart:268: child: _dot(12, const Color(0xFF2E7D32), true),
components/score_breakdown/score_breakdown_widget.dart:373: c = const Color(0xFF2E7D32);
components/score_breakdown/score_breakdown_widget.dart:385: c = const Color(0xFF2E7D32);
```

###   success-bg #E8F5E9

**Occurrences:** 2 · **Why replace:** Green tint — promote to successBg.

```
custom_code/widgets/share_card_widget.dart:307: const greenBg = Color(0xFFE8F5E9);
item_card/ingridients/ingridients_widget.dart:28: static const _greenBg = Color(0xFFE8F5E9);
```

### 2h. Grey family sprawl

###   surface greys #F3F4F6/#F2F2F2/#F5F7FF/#F5F8FF

**Occurrences:** 23 · **Why replace:** Four near-white surfaces — collapse to surfaceMuted.

```
itemcard2/itemcard2_widget.dart:1148: color: const Color(0xFFF5F8FF),
itemcard2/itemcard2_widget.dart:1319: color: const Color(0xFFF5F8FF),
search/search_widget.dart:359: fillColor: const Color(0xFFF3F4F6),
search/search_widget.dart:534: color: isSelected ? theme.primary : const Color(0xFFF3F4F6),
components/profile_summary_card.dart:166: color: const Color(0xFFF2F2F2),
settings/langs/langs_widget.dart:132: color: const Color(0xFFF3F4F6),
settings/countries/countries_widget.dart:203: color: const Color(0xFFF3F4F6),
home/home/home_widget.dart:737: : const Color(0xFFF3F4F6),
custom_code/widgets/share_card_widget.dart:510: static const _bg = Color(0xFFF5F7FF);
custom_code/widgets/share_card_widget.dart:614: static const _bg = Color(0xFFF5F7FF);
topratings/toprated/toprated_widget.dart:244: color: sel ? theme.primary : const Color(0xFFF3F4F6),
topratings/toprated/toprated_widget.dart:280: color: sel ? theme.primary : const Color(0xFFF3F4F6),
topratings/toprated/toprated_widget.dart:520: : const Color(0xFFF3F4F6),
pages/routine_calendar/routine_calendar_widget.dart:584: color: const Color(0xFFF2F2F2),
pages/routine_calendar/routine_calendar_widget.dart:739: color: const Color(0xFFF2F2F2),
pages/onboarding_profile/onboarding_profile_widget.dart:220: fillColor: const Color(0xFFF3F4F6),
pages/onboarding_profile/onboarding_profile_widget.dart:543: backgroundColor: const Color(0xFFF3F4F6),
pages/log_in_page/login_feature_cards.dart:8:const _kCardBg = Color(0xFFF5F8FF);
pages/onboarding_quiz/onboarding_quiz_widget.dart:76: static const Color _card = Color(0xFFF3F4F6); // answer background
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:150: color: const Color(0xFFF2F2F2),
components/score_breakdown/score_breakdown_widget.dart:441: color: const Color(0xFFF5F8FF),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:35: color: const Color(0xFFF3F4F6),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:197: fillColor: const Color(0xFFF3F4F6),
```

###   border greys #E0E0E0/#E6E6E6/#E7E8EB

**Occurrences:** 22 · **Why replace:** Three border/divider greys — collapse to border+divider.

```
itemcard2/itemcard2_widget.dart:1788: color: const Color(0xFFE0E0E0),
search/search_widget.dart:537: color: isSelected ? theme.primary : const Color(0xFFE0E0E0),
components/home_pipeline_widget.dart:96: border: Border.all(color: const Color(0xFFE6E6E6)),
components/profile_summary_card.dart:168: border: Border.all(color: const Color(0xFFE0E0E0)),
home/home/home_widget.dart:745: : const Color(0xFFE0E0E0),
item_card/markasspam/markasspam_widget.dart:132: color: const Color(0xFFE0E0E0),
item_card/markasspam/markasspam_widget.dart:145: color: const Color(0xFFE0E0E0),
pages/compatibility_result/compatibility_result_widget.dart:580: border: Border.all(color: const Color(0xFFE6E6E6)),
pages/compatibility_result/compatibility_result_widget.dart:694: backgroundColor: const Color(0xFFE6E6E6),
pages/routine_calendar/routine_calendar_widget.dart:365: color: selected == d ? primary : const Color(0xFFE6E6E6),
pages/routine_calendar/routine_calendar_widget.dart:549: border: Border.all(color: const Color(0xFFE6E6E6)),
pages/routine_calendar/routine_calendar_widget.dart:1081: : const Color(0xFFE6E6E6),
pages/cosmetic_bag_intro/cosmetic_bag_intro_widget.dart:319: color: filled ? theme.primary : const Color(0xFFE6E6E6),
pages/profile/profile_widget.dart:1028: color: Color(0xFFE7E8EB),
pages/profile/profile_widget.dart:1125: color: Color(0xFFE7E8EB),
pages/profile/profile_widget.dart:1141: color: Color(0xFFE7E8EB),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:83: color: const Color(0xFFE0E0E0),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:210: borderColor: const Color(0xFFE0E0E0),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:37: border: Border.all(color: const Color(0xFFE0E0E0)),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:157: color: const Color(0xFFE0E0E0),
topratings/copyitem/copyitem_widget.dart:131: color: const Color(0xFFE0E0E0),
topratings/copyitem/copyitem_widget.dart:144: color: const Color(0xFFE0E0E0),
```

###   text greys #555555/#333333/#9E9E9E/#AFAFB0/#AEAEAE

**Occurrences:** 23 · **Why replace:** Five greys for secondary/tertiary/disabled text — collapse to 2-3 tokens.

```
components/profile_summary_card.dart:173: color: const Color(0xFF333333),
components/profile_summary_card.dart:186: color: const Color(0xFF555555), fontSize: 13, letterSpacing: 0),
components/share_card_sheet_widget.dart:130: : Color(0xFFAFAFB0),
components/share_card_sheet_widget.dart:138: : Color(0xFFAFAFB0),
components/share_card_sheet_widget.dart:179: ? Color(0xFFAFAFB0)
components/share_card_sheet_widget.dart:181: Color(0xFFAFAFB0),
components/share_card_sheet_widget.dart:187: ? Color(0xFFAFAFB0)
components/share_card_sheet_widget.dart:189: Color(0xFFAFAFB0),
settings/langs/langs_widget.dart:168: color: const Color(0xFF555555),
settings/countries/countries_widget.dart:296: color: const Color(0xFF555555),
settings/countries/countries_widget.dart:304: color: const Color(0xFF555555),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:222: color: Color(0xFF333333),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:146: color: Color(0xFF333333),
pages/routine_calendar/routine_calendar_widget.dart:413: color: selected ? Colors.white : const Color(0xFFAEAEAE),
pages/routine_calendar/routine_calendar_widget.dart:510: color: pushEnabled ? primary : const Color(0xFFAEAEAE),
pages/routine_calendar/routine_calendar_widget.dart:831: color: Color(0xFF9E9E9E), size: 22),
pages/routine_calendar/routine_calendar_widget.dart:1020: color: value ? primary : const Color(0xFFAEAEAE),
pages/routine_calendar/routine_calendar_widget.dart:1138: color: Color(0xFF9E9E9E), size: 22),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:158: color: Color(0xFF555555)),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:207: iconColor: const Color(0xFF555555),
components/score_breakdown/score_breakdown_widget.dart:276: child: _dot(12, const Color(0xFF9E9E9E), false),
components/score_breakdown/score_breakdown_widget.dart:381: c = const Color(0xFF9E9E9E);
components/link_telegram_sheet/link_telegram_sheet_widget.dart:56: : const Color(0xFF555555),
```

### 2i. Overlay/scrim black-alpha values

###   overlays 0x14/1A/33/44 000000

**Occurrences:** 28 · **Why replace:** Four ad-hoc black alphas for shadows/scrims — standardize to a 4-step overlay ramp.

```
itemcard2/itemcard2_widget.dart:1035: color: Color(0x1A000000),
itemcard2/itemcard2_widget.dart:1153: color: Color(0x1A000000),
itemcard2/itemcard2_widget.dart:1331: color: Color(0x14000000),
home/takeor_upload_page/takeor_upload_page_widget.dart:111: color: Color(0x1A000000),
limits/limit_out/limit_out_widget.dart:66: color: Color(0x33000000),
topratings/makepubluc/makepubluc_widget.dart:61: color: Color(0x33000000),
item_card/markasspam/markasspam_widget.dart:66: color: Color(0x33000000),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:86: color: Color(0x33000000),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:176: color: Color(0x44000000),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:211: color: Color(0x44000000),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:354: color: Color(0x33000000),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:385: color: Color(0x33000000),
item_card/deleteitem/deleteitem_widget.dart:59: color: Color(0x1A000000),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:74: color: Color(0x33000000),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:135: color: Color(0x44000000),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:247: color: Color(0x33000000),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:277: color: Color(0x33000000),
pages/log_in_page/login_feature_cards.dart:23: color: Color(0x14000000),
components/error_popup/error_popup_widget.dart:108: color: Color(0x1A000000),
components/error_popup/error_popup_widget.dart:231: color: Color(0x1A000000),
components/error_popup/error_popup_widget.dart:444: color: Color(0x1A000000),
components/score_breakdown/score_breakdown_widget.dart:70: ..color = const Color(0x14000000)
components/score_breakdown/score_breakdown_widget.dart:85: ..color = const Color(0x1A000000)
components/score_breakdown/score_breakdown_widget.dart:446: color: Color(0x1A000000),
topratings/copyitem/copyitem_widget.dart:65: color: Color(0x33000000),
topratings/hidenavailability/hidenavailability_widget.dart:68: color: Color(0x33000000),
topratings/makepublic/makepublic_widget.dart:51: color: Color(0x33000000),
topratings/makeprivate/makeprivate_widget.dart:61: color: Color(0x33000000),
```

### 2j. FULL distinct hardcoded-color inventory (count · hex)

All **104** distinct hardcoded colors / **297** occurrences vs the 16-token theme:
```
  19 Color(0xFF1A1A1A)
  13 Color(0xFFF3F4F6)
  13 Color(0x33000000)
  12 Color(0xFFE0E0E0)
  10 Color(0xFF5C85D9)
   9 Color(0xFFFF5963)
   9 Color(0x1A000000)
   8 Color(0xFFD32F2F)
   7 Color(0xFFE6E6E6)
   7 Color(0xFF555555)
   6 Color(0xFFAFAFB0)
   6 Color(0xFF1B5E20)
   6 Color(0xFF1A1A1D)
   5 Color(0xFFFFB300)
   5 Color(0xFFFBBF23)
   4 Color(0xFFFF7043)
   4 Color(0xFFF5F8FF)
   4 Color(0xFFF2F2F2)
   4 Color(0xFFE07A00)
   4 Color(0xFF9E9E9E)
   4 Color(0xFF43A047)
   4 Color(0xFF2E7D32)
   4 Color(0xFF1565C0)
   3 Color(0xFFFFE0E0)
   3 Color(0xFFF9A825)
   3 Color(0xFFE7E8EB)
   3 Color(0xFFE53935)
   3 Color(0xFFC0CA33)
   3 Color(0xFFAEAEAE)
   3 Color(0xFF3B6FCC)
   3 Color(0xFF333333)
   3 Color(0x44000000)
   3 Color(0x14000000)
   2 Color(0xFFFFF3E0)
   2 Color(0xFFFFEEEE)
   2 Color(0xFFFFEBEE)
   2 Color(0xFFF5F7FF)
   2 Color(0xFFF3E5F5)
   2 Color(0xFFE8F5E9)
   2 Color(0xFFE65100)
   2 Color(0xFFE3F2FD)
   2 Color(0xFFD9534F)
   2 Color(0xFFB8860B)
   2 Color(0xFFB71C1C)
   2 Color(0xFFB0A6C9)
   2 Color(0xFFA7B6CC)
   2 Color(0xFF9A8FBF)
   2 Color(0xFF9489F5)
   2 Color(0xFF7B1FA2)
   2 Color(0xFF757575)
   2 Color(0xFF6B7280)
   2 Color(0xFF667799)
   2 Color(0xFF3A5CB8)
   2 Color(0xFF262D34)
   2 Color(0xFF14181B)
   2 Color(0xFF132444)
   2 Color(0xFF111111)
   2 Color(0xFF060D1E)
   2 Color(0xD25C85D9)
   2 Color(0xD15C85D9)
   2 Color(0x99000000)
   2 Color(0x284E7FE8)
   1 Color(0xFFFFFDE7)
   1 Color(0xFFFFF9EB)
   1 Color(0xFFFFF4E6)
   1 Color(0xFFFFCA28)
   1 Color(0xFFF7F7F7)
   1 Color(0xFFF5F5F5)
   1 Color(0xFFF4F4F4)
   1 Color(0xFFEF5350)
   1 Color(0xFFEBF0FC)
   1 Color(0xFFE8F4FD)
   1 Color(0xFFE6E6E9)
   1 Color(0xFFE07A5F)
   1 Color(0xFFCBDDFE)
   1 Color(0xFFC62828)
   1 Color(0xFFBDBDBD)
   1 Color(0xFFBBBBBB)
   1 Color(0xFF999999)
   1 Color(0xFF90A4AE)
   1 Color(0xFF888888)
   1 Color(0xFF78909C)
   1 Color(0xFF66BB6A)
   1 Color(0xFF666666)
   1 Color(0xFF5DBBAA)
   1 Color(0xFF4CAF50)
   1 Color(0xFF4A6FC7)
   1 Color(0xFF445588)
   1 Color(0xFF39D2C0)
   1 Color(0xFF2C2C2E)
   1 Color(0xFF1A1F2E)
   1 Color(0xFF1976D2)
   1 Color(0xFF180F3A)
   1 Color(0xFF111417)
   1 Color(0xFF0C1D45)
   1 Color(0xFF0C1A35)
   1 Color(0xCCFFFFFF)
   1 Color(0xCCFF6B00)
   1 Color(0xCCF9A825)
   1 Color(0x62FFFFFF)
   1 Color(0x55000000)
   1 Color(0x40000000)
   1 Color(0x39FFFFFF)
   1 Color(0x2B5C85D9)
```

---
## 3. Typography inconsistencies

### 3a. font-size distinct inventory (count · size). Theme scale = 12/14/16/18/22/24/32/36/45/57
```
   2 7.5
   1 8
   4 9
   2 9.5
   9 11
   4 11.0
  11 12
   7 12.0
   1 12.5
  29 13
   3 13.0
  10 14
   3 14.0
   2 15
  17 15.0
  12 16
  27 16.0
   2 17
   3 18
   7 18.0
   5 20
   4 20.0
   1 21.0
   3 22.0
   3 24
   4 24.0
   1 26
   6 26.0
   2 28.0
   1 34
   1 36
```

### 3b. Illegible sub-12px sizes (accessibility failure)

**Occurrences:** 8 · **Why replace:** Below 12px readable minimum — bump to 12.

```
custom_code/widgets/share_card_widget.dart:258: fontSize: 7.5,
custom_code/widgets/share_card_widget.dart:288: fontSize: 7.5,
custom_code/widgets/share_card_widget.dart:467: fontSize: 9,
custom_code/widgets/share_card_widget.dart:540: fontSize: 9,
custom_code/widgets/share_card_widget.dart:643: fontSize: 9,
components/score_breakdown/score_breakdown_widget.dart:162: fontSize: 9.5,
components/score_breakdown/score_breakdown_widget.dart:168: fontSize: 9,
components/score_breakdown/score_breakdown_widget.dart:327: style: const TextStyle(fontSize: 9.5, color: Color(0xFF667799))),
```

### 3c. fontSize: 13 (off-scale, top offender)

**Occurrences:** 32 · **Why replace:** Not on the type scale; snap to bodyMedium (14).

```
itemcard2/itemcard2_widget.dart:1068: fontSize: 13,
itemcard2/itemcard2_widget.dart:2072: fontSize: 13,
flutter_flow/flutter_flow_language_selector.dart:148: fontSize: 13,
search/search_widget.dart:544: fontSize: 13,
components/home_pipeline_widget.dart:183: fontSize: 13,
components/profile_summary_card.dart:106: color: Colors.black54, fontSize: 13, letterSpacing: 0),
components/profile_summary_card.dart:150: fontSize: 13,
components/profile_summary_card.dart:186: color: const Color(0xFF555555), fontSize: 13, letterSpacing: 0),
home/home/home_widget.dart:762: fontSize: 13.0,
home/home/home_widget.dart:1194: fontSize: 13.0,
home/home/home_widget.dart:1207: fontSize: 13.0,
custom_code/widgets/share_card_widget.dart:752: fontSize: 13,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:220: fontSize: 13,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:368: fontSize: 13,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:410: fontSize: 13,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:420: fontSize: 13,
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:144: fontSize: 13,
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:261: fontSize: 13,
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:297: fontSize: 13,
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:311: fontSize: 13,
pages/compatibility_result/compatibility_result_widget.dart:743: style: const TextStyle(color: Colors.black, fontSize: 13),
pages/routine_calendar/routine_calendar_widget.dart:373: fontSize: 13,
pages/routine_calendar/routine_calendar_widget.dart:415: fontSize: 13,
pages/routine_calendar/routine_calendar_widget.dart:519: fontSize: 13,
pages/routine_calendar/routine_calendar_widget.dart:570: fontSize: 13,
pages/routine_calendar/routine_calendar_widget.dart:797: fontSize: 13,
pages/log_in_page/login_feature_cards.dart:111: fontSize: 13,
pages/log_in_page/login_feature_cards.dart:256: fontSize: 13,
pages/log_in_page/login_feature_cards.dart:330: fontSize: 13,
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:124: fontSize: 13,
components/product_card_v2/product_card_v2_widget.dart:346: fontSize: 13,
components/product_card_v2/product_card_v2_widget.dart:847: fontSize: 13,
```

### 3d. fontSize: 15 (off-scale)

**Occurrences:** 19 · **Why replace:** Not on the scale; snap to bodyLarge (16).

```
flutter_flow/flutter_flow_language_selector.dart:231: fontSize: 15,
home/takeor_upload_page/takeor_upload_page_widget.dart:175: fontSize: 15.0,
item_card/deleteitem/deleteitem_widget.dart:144: fontSize: 15.0,
item_card/deleteitem/deleteitem_widget.dart:168: fontSize: 15.0,
pages/cosmetic_bag_intro/cosmetic_bag_intro_widget.dart:221: fontSize: 15,
components/error_popup/error_popup_widget.dart:168: fontSize: 15.0,
components/error_popup/error_popup_widget.dart:299: fontSize: 15.0,
components/error_popup/error_popup_widget.dart:386: fontSize: 15.0,
components/error_popup/error_popup_widget.dart:413: fontSize: 15.0,
components/error_popup/error_popup_widget.dart:510: fontSize: 15.0,
components/error_popup/error_popup_widget.dart:534: fontSize: 15.0,
components/premium_features_list/premium_features_list_widget.dart:78: fontSize: 15.0,
components/premium_features_list/premium_features_list_widget.dart:122: fontSize: 15.0,
components/premium_features_list/premium_features_list_widget.dart:165: fontSize: 15.0,
components/premium_features_list/premium_features_list_widget.dart:208: fontSize: 15.0,
components/premium_features_list/premium_features_list_widget.dart:249: fontSize: 15.0,
components/premium_features_list/premium_features_list_widget.dart:290: fontSize: 15.0,
components/premium_features_list/premium_features_list_widget.dart:331: fontSize: 15.0,
components/premium_features_list/premium_features_list_widget.dart:372: fontSize: 15.0,
```

### 3e. fontSize: 11 (off-scale)

**Occurrences:** 13 · **Why replace:** Not on the scale; snap to bodySmall/labelSmall (12).

```
search/search_widget.dart:494: style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
home/startanalys/startanalys_widget.dart:253: fontSize: 11.0,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:190: fontSize: 11,
item_card/ingridients/ingridients_widget.dart:193: fontSize: 11,
pages/compatibility_result/compatibility_result_widget.dart:549: fontSize: 11,
pages/log_in_page/login_feature_cards.dart:120: fontSize: 11,
pages/log_in_page/login_feature_cards.dart:265: fontSize: 11,
pages/log_in_page/login_feature_cards.dart:373: fontSize: 11,
pages/profile/profile_widget.dart:136: fontSize: 11.0,
paywall/paywallpage/paywallpage_widget.dart:587: fontSize: 11.0,
components/navbar/navbar_widget.dart:137: fontSize: 11.0,
components/ingredient_bubbles/ingredient_bubbles_widget.dart:394: fontSize: 11,
components/ingredient_bubbles/ingredient_bubbles_widget.dart:404: fontSize: 11,
```

### 3f. FontWeight.bold vs .w700 (identical value, two spellings)

`FontWeight.bold` **is** `FontWeight.w700`. Distribution:
```
 145 FontWeight.w600
  67 FontWeight.bold
  39 FontWeight.w500
  27 FontWeight.w700
  14 FontWeight.normal
   1 FontWeight.w400
```
→ bold=67 vs w700=27. Pick one spelling.

---
## 4. Corner-radius inconsistencies

### 4a. BorderRadius.circular distinct inventory (count · value). FFRadius tokens = 8/16/24/full
```
 133 circular(8.0)
 105 circular(16.0)
  34 circular(12.0)
  33 circular(24.0)
  22 circular(12)
  21 circular(50.0)
  19 circular(4.0)
  18 circular(20)
  18 circular(16)
  16 circular(14)
  13 circular(8)
  12 circular(20.0)
  12 circular(14.0)
  11 circular(40.0)
   9 circular(30.0)
   7 circular(2)
   6 circular(10)
   5 circular(50)
   5 circular(24)
   4 circular(28.0)
   3 circular(30)
   3 circular(26)
   2 circular(36.0)
   2 circular(3)
   2 circular(10.0)
   1 circular(6.0)
   1 circular(6)
   1 circular(4)
   1 circular(280.0)
   1 circular(28)
   1 circular(25)
   1 circular(240.0)
   1 circular(0.0)
```

### 4b. circular(12) — off-token, 2nd most common radius

**Occurrences:** 56 · **Why replace:** Heavily used but no token; add radius.md=12.

```
itemcard2/itemcard2_widget.dart:483: borderRadius: BorderRadius.circular(12.0)),
itemcard2/itemcard2_widget.dart:517: borderRadius: BorderRadius.circular(12.0)),
itemcard2/itemcard2_widget.dart:620: borderRadius: BorderRadius.circular(12.0)),
itemcard2/itemcard2_widget.dart:1624: borderRadius: BorderRadius.circular(12)),
itemcard2/itemcard2_widget.dart:1656: borderRadius: BorderRadius.circular(12)),
itemcard2/itemcard2_widget.dart:1837: borderRadius: BorderRadius.circular(12),
search/search_widget.dart:362: borderRadius: BorderRadius.circular(12),
search/search_widget.dart:393: shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
search/search_widget.dart:659: shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
settings/langs/langs_widget.dart:133: borderRadius: BorderRadius.circular(12.0),
settings/countries/countries_widget.dart:205: BorderRadius.circular(12.0),
home/takeor_upload_page/takeor_upload_page_widget.dart:1881: borderRadius: BorderRadius.circular(12),
custom_code/widgets/share_card_widget.dart:637: borderRadius: BorderRadius.circular(12),
boards/albumslist/albumslist_widget.dart:86: borderRadius: BorderRadius.circular(12.0),
boards/edit_album/edit_album_widget.dart:124: borderRadius: BorderRadius.circular(12.0),
boards/boards/boards_widget.dart:286: borderRadius: BorderRadius.circular(12.0),
boards/boards/boards_widget.dart:300: borderRadius: BorderRadius.circular(12.0),
boards/boards/boards_widget.dart:334: borderRadius: BorderRadius.circular(12.0),
pages/routine_calendar/routine_calendar_widget.dart:408: borderRadius: BorderRadius.circular(12),
pages/routine_calendar/routine_calendar_widget.dart:474: borderRadius: BorderRadius.circular(12),
pages/routine_calendar/routine_calendar_widget.dart:787: borderRadius: BorderRadius.circular(12),
pages/routine_calendar/routine_calendar_widget.dart:1077: borderRadius: BorderRadius.circular(12),
pages/cosmetic_bag_intro/cosmetic_bag_intro_widget.dart:328: borderRadius: BorderRadius.circular(12),
pages/onboarding_quiz/onboarding_quiz_widget.dart:935: borderRadius: BorderRadius.circular(12),
pages/onboarding_quiz/onboarding_quiz_widget.dart:946: borderRadius: BorderRadius.circular(12),
paywall/paywallpage/paywallpage_widget.dart:204: borderRadius: BorderRadius.circular(12.0),
paywall/paywallpage/paywallpage_widget.dart:207: borderRadius: BorderRadius.circular(12.0),
paywall/paywallpage/paywallpage_widget.dart:212: borderRadius: BorderRadius.circular(12.0),
paywall/paywallpage/paywallpage_widget.dart:550: borderRadius: BorderRadius.circular(12.0),
paywall/paywallpage/paywallpage_widget.dart:553: borderRadius: BorderRadius.circular(12.0),
paywall/paywallpage/paywallpage_widget.dart:558: borderRadius: BorderRadius.circular(12.0),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:151: borderRadius: BorderRadius.circular(12),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:160: borderRadius: BorderRadius.circular(12),
components/product_card_v2/product_card_v2_widget.dart:295: borderRadius: BorderRadius.circular(12),
components/product_card_v2/product_card_v2_widget.dart:305: borderRadius: BorderRadius.circular(12),
components/product_card_v2/product_card_v2_widget.dart:836: borderRadius: BorderRadius.circular(12),
components/out_of_generations/out_of_generations_widget.dart:107: borderRadius: BorderRadius.circular(12.0),
components/error_popup/error_popup_widget.dart:344: borderRadius: BorderRadius.circular(12.0),
components/error_popup/error_popup_widget.dart:348: borderRadius: BorderRadius.circular(12.0),
components/error_popup/error_popup_widget.dart:352: borderRadius: BorderRadius.circular(12.0),
components/feedback_collector/negative_feedback_widget.dart:88: borderRadius: BorderRadius.circular(12.0),
components/gallery_loading_component/gallery_loading_component_widget.dart:110: borderRadius: BorderRadius.circular(12.0),
components/new_album/new_album_widget.dart:73: borderRadius: BorderRadius.circular(12.0),
components/album_list_loading_component/album_list_loading_component_widget.dart:513: borderRadius: BorderRadius.circular(12.0),
components/album_list_loading_component/album_list_loading_component_widget.dart:600: borderRadius: BorderRadius.circular(12.0),
components/album_list_loading_component/album_list_loading_component_widget.dart:687: borderRadius: BorderRadius.circular(12.0),
components/album_list_loading_component/album_list_loading_component_widget.dart:774: borderRadius: BorderRadius.circular(12.0),
components/album_list_loading_component/album_list_loading_component_widget.dart:861: borderRadius: BorderRadius.circular(12.0),
components/album_list_loading_component/album_list_loading_component_widget.dart:948: borderRadius: BorderRadius.circular(12.0),
components/album_list_loading_component/album_list_loading_component_widget.dart:1035: borderRadius: BorderRadius.circular(12.0),
components/album_list_loading_component/album_list_loading_component_widget.dart:1122: borderRadius: BorderRadius.circular(12.0),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:36: borderRadius: BorderRadius.circular(12),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:199: borderRadius: BorderRadius.circular(12),
components/delete_confirmation/delete_confirmation_widget.dart:69: borderRadius: BorderRadius.circular(12.0),
components/leave_review/leave_review_widget.dart:107: borderRadius: BorderRadius.circular(12.0),
components/paywall_confirmation/paywall_confirmation_widget.dart:181: borderRadius: BorderRadius.circular(12.0),
```

### 4c. circular(14) — off-token

**Occurrences:** 28 · **Why replace:** No token; snap to 12 or 16.

```
itemcard2/itemcard2_widget.dart:1712: borderRadius: BorderRadius.circular(14.0),
search/search_widget.dart:567: shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
home/takeor_upload_page/takeor_upload_page_widget.dart:168: borderRadius: BorderRadius.circular(14.0),
custom_code/widgets/share_card_widget.dart:738: borderRadius: BorderRadius.circular(14),
limits/limit_out/limit_out_widget.dart:138: borderRadius: BorderRadius.circular(14.0),
limits/limit_out/limit_out_widget.dart:164: borderRadius: BorderRadius.circular(14.0),
topratings/toprated/toprated_widget.dart:310: shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
item_card/deleteitem/deleteitem_widget.dart:137: borderRadius: BorderRadius.circular(14.0),
item_card/deleteitem/deleteitem_widget.dart:161: borderRadius: BorderRadius.circular(14.0),
pages/compatibility_result/compatibility_result_widget.dart:579: borderRadius: BorderRadius.circular(14),
pages/compatibility_result/compatibility_result_widget.dart:727: borderRadius: BorderRadius.circular(14),
pages/compatibility_result/compatibility_result_widget.dart:732: borderRadius: BorderRadius.circular(14),
pages/routine_calendar/routine_calendar_widget.dart:363: borderRadius: BorderRadius.circular(14),
pages/routine_calendar/routine_calendar_widget.dart:548: borderRadius: BorderRadius.circular(14),
pages/onboarding_profile/onboarding_profile_widget.dart:225: borderRadius: BorderRadius.circular(14),
pages/onboarding_profile/onboarding_profile_widget.dart:229: borderRadius: BorderRadius.circular(14),
pages/onboarding_profile/onboarding_profile_widget.dart:233: borderRadius: BorderRadius.circular(14),
pages/onboarding_profile/onboarding_profile_widget.dart:237: borderRadius: BorderRadius.circular(14),
pages/onboarding_profile/onboarding_profile_widget.dart:539: borderRadius: BorderRadius.circular(14),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:225: borderRadius: BorderRadius.circular(14),
components/error_popup/error_popup_widget.dart:161: borderRadius: BorderRadius.circular(14.0),
components/error_popup/error_popup_widget.dart:292: borderRadius: BorderRadius.circular(14.0),
components/error_popup/error_popup_widget.dart:379: borderRadius: BorderRadius.circular(14.0),
components/error_popup/error_popup_widget.dart:404: borderRadius: BorderRadius.circular(14.0),
components/error_popup/error_popup_widget.dart:503: borderRadius: BorderRadius.circular(14.0),
components/error_popup/error_popup_widget.dart:527: borderRadius: BorderRadius.circular(14.0),
components/ingredient_bubbles/ingredient_bubbles_widget.dart:355: borderRadius: BorderRadius.circular(14),
components/link_telegram_sheet/link_telegram_sheet_widget.dart:216: borderRadius: BorderRadius.circular(14),
```

### 4d. circular(50)/240/280 — ad-hoc pills

**Occurrences:** 28 · **Why replace:** Ad-hoc pill radii; use radius.full.

```
boards/edit_album/edit_album_widget.dart:294: borderRadius: BorderRadius.circular(50.0),
boards/edit_album/edit_album_widget.dart:323: borderRadius: BorderRadius.circular(50.0),
pages/forgot_password/forgot_password_widget.dart:300: borderRadius: BorderRadius.circular(50.0),
pages/edit_profile/edit_profile_widget.dart:372: BorderRadius.circular(280.0),
pages/edit_profile/edit_profile_widget.dart:1124: borderRadius: BorderRadius.circular(50.0),
pages/onboarding_profile/onboarding_profile_widget.dart:685: borderRadius: BorderRadius.circular(50),
pages/log_in_page/log_in_page_widget.dart:323: borderRadius: BorderRadius.circular(50.0),
pages/log_in_page/log_in_page_widget.dart:435: borderRadius: BorderRadius.circular(50.0),
pages/log_in_page/log_in_page_widget.dart:623: borderRadius: BorderRadius.circular(50.0),
pages/create_account_page/create_account_page_widget.dart:669: borderRadius: BorderRadius.circular(50.0),
pages/create_account_page/create_account_page_widget.dart:745: BorderRadius.circular(50.0),
pages/onboarding_quiz/onboarding_quiz_widget.dart:1118: borderRadius: BorderRadius.circular(50),
pages/onboarding_quiz/onboarding_quiz_widget.dart:1134: borderRadius: BorderRadius.circular(50),
pages/profile/profile_widget.dart:157: borderRadius: BorderRadius.circular(240.0),
pages/profile/profile_widget.dart:1090: borderRadius: BorderRadius.circular(50.0),
pages/profile/profile_widget.dart:1203: borderRadius: BorderRadius.circular(50.0),
paywall/paywallpage/paywallpage_widget.dart:515: BorderRadius.circular(50.0),
paywall/paywallpage/paywallpage_widget.dart:971: BorderRadius.circular(50.0),
components/out_of_generations/out_of_generations_widget.dart:186: borderRadius: BorderRadius.circular(50.0),
components/feedback_collector/feedback_collector_widget.dart:156: borderRadius: BorderRadius.circular(50),
components/feedback_collector/feedback_collector_widget.dart:179: borderRadius: BorderRadius.circular(50),
components/feedback_collector/negative_feedback_widget.dart:258: borderRadius: BorderRadius.circular(50.0),
components/new_album/new_album_widget.dart:236: borderRadius: BorderRadius.circular(50.0),
components/new_album/new_album_widget.dart:268: borderRadius: BorderRadius.circular(50.0),
components/delete_confirmation/delete_confirmation_widget.dart:180: borderRadius: BorderRadius.circular(50.0),
components/delete_confirmation/delete_confirmation_widget.dart:215: borderRadius: BorderRadius.circular(50.0),
components/leave_review/leave_review_widget.dart:285: borderRadius: BorderRadius.circular(50.0),
components/paywall_confirmation/paywall_confirmation_widget.dart:456: borderRadius: BorderRadius.circular(50.0),
```

---
## 5. Spacing inconsistencies

### 5a. EdgeInsets numeric-arg distinct inventory (count · value). FFSpacing = 4/8/16/24/32 (skips 12 & 20)
```
  23 0
 264 0.0
   8 2
   4 2.0
   8 3
  17 4
   7 4.0
   4 5
  11 6
  11 6.0
   1 7
  35 8
  61 8.0
   2 9
  14 10
   3 10.0
  23 12
  33 12.0
  22 14
   6 14.0
   2 15.0
  77 16
  80 16.0
   5 18
  25 20
   9 20.0
   1 22
  18 24
  84 24.0
   3 26.0
   3 28
   7 28.0
   5 32
  13 32.0
   4 40
   2 40.0
   1 48.0
   2 60
   2 60.0
   3 64.0
   1 100
   2 100.0
   1 130
```

### 5b. SizedBox gap 10 — off-grid, heavily used

**Occurrences:** 43 · **Why replace:** 10px off the 4/8/12/16 grid; snap to 8 or 12.

```
itemcard2/itemcard2_widget.dart:259: const SizedBox(height: 10),
itemcard2/itemcard2_widget.dart:830: ].divide(SizedBox(height: 10.0)),
itemcard2/itemcard2_widget.dart:905: SizedBox(width: 10.0)),
itemcard2/itemcard2_widget.dart:1517: const SizedBox(width: 10),
itemcard2/itemcard2_widget.dart:1641: const SizedBox(height: 10),
itemcard2/itemcard2_widget.dart:1672: const SizedBox(height: 10),
itemcard2/itemcard2_widget.dart:1728: const SizedBox(width: 10),
flutter_flow/upload_data.dart:133: const SizedBox(height: 10),
components/profile_summary_card.dart:182: const SizedBox(height: 10),
components/share_card_sheet_widget.dart:216: ].divide(SizedBox(width: 10.0)),
home/home/home_widget.dart:897: const SizedBox(height: 10),
home/takeor_upload_page/takeor_upload_page_widget.dart:1739: const SizedBox(width: 10),
topratings/toprated/toprated_widget.dart:229: const SizedBox(height: 10),
topratings/toprated/toprated_widget.dart:268: const SizedBox(height: 10),
boards/edit_album/edit_album_widget.dart:256: const SizedBox(height: 10.0),
boards/edit_album/edit_album_widget.dart:326: ].divide(const SizedBox(height: 10.0)),
item_card/deleteitem/deleteitem_widget.dart:149: const SizedBox(height: 10.0),
pages/compatibility_result/compatibility_result_widget.dart:638: const SizedBox(width: 10),
pages/compatibility_result/compatibility_result_widget.dart:739: const SizedBox(width: 10),
pages/routine_calendar/routine_calendar_widget.dart:527: const SizedBox(height: 10),
pages/routine_calendar/routine_calendar_widget.dart:574: const SizedBox(width: 10),
pages/routine_calendar/routine_calendar_widget.dart:940: const SizedBox(height: 10),
pages/routine_calendar/routine_calendar_widget.dart:1065: separatorBuilder: (_, __) => const SizedBox(width: 10),
pages/cosmetic_bag_intro/cosmetic_bag_intro_widget.dart:215: const SizedBox(height: 10),
pages/onboarding_profile/onboarding_profile_widget.dart:389: const SizedBox(height: 10),
pages/onboarding_profile/onboarding_profile_widget.dart:402: const SizedBox(width: 10),
pages/onboarding_profile/onboarding_profile_widget.dart:425: const SizedBox(height: 10),
pages/onboarding_profile/onboarding_profile_widget.dart:468: const SizedBox(height: 10),
pages/onboarding_profile/onboarding_profile_widget.dart:537: const SizedBox(height: 10),
pages/onboarding_quiz/onboarding_quiz_widget.dart:328: const SizedBox(height: 10),
pages/onboarding_quiz/onboarding_quiz_widget.dart:719: const SizedBox(width: 10),
pages/onboarding_quiz/onboarding_quiz_widget.dart:866: const SizedBox(height: 10),
components/analysis_loading/analysis_loading_widget.dart:226: const SizedBox(width: 10),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:145: const SizedBox(height: 10),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:169: const SizedBox(width: 10),
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:200: const SizedBox(height: 10),
components/navbar/navbar_widget.dart:147: .addToStart(const SizedBox(height: 10.0))
components/navbar/navbar_widget.dart:148: .addToEnd(const SizedBox(height: 10.0)),
components/product_card_v2/product_card_v2_widget.dart:338: const SizedBox(width: 10),
components/product_card_v2/product_card_v2_widget.dart:415: const SizedBox(width: 10),
components/product_card_v2/product_card_v2_widget.dart:507: const SizedBox(width: 10),
components/product_card_v2/product_card_v2_widget.dart:810: const SizedBox(width: 10),
components/feedback_collector/feedback_collector_widget.dart:213: const SizedBox(height: 10),
```

### 5c. SizedBox gap 6 — off-grid

**Occurrences:** 21 · **Why replace:** 6px off-grid; snap to 8.

```
itemcard2/itemcard2_widget.dart:1107: const SizedBox(height: 6),
itemcard2/itemcard2_widget.dart:1120: const SizedBox(height: 6),
search/search_widget.dart:485: const SizedBox(width: 6),
home/home/home_widget.dart:1156: const SizedBox(width: 6),
home/startanalys/startanalys_widget.dart:215: SizedBox(width: 6.0),
home/startanalys/startanalys_widget.dart:258: SizedBox(height: 6.0),
custom_code/widgets/share_card_widget.dart:452: const SizedBox(height: 6),
topratings/toprated/toprated_widget.dart:498: const SizedBox(height: 6),
boards/boards/boards_widget.dart:309: const SizedBox(height: 6),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:364: const SizedBox(width: 6),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:257: const SizedBox(width: 6),
pages/routine_calendar/routine_calendar_widget.dart:479: const SizedBox(width: 6),
pages/routine_calendar/routine_calendar_widget.dart:513: const SizedBox(width: 6),
pages/routine_calendar/routine_calendar_widget.dart:1023: const SizedBox(width: 6),
pages/edit_profile/edit_profile_widget.dart:756: ].divide(SizedBox(height: 6.0)),
pages/log_in_page/login_feature_cards.dart:251: const SizedBox(height: 6),
pages/log_in_page/login_feature_cards.dart:368: const SizedBox(width: 6),
paywall/upgrade/upgrade_widget.dart:92: ].divide(SizedBox(width: 6.0)),
components/product_card_v2/product_card_v2_widget.dart:239: const SizedBox(height: 6),
components/light_dark_toggle/light_dark_toggle_widget.dart:64: ].divide(SizedBox(width: 6.0)),
components/paywall_confirmation/paywall_confirmation_widget.dart:227: ].divide(SizedBox(width: 6.0)),
```

---
## 6. Button-height inconsistencies

### 6a. Button-plausible height: values (35–56) — 7 distinct heights across 56 FFButtonWidget
```
itemcard2/itemcard2_widget.dart:325: height: 50.0,
itemcard2/itemcard2_widget.dart:1445: height: 44,
flutter_flow/flutter_flow_language_selector.dart:202: height: 44.0,
flutter_flow/flutter_flow_drop_down.dart:335: height: 50,
search/search_widget.dart:386: width: 44, height: 44,
search/search_widget.dart:561: height: 52,
shareproduct/shareproduct_widget.dart:87: height: 50.0,
components/profile_summary_card.dart:81: height: 44,
components/share_card_sheet_widget.dart:60: height: 50.0,
settings/countries/countries_widget.dart:59: height: 50.0,
settings/countries/countries_widget.dart:160: height: 50.0,
home/home/home_widget.dart:421: height: 50.0,
home/home/home_widget.dart:506: height: 35.0,
home/home/home_widget.dart:816: height: 50.0,
home/home/home_widget.dart:928: height: 50,
home/takeor_upload_page/takeor_upload_page_widget.dart:123: height: 56.0,
home/takeor_upload_page/takeor_upload_page_widget.dart:160: height: 50.0,
home/startanalys/startanalys_widget.dart:158: height: 54.0,
limits/limit_out/limit_out_widget.dart:124: height: 52.0,
limits/limit_out/limit_out_widget.dart:150: height: 52.0,
topratings/makepubluc/makepubluc_widget.dart:123: height: 44.0,
topratings/toprated/toprated_widget.dart:302: width: double.infinity, height: 52,
topratings/toprated/toprated_widget.dart:516: width: 44, height: 44,
boards/albumslist/albumslist_widget.dart:131: height: 52.0,
boards/albumslist/albumslist_widget.dart:197: height: 55.0,
boards/edit_album/edit_album_widget.dart:278: height: 55.0,
boards/edit_album/edit_album_widget.dart:307: height: 55.0,
boards/newboardempty/newboardempty_widget.dart:141: height: 52.0,
boards/imagesby_album/imagesby_album_widget.dart:87: height: 50.0,
boards/imagesby_album/imagesby_album_widget.dart:222: height: 50.0,
boards/boards/boards_widget.dart:80: height: 50.0,
boards/boards/boards_widget.dart:163: height: 40.0,
item_card/markasspam/markasspam_widget.dart:128: height: 44.0,
item_card/markasspam/markasspam_widget.dart:170: height: 44.0,
item_card/deleteitem/deleteitem_widget.dart:72: height: 52.0,
item_card/deleteitem/deleteitem_widget.dart:119: height: 50.0,
item_card/deleteitem/deleteitem_widget.dart:154: height: 44.0,
pages/compatibility_result/compatibility_result_widget.dart:271: height: 50,
pages/routine_calendar/routine_calendar_widget.dart:404: height: 40,
pages/routine_calendar/routine_calendar_widget.dart:580: width: 44, height: 44, fit: BoxFit.cover)
pages/routine_calendar/routine_calendar_widget.dart:583: height: 44,
pages/routine_calendar/routine_calendar_widget.dart:735: width: 44, height: 44, fit: BoxFit.cover)
pages/routine_calendar/routine_calendar_widget.dart:738: height: 44,
pages/routine_calendar/routine_calendar_widget.dart:857: height: 52,
pages/routine_calendar/routine_calendar_widget.dart:949: height: 52,
pages/routine_calendar/routine_calendar_widget.dart:1164: height: 52,
pages/forgot_password/forgot_password_widget.dart:278: height: 55.0,
pages/edit_profile/edit_profile_widget.dart:108: height: 50.0,
pages/edit_profile/edit_profile_widget.dart:468: height: 40.0,
pages/edit_profile/edit_profile_widget.dart:507: height: 40.0,
pages/edit_profile/edit_profile_widget.dart:546: height: 40.0,
pages/edit_profile/edit_profile_widget.dart:585: height: 40.0,
pages/edit_profile/edit_profile_widget.dart:624: height: 40.0,
pages/edit_profile/edit_profile_widget.dart:663: height: 40.0,
pages/edit_profile/edit_profile_widget.dart:702: height: 40.0,
pages/edit_profile/edit_profile_widget.dart:741: height: 40.0,
pages/edit_profile/edit_profile_widget.dart:1102: height: 55.0,
pages/cosmetic_bag_intro/cosmetic_bag_intro_widget.dart:264: height: 56,
pages/onboarding_profile/onboarding_profile_widget.dart:321: height: 44,
pages/onboarding_profile/onboarding_profile_widget.dart:542: height: 50,
pages/onboarding_profile/onboarding_profile_widget.dart:674: height: 55,
pages/newblank/newblank_widget.dart:239: height: 56,
pages/log_in_page/log_in_page_widget.dart:309: height: 55.0,
pages/log_in_page/log_in_page_widget.dart:418: height: 55.0,
pages/log_in_page/log_in_page_widget.dart:604: height: 55.0,
pages/log_in_page/log_in_page_widget.dart:678: height: 44.0,
pages/create_account_page/create_account_page_widget.dart:643: height: 55.0,
pages/create_account_page/create_account_page_widget.dart:712: height: 55.0,
pages/onboarding_quiz/onboarding_quiz_widget.dart:339: options: _primaryBtn(theme, height: 52),
pages/profile/profile_widget.dart:88: height: 50.0,
pages/profile/profile_widget.dart:230: height: 55.0,
pages/profile/profile_widget.dart:309: height: 55.0,
pages/profile/profile_widget.dart:391: height: 55.0,
pages/profile/profile_widget.dart:471: height: 55.0,
pages/profile/profile_widget.dart:568: height: 55.0,
pages/profile/profile_widget.dart:645: height: 55.0,
pages/profile/profile_widget.dart:722: height: 55.0,
pages/profile/profile_widget.dart:833: height: 55.0,
pages/profile/profile_widget.dart:883: height: 55.0,
pages/profile/profile_widget.dart:929: height: 55.0,
pages/profile/profile_widget.dart:979: height: 55.0,
pages/profile/profile_widget.dart:1023: height: 55.0,
pages/profile/profile_widget.dart:1070: height: 35.0,
pages/profile/profile_widget.dart:1120: height: 55.0,
pages/profile/profile_widget.dart:1179: height: 35.0,
pages/cosmetic_bag/cosmetic_bag_widget.dart:309: height: 56,
pages/cosmetic_bag/bag_add_helpers.dart:138: width: 44, height: 44, fit: BoxFit.cover)
pages/cosmetic_bag/bag_add_helpers.dart:141: height: 44,
paywall/paywallpage/paywallpage_widget.dart:483: height: 55.0,
paywall/paywallpage/paywallpage_widget.dart:937: height: 55.0,
paywall/upgrade/upgrade_widget.dart:56: height: 55.0,
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:147: height: 52,
components/guest_prefs_sheet/guest_prefs_sheet_widget.dart:218: height: 52,
components/navbar/navbar_widget.dart:232: const Expanded(child: SizedBox(height: 40.0)),
components/out_of_generations/out_of_generations_widget.dart:167: height: 55.0,
components/error_popup/error_popup_widget.dart:120: height: 56.0,
components/error_popup/error_popup_widget.dart:153: height: 50.0,
components/error_popup/error_popup_widget.dart:243: height: 56.0,
components/error_popup/error_popup_widget.dart:280: height: 50.0,
components/error_popup/error_popup_widget.dart:365: height: 50.0,
components/error_popup/error_popup_widget.dart:394: height: 50.0,
components/error_popup/error_popup_widget.dart:456: height: 56.0,
components/error_popup/error_popup_widget.dart:493: height: 50.0,
components/error_popup/error_popup_widget.dart:518: height: 50.0,
components/feedback_collector/feedback_collector_widget.dart:189: height: 54,
components/feedback_collector/negative_feedback_widget.dart:245: height: 55.0,
components/countryselector/countryselector_widget.dart:99: height: 50.0,
components/countryselector/countryselector_widget.dart:120: height: 50.0,
components/countryselector/countryselector_widget.dart:160: height: 50.0,
components/new_album/new_album_widget.dart:217: height: 55.0,
components/new_album/new_album_widget.dart:249: height: 55.0,
components/link_telegram_sheet/link_telegram_sheet_widget.dart:209: height: 52,
components/premium_features_list/premium_features_list_widget.dart:53: height: 40.0,
components/premium_features_list/premium_features_list_widget.dart:95: height: 40.0,
components/premium_features_list/premium_features_list_widget.dart:138: height: 40.0,
components/premium_features_list/premium_features_list_widget.dart:181: height: 40.0,
components/premium_features_list/premium_features_list_widget.dart:224: height: 40.0,
components/premium_features_list/premium_features_list_widget.dart:265: height: 40.0,
components/premium_features_list/premium_features_list_widget.dart:306: height: 40.0,
components/premium_features_list/premium_features_list_widget.dart:347: height: 40.0,
components/delete_confirmation/delete_confirmation_widget.dart:161: height: 55.0,
components/delete_confirmation/delete_confirmation_widget.dart:196: height: 55.0,
components/leave_review/leave_review_widget.dart:263: height: 55.0,
components/paywall_confirmation/paywall_confirmation_widget.dart:189: height: 40.0,
components/paywall_confirmation/paywall_confirmation_widget.dart:260: height: 40.0,
components/paywall_confirmation/paywall_confirmation_widget.dart:303: height: 40.0,
components/paywall_confirmation/paywall_confirmation_widget.dart:346: height: 40.0,
components/paywall_confirmation/paywall_confirmation_widget.dart:389: height: 40.0,
components/paywall_confirmation/paywall_confirmation_widget.dart:437: height: 55.0,
topratings/copyitem/copyitem_widget.dart:127: height: 44.0,
topratings/copyitem/copyitem_widget.dart:197: height: 44.0,
topratings/hidenavailability/hidenavailability_widget.dart:132: height: 44.0,
topratings/makepublic/makepublic_widget.dart:97: height: 44.0,
topratings/makeprivate/makeprivate_widget.dart:123: height: 44.0,
```
→ 35/40/44/50/52/54/55 all used for buttons — consolidate to 3 sizes (36/44/52).

---
## 7. Opacity inconsistencies

### 7a. withOpacity distinct inventory (count · value) — ~25 distinct 0.06–0.92
```
  11 .withOpacity(0.12)
   8 .withOpacity(0.35)
   7 .withOpacity(0.15)
   6 .withOpacity(0.92)
   6 .withOpacity(0.5)
   4 .withOpacity(0.7)
   4 .withOpacity(0.25)
   4 .withOpacity(0.08)
   3 .withOpacity(0.4)
   3 .withOpacity(0.3)
   2 .withOpacity(0.85)
   2 .withOpacity(0.55)
   2 .withOpacity(0.45)
   2 .withOpacity(0.10)
   2 .withOpacity(0.1)
   2 .withOpacity(0.06)
   1 .withOpacity(0.9)
   1 .withOpacity(0.80)
   1 .withOpacity(0.8)
   1 .withOpacity(0.75)
   1 .withOpacity(0.6)
   1 .withOpacity(0.2)
   1 .withOpacity(0.18)
   1 .withOpacity(0.14)
   1 .withOpacity(0.11)
   1 .withOpacity(0.09)
   1 .withOpacity(0.07)
   1 .withOpacity(0.05)
   1 .withOpacity(0.0)
   1 .withOpacity(0)
```
### 7b. withOpacity raw locations
```
itemcard2/itemcard2_widget.dart:1244: .withOpacity(0.1),
itemcard2/itemcard2_widget.dart:1494: color: FlutterFlowTheme.of(context).primary.withOpacity(0.25),
itemcard2/itemcard2_widget.dart:1499: color: Colors.black.withOpacity(0.10),
itemcard2/itemcard2_widget.dart:1715: ? const Color(0xFFFF7043).withOpacity(0.35)
itemcard2/itemcard2_widget.dart:1716: : FlutterFlowTheme.of(context).primary.withOpacity(0.25),
search/search_widget.dart:354: color: theme.secondaryText.withOpacity(0.5),
search/search_widget.dart:566: disabledBackgroundColor: theme.primary.withOpacity(0.5),
search/search_widget.dart:683: Icon(Icons.search_off_rounded, size: 48, color: theme.secondaryText.withOpacity(0.4)),
shareproduct/shareproduct_widget.dart:140: color: Colors.black.withOpacity(0.12),
components/profile_summary_card.dart:83: color: theme.primary.withOpacity(0.15),
home/home/home_widget.dart:458: .withOpacity(0.55),
home/home/home_widget.dart:871: .withOpacity(0.35),
home/takeor_upload_page/takeor_upload_page_widget.dart:1655: colors: [primary.withOpacity(0.08), Colors.transparent],
home/takeor_upload_page/takeor_upload_page_widget.dart:1680: color: primary.withOpacity(0.35),
home/takeor_upload_page/takeor_upload_page_widget.dart:1701: color: primary.withOpacity(0.7),
home/takeor_upload_page/takeor_upload_page_widget.dart:1704: color: primary.withOpacity(0.5),
custom_code/widgets/share_card_widget.dart:210: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
custom_code/widgets/share_card_widget.dart:270: Container(height: 4, color: color.withOpacity(0.12)),
custom_code/widgets/share_card_widget.dart:394: color: Colors.black.withOpacity(0.4),
custom_code/widgets/share_card_widget.dart:420: color: sColor.withOpacity(0.12),
custom_code/widgets/share_card_widget.dart:466: color: primary.withOpacity(0.5),
custom_code/widgets/share_card_widget.dart:533: color: _primary.withOpacity(0.85),
custom_code/widgets/share_card_widget.dart:636: color: _primary.withOpacity(0.85),
custom_code/widgets/share_card_widget.dart:737: color: _primary.withOpacity(0.06),
custom_code/widgets/share_card_widget.dart:739: border: Border.all(color: _primary.withOpacity(0.15)),
custom_code/widgets/share_card_widget.dart:784: size: 14, color: _primary.withOpacity(0.7)),
custom_code/widgets/share_card_widget.dart:791: color: _primary.withOpacity(0.7),
custom_code/widgets/share_card_widget.dart:809: color: _primary.withOpacity(0.1),
custom_code/widgets/share_card_widget.dart:811: border: Border.all(color: _primary.withOpacity(0.25)),
custom_code/widgets/animated_paywall_bg.dart:101: color: const Color(0xFF5C85D9).withOpacity(0.18),
custom_code/widgets/animated_paywall_bg.dart:112: color: const Color(0xFF9489F5).withOpacity(0.15),
custom_code/widgets/animated_paywall_bg.dart:123: color: const Color(0xFF39D2C0).withOpacity(0.12),
topratings/toprated/toprated_widget.dart:186: color: theme.secondaryText.withOpacity(0.3),
topratings/toprated/toprated_widget.dart:519: ? FlutterFlowTheme.of(context).primary.withOpacity(0.12)
boards/newboardempty/newboardempty_widget.dart:63: color: primary.withOpacity(0.06),
boards/newboardempty/newboardempty_widget.dart:71: color: primary.withOpacity(0.11),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:91: color: _scoreColor(widget.score ?? 0).withOpacity(0.07),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:171: color: const Color(0xFF1565C0).withOpacity(0.9),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:206: color: Colors.white.withOpacity(0.92),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:349: color: Colors.white.withOpacity(0.92),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:380: color: Colors.white.withOpacity(0.92),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:390: color: sColor.withOpacity(0.35),
item_card/imagedetailed_main/imagedetailed_main_widget.dart:403: backgroundColor: sColor.withOpacity(0.15),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:130: color: Colors.white.withOpacity(0.92),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:242: color: Colors.white.withOpacity(0.92),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:272: color: Colors.white.withOpacity(0.92),
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:290: backgroundColor: _color.withOpacity(0.15),
pages/onboarding_profile/onboarding_profile_widget.dart:183: color: Colors.black.withOpacity(0.05),
pages/newblank/newblank_widget.dart:253: FlutterFlowTheme.of(context).primary.withOpacity(0.6),
pages/newblank/newblank_widget.dart:451: color: primary.withOpacity(0.08),
pages/newblank/newblank_widget.dart:469: color: primary.withOpacity(0.14),
pages/newblank/newblank_widget.dart:511: color: primary.withOpacity(0.2),
pages/log_in_page/login_feature_cards.dart:15: border: Border.all(color: primary.withOpacity(0.15)),
pages/log_in_page/login_feature_cards.dart:18: color: primary.withOpacity(0.12),
pages/log_in_page/login_feature_cards.dart:91: backgroundColor: _scoreColor.withOpacity(0.12),
pages/log_in_page/login_feature_cards.dart:217: color: primary.withOpacity(0.35),
pages/log_in_page/login_feature_cards.dart:236: color: primary.withOpacity(0.7),
pages/log_in_page/login_feature_cards.dart:239: color: primary.withOpacity(0.5),
pages/log_in_page/login_feature_cards.dart:351: color: pill.color.withOpacity(0.12),
pages/log_in_page/login_feature_cards.dart:354: color: pill.color.withOpacity(0.4),
pages/create_account_page/create_account_page_widget.dart:773: .withOpacity(0),
pages/profile/profile_widget.dart:1253: color: primary.withOpacity(0.08),
paywall/paywallpage/paywallpage_widget.dart:98: color: const Color(0xFF0C1A35).withOpacity(0.80),
paywall/paywallpage/paywallpage_widget.dart:101: color: Colors.white.withOpacity(0.09),
paywall/paywallpage/paywallpage_widget.dart:121: color: Colors.white.withOpacity(0.8),
paywall/paywallpage/paywallpage_widget.dart:216: : Colors.white.withOpacity(0.12),
paywall/paywallpage/paywallpage_widget.dart:523: color: Colors.white.withOpacity(0.3),
paywall/paywallpage/paywallpage_widget.dart:562: : Colors.white.withOpacity(0.12),
paywall/paywallpage/paywallpage_widget.dart:980: .withOpacity(0.3),
paywall/paywallpage/paywallpage_widget.dart:1002: color: Colors.white.withOpacity(0.45),
paywall/paywallpage/paywallpage_widget.dart:1098: color: Colors.white.withOpacity(0.35),
components/analysis_loading/analysis_loading_widget.dart:106: Colors.black.withOpacity(0.08),
components/analysis_loading/analysis_loading_widget.dart:107: Colors.black.withOpacity(0.0),
components/analysis_loading/analysis_loading_widget.dart:299: color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
components/product_card_v2/product_card_v2_widget.dart:192: color: Colors.black.withOpacity(0.10),
components/product_card_v2/product_card_v2_widget.dart:211: color: ringColor.withOpacity(0.35),
components/product_card_v2/product_card_v2_widget.dart:221: backgroundColor: ringColor.withOpacity(0.12),
components/ingredient_bubbles/ingredient_bubbles_widget.dart:252: b.color.withOpacity(0.75),
components/ingredient_bubbles/ingredient_bubbles_widget.dart:259: ..color = selected ? b.color : b.color.withOpacity(0.55)
components/ingredient_bubbles/ingredient_bubbles_widget.dart:266: ..color = Colors.white.withOpacity(0.45)
components/ingredient_bubbles/ingredient_bubbles_widget.dart:358: color: bubble.color.withOpacity(0.25),
components/ingredient_bubbles/ingredient_bubbles_widget.dart:363: border: Border.all(color: bubble.color.withOpacity(0.35)),
```

---
## 8. Shadow inconsistencies

### 8a. blurRadius distinct inventory (count · value). FFShadows blur = 3/6/15/25
```
   7 blurRadius: 12.0
   6 blurRadius: 6
   6 blurRadius: 24.0
   6 blurRadius: 16
   5 blurRadius: 8.0
   5 blurRadius: 8
   3 blurRadius: 20
   2 blurRadius: 16.0
   2 blurRadius: 12
   2 blurRadius: 10
   1 blurRadius: 4.0
   1 blurRadius: 4
   1 blurRadius: 32
   1 blurRadius: 3
   1 blurRadius: 24
```
### 8b. blurRadius raw locations
```
itemcard2/itemcard2_widget.dart:1034: blurRadius: 8.0,
itemcard2/itemcard2_widget.dart:1152: blurRadius: 8.0,
itemcard2/itemcard2_widget.dart:1330: blurRadius: 8.0,
itemcard2/itemcard2_widget.dart:1500: blurRadius: 12,
shareproduct/shareproduct_widget.dart:141: blurRadius: 16,
components/profile_summary_card.dart:17: blurRadius: 16,
home/takeor_upload_page/takeor_upload_page_widget.dart:110: blurRadius: 24.0,
home/takeor_upload_page/takeor_upload_page_widget.dart:1681: blurRadius: 20,
home/takeor_upload_page/takeor_upload_page_widget.dart:1705: blurRadius: 6,
limits/limit_out/limit_out_widget.dart:65: blurRadius: 12.0,
topratings/makepubluc/makepubluc_widget.dart:60: blurRadius: 12.0,
item_card/markasspam/markasspam_widget.dart:65: blurRadius: 12.0,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:85: blurRadius: 8.0,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:90: blurRadius: 16.0,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:175: blurRadius: 6,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:210: blurRadius: 6,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:353: blurRadius: 8,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:384: blurRadius: 8,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:389: blurRadius: 10,
item_card/deleteitem/deleteitem_widget.dart:58: blurRadius: 24.0,
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:73: blurRadius: 4.0,
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:134: blurRadius: 6,
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:246: blurRadius: 8,
item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart:276: blurRadius: 8,
pages/onboarding_profile/onboarding_profile_widget.dart:184: blurRadius: 16,
pages/newblank/newblank_widget.dart:513: blurRadius: 6,
pages/log_in_page/login_feature_cards.dart:19: blurRadius: 16,
pages/log_in_page/login_feature_cards.dart:24: blurRadius: 6,
pages/log_in_page/login_feature_cards.dart:80: blurRadius: 20,
pages/log_in_page/login_feature_cards.dart:218: blurRadius: 10,
pages/log_in_page/login_feature_cards.dart:240: blurRadius: 4,
components/navbar/navbar_widget.dart:195: blurRadius: 24.0,
components/navbar/navbar_widget.dart:268: blurRadius: 16.0,
components/product_card_v2/product_card_v2_widget.dart:186: blurRadius: 24,
components/product_card_v2/product_card_v2_widget.dart:191: blurRadius: 8,
components/product_card_v2/product_card_v2_widget.dart:212: blurRadius: 20,
components/error_popup/error_popup_widget.dart:107: blurRadius: 24.0,
components/error_popup/error_popup_widget.dart:230: blurRadius: 24.0,
components/error_popup/error_popup_widget.dart:443: blurRadius: 24.0,
components/feedback_collector/feedback_collector_widget.dart:42: blurRadius: 32,
components/feedback_collector/feedback_collector_widget.dart:109: blurRadius: 16,
components/feedback_collector/feedback_collector_widget.dart:183: blurRadius: 12,
components/ingredient_bubbles/ingredient_bubbles_widget.dart:295: shadows: const [Shadow(color: Color(0xCCFFFFFF), blurRadius: 3)],
components/ingredient_bubbles/ingredient_bubbles_widget.dart:359: blurRadius: 16,
components/score_breakdown/score_breakdown_widget.dart:445: blurRadius: 8.0,
topratings/copyitem/copyitem_widget.dart:64: blurRadius: 12.0,
topratings/hidenavailability/hidenavailability_widget.dart:67: blurRadius: 12.0,
topratings/makepublic/makepublic_widget.dart:50: blurRadius: 12.0,
topratings/makeprivate/makeprivate_widget.dart:60: blurRadius: 12.0,
```

---
## 9. Icon-size inconsistencies

### 9a. Icon size: distinct inventory (count · value). Recommend 16/20/24/28/32/48
```
   1 1.0
   1 1.5
   1 12
   1 13
   9 14
   2 14.0
   5 15.0
   8 16
   1 16.0
  10 18
   4 18.0
  15 20
  15 20.0
  10 22
   2 22.0
   2 24
  32 24.0
   1 26
   6 26.0
   1 28
   7 28.0
   3 30
   3 30.0
   1 32.0
   2 36
   2 40
   2 40.0
   9 48
   1 52
   1 56
   1 56.0
   1 64
   1 150
   1 200
   1 280
```

### 9b. Icon size 22 (off-set)

**Occurrences:** 12 · **Why replace:** Between 20 and 24 tokens; snap to 24.

```
itemcard2/itemcard2_widget.dart:1515: size: 22,
components/profile_summary_card.dart:86: child: Icon(Icons.auto_awesome, color: theme.primary, size: 22),
topratings/toprated/toprated_widget.dart:525: size: 22,
boards/albumslist/albumslist_widget.dart:170: size: 22.0,
pages/compatibility_result/compatibility_result_widget.dart:586: Icon(Icons.warning_amber_rounded, color: color, size: 22),
pages/routine_calendar/routine_calendar_widget.dart:821: color: theme.primary, size: 22),
pages/routine_calendar/routine_calendar_widget.dart:831: color: Color(0xFF9E9E9E), size: 22),
pages/routine_calendar/routine_calendar_widget.dart:1021: size: 22,
pages/routine_calendar/routine_calendar_widget.dart:1128: color: theme.primary, size: 22),
pages/routine_calendar/routine_calendar_widget.dart:1138: color: Color(0xFF9E9E9E), size: 22),
pages/onboarding_quiz/onboarding_quiz_widget.dart:447: icon: Icon(Icons.close, size: 22, color: _muted),
components/paywall_confirmation/paywall_confirmation_widget.dart:313: size: 22.0,
```

### 9c. Icon size 26 (off-set)

**Occurrences:** 7 · **Why replace:** Snap to 24 or 28.

```
item_card/imagedetailed_main/imagedetailed_main_widget.dart:284: size: 26.0,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:290: size: 26.0,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:296: size: 26.0,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:302: size: 26.0,
item_card/imagedetailed_main/imagedetailed_main_widget.dart:308: size: 26.0,
item_card/deleteitem/deleteitem_widget.dart:80: size: 26.0,
pages/cosmetic_bag_intro/cosmetic_bag_intro_widget.dart:373: size: 26,
```

---
## 10. Border-width inconsistencies

### 10a. BorderSide width distribution
```
   5 width: 1.0
   3 width: 1.5
```

### 10b. width: 1.5 (odd hairline)

**Occurrences:** 12 · **Why replace:** Between hairline(1) and thick(2); snap to 1 (or 2 for focus).

```
itemcard2/itemcard2_widget.dart:1654: width: 1.5),
components/home_pipeline_widget.dart:174: border: Border.all(color: primary, width: 1.5),
components/profile_summary_card.dart:13: Border.all(color: theme.primary.withValues(alpha: 0.4), width: 1.5),
home/takeor_upload_page/takeor_upload_page_widget.dart:1637: border: Border.all(color: primary, width: 1.5),
topratings/toprated/toprated_widget.dart:539: border: Border.all(color: FlutterFlowTheme.of(context).primaryBackground, width: 1.5),
boards/albumslist/albumslist_widget.dart:140: width: 1.5,
boards/edit_album/edit_album_widget.dart:206: width: 1.5,
pages/onboarding_profile/onboarding_profile_widget.dart:228: borderSide: BorderSide(color: theme.primary, width: 1.5),
pages/onboarding_profile/onboarding_profile_widget.dart:236: borderSide: BorderSide(color: theme.error, width: 1.5),
pages/onboarding_profile/onboarding_profile_widget.dart:512: width: 1.5,
pages/log_in_page/login_feature_cards.dart:191: border: Border.all(color: primary, width: 1.5),
pages/onboarding_quiz/onboarding_quiz_widget.dart:1135: borderSide: BorderSide(color: _border, width: 1.5),
```

---
## 11. Duplicated / typo'd components

### 11a. Two parallel item-card implementations
```
lib/item_card/deleteitem
lib/item_card/imagedetailed_main
lib/item_card/imagedetailed_top_raited
lib/item_card/ingridients
lib/item_card/markasspam
---
lib/itemcard2/itemcard2_model.dart
lib/itemcard2/itemcard2_widget.dart
```
→ Two implementations of the same card. Merge to one parameterised `ItemCard`.

### 11b. Visibility-toggle triplication incl. spelling typo
```
lib/topratings/copyitem
lib/topratings/emptytopfindings
lib/topratings/hidenavailability
lib/topratings/makeprivate
lib/topratings/makepublic
lib/topratings/makepubluc
lib/topratings/toprated
lib/topratings/topratedproductspage
```
→ `makepublic`, **`makepubluc`** (misspelling of 'public'), `makeprivate`, `hidenavailability` are one control. Merge to `VisibilityToggle`.

### 11c. Empty-state duplication
```
lib/components/blank_album
lib/components/empty_gallery
lib/components/empty_gallery_with_animation
lib/components/no_images
```
→ Four empty-state variants — collapse to one `EmptyState`.

### 11d. Loading-skeleton duplication
```
lib/components/album_list_loading_component
lib/components/analysis_loading
lib/components/gallery_image_loading_component
lib/components/gallery_loading_component
lib/components/loading_recent
lib/components/loading_styles
```
→ Five loading components — consolidate to one `SkeletonLoader`.

---
## 12. Dead dark-mode affordance

### 12a. Only LightModeTheme is ever returned
```
lib/flutter_flow/flutter_flow_theme.dart:17:    return LightModeTheme();
lib/flutter_flow/flutter_flow_theme.dart:139:class LightModeTheme extends FlutterFlowTheme {
```
→ `FlutterFlowTheme.of()` unconditionally returns `LightModeTheme`; there is no `DarkModeTheme` class.

### 12b. …yet a light/dark toggle + ThemeMode plumbing ship
```
lib/components/light_dark_toggle/light_dark_toggle_model.dart
lib/components/light_dark_toggle/light_dark_toggle_widget.dart
lib/main.dart:122:  ThemeMode _themeMode = ThemeMode.system;
lib/main.dart:215:  void setThemeMode(ThemeMode mode) => safeSetState(() {
lib/main.dart:216:        _themeMode = mode;
lib/main.dart:254:      themeMode: _themeMode,
lib/flutter_flow/flutter_flow_util.dart:290:void setDarkModeSetting(BuildContext context, ThemeMode themeMode) =>
```
→ `MaterialApp.themeMode` is driven by `_themeMode` and `setDarkModeSetting` can change it, but since all colours come from `FlutterFlowTheme.of()`→`LightModeTheme` (which ignores ThemeMode), the toggle changes nothing. Dead toggle + dead plumbing.

---
## 13. Low-contrast secondary text (accessibility)

### 13a. secondaryText token definition
```
lib/flutter_flow/flutter_flow_theme.dart:152:  late Color secondaryText = const Color(0xFF929292);
```
→ `secondaryText = #929292`. On `primaryBackground #EBF0FC` contrast ≈ **2.8:1** (< WCAG AA 4.5:1 for body). Darken to `#6B6B6B` (≈ 4.7:1) for small text.

### 13b. secondaryText applied as text/icon colour — 73 usages (sample, first 40)
```
lib/itemcard2/itemcard2_widget.dart:277: color: FlutterFlowTheme.of(context).secondaryText,
lib/itemcard2/itemcard2_widget.dart:1189: .secondaryText,
lib/itemcard2/itemcard2_widget.dart:1225: .secondaryText,
lib/itemcard2/itemcard2_widget.dart:1752: color: FlutterFlowTheme.of(context).secondaryText,
lib/itemcard2/itemcard2_widget.dart:2066: color: iconColor ?? FlutterFlowTheme.of(context).secondaryText),
lib/search/search_widget.dart:336: color: theme.secondaryText,
lib/search/search_widget.dart:354: color: theme.secondaryText.withOpacity(0.5),
lib/search/search_widget.dart:365: prefixIcon: Icon(Icons.search_rounded, color: theme.secondaryText, size: 20),
lib/search/search_widget.dart:368: icon: Icon(Icons.clear_rounded, color: theme.secondaryText, size: 18),
lib/search/search_widget.dart:437: color: theme.secondaryText,
lib/search/search_widget.dart:479: color: theme.secondaryText,
lib/search/search_widget.dart:613: color: theme.secondaryText,
lib/search/search_widget.dart:683: Icon(Icons.search_off_rounded, size: 48, color: theme.secondaryText.withOpacity(0.4)),
lib/search/search_widget.dart:716: color: theme.secondaryText,
lib/home/home/home_widget.dart:911: .secondaryText,
lib/home/home/home_widget.dart:985: .secondaryText,
lib/home/takeor_upload_page/takeor_upload_page_widget.dart:152: color: theme.secondaryText,
lib/topratings/makepubluc/makepubluc_widget.dart:102: color: FlutterFlowTheme.of(context).secondaryText,
lib/topratings/toprated/toprated_widget.dart:186: color: theme.secondaryText.withOpacity(0.3),
lib/topratings/toprated/toprated_widget.dart:571: color: FlutterFlowTheme.of(context).secondaryText,
lib/topratings/toprated/toprated_widget.dart:631: .secondaryText,
lib/boards/albumslist/albumslist_widget.dart:169: : FlutterFlowTheme.of(context).secondaryText,
lib/boards/edit_album/edit_album_widget.dart:65: color: FlutterFlowTheme.of(context).secondaryText,
lib/boards/edit_album/edit_album_widget.dart:77: color: FlutterFlowTheme.of(context).secondaryText),
lib/boards/newboardempty/newboardempty_widget.dart:107: color: FlutterFlowTheme.of(context).secondaryText,
lib/boards/imagesby_album/imagesby_album_widget.dart:242: FlutterFlowTheme.of(context).secondaryText,
lib/boards/imagesby_album/imagesby_album_widget.dart:255: .secondaryText,
lib/item_card/deleteitem/deleteitem_widget.dart:108: color: FlutterFlowTheme.of(context).secondaryText,
lib/item_card/deleteitem/deleteitem_widget.dart:159: FlutterFlowTheme.of(context).secondaryText,
lib/item_card/ingridients/ingridients_widget.dart:109: color: FlutterFlowTheme.of(context).secondaryText,
lib/pages/forgot_password/forgot_password_widget.dart:142: color: FlutterFlowTheme.of(context).secondaryText,
lib/pages/onboarding_profile/onboarding_profile_widget.dart:284: color: theme.secondaryText, size: 36),
lib/pages/onboarding_profile/onboarding_profile_widget.dart:545: dropdownIconColor: theme.secondaryText,
lib/pages/log_in_page/log_in_page_widget.dart:181: color: FlutterFlowTheme.of(context).secondaryText,
lib/pages/log_in_page/log_in_page_widget.dart:693: FlutterFlowTheme.of(context).secondaryText,
lib/pages/create_account_page/create_account_page_widget.dart:569: .secondaryText,
lib/pages/profile/profile_widget.dart:287: .secondaryText,
lib/pages/profile/profile_widget.dart:366: .secondaryText,
lib/pages/profile/profile_widget.dart:447: .secondaryText,
lib/pages/profile/profile_widget.dart:529: .secondaryText,
```
