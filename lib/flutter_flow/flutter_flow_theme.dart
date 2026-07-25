// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum DeviceSize {
  mobile,
  tablet,
  desktop,
}

abstract class FlutterFlowTheme {
  static DeviceSize deviceSize = DeviceSize.mobile;

  static FlutterFlowTheme of(BuildContext context) {
    deviceSize = getDeviceSize(context);
    return LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  // Additive design-system colour tokens (Phase 0). New fields only — no existing
  // field is changed or removed. See design_system/DESIGN_SYSTEM.md for rationale.
  late Color primaryVariant;
  late Color surfaceMuted;
  late Color border;
  late Color divider;
  late Color textTertiary;
  late Color textDisabled;
  late Color errorBg;
  late Color successBg;
  late Color warningBg;
  late Color overlay08;
  late Color overlay10;
  late Color overlay20;
  late Color overlay27;
  late Color onPrimary;

  FFDesignTokens get designToken => FFDesignTokens(this);

  // Additive scale accessors (Phase 0). `designToken` is retained unchanged for
  // backward compatibility; these are shorter aliases used going forward.
  FFSpacing get space => const FFSpacing();
  FFRadius get radii => const FFRadius();
  FFShadows get shadow => FFShadows(this);
  FFOpacity get opacity => const FFOpacity();
  FFSizing get size => const FFSizing();

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  // displayXS: the 24–26px section/sheet title role (Design Review Initiative 11),
  // replacing the ad-hoc `headlineSmall.override(fontSize: 26, w700)`.
  String get displayXSFamily => headlineSmallFamily;
  bool get displayXSIsCustom => headlineSmallIsCustom;
  TextStyle get displayXS => headlineSmall.override(
        fontFamily: headlineSmallFamily,
        fontSize: 26.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w700,
        useGoogleFonts: !headlineSmallIsCustom,
      );
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => {
        DeviceSize.mobile: MobileTypography(this),
        DeviceSize.tablet: TabletTypography(this),
        DeviceSize.desktop: DesktopTypography(this),
      }[deviceSize]!;
}

DeviceSize getDeviceSize(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 479) {
    return DeviceSize.mobile;
  } else if (width < 991) {
    return DeviceSize.tablet;
  } else {
    return DeviceSize.desktop;
  }
}

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF5C85D9);
  late Color secondary = const Color(0xFFF2EBB4);
  late Color tertiary = const Color(0xFFF4CFBC);
  late Color alternate = const Color(0xFFFFFFFF);
  late Color primaryText = const Color(0xFF1A1A1A);
  late Color secondaryText = const Color(0xFF6B6B6B);
  late Color primaryBackground = const Color(0xFFEBF0FC);
  late Color secondaryBackground = const Color(0xFFCBDDFE);
  late Color accent1 = const Color(0x4D9489F5);
  late Color accent2 = const Color(0x4C39D2C0);
  late Color accent3 = const Color(0x4CEE8B60);
  late Color accent4 = const Color(0x9AFFFFFF);
  late Color success = const Color(0xFF048178);
  late Color warning = const Color(0xFFFCDC0C);
  late Color error = const Color(0xFFFF5963);
  late Color info = const Color(0xFFE7E8EB);

  // Additive design-system colour tokens (Phase 0). Values lifted verbatim from
  // existing UI (see DESIGN_AUDIT_EVIDENCE.md). No existing colour value changed.
  late Color primaryVariant = const Color(0xFF3B6FCC);
  late Color surfaceMuted = const Color(0xFFF3F4F6);
  late Color border = const Color(0xFFE0E0E0);
  late Color divider = const Color(0xFFE6E6E6);
  late Color textTertiary = const Color(0xFF555555);
  late Color textDisabled = const Color(0xFFAFAFB0);
  late Color errorBg = const Color(0xFFFFEBEE);
  late Color successBg = const Color(0xFFE8F5E9);
  late Color warningBg = const Color(0xFFFFF3E0);
  late Color overlay08 = const Color(0x14000000);
  late Color overlay10 = const Color(0x1A000000);
  late Color overlay20 = const Color(0x33000000);
  late Color overlay27 = const Color(0x44000000);
  late Color onPrimary = const Color(0xFFFFFFFF);
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class MobileTypography extends Typography {
  MobileTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Raleway';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 57.0,
      );
  String get displayMediumFamily => 'Raleway';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 45.0,
      );
  String get displaySmallFamily => 'Raleway';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36.0,
      );
  String get headlineLargeFamily => 'Raleway';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 32.0,
      );
  String get headlineMediumFamily => 'Raleway';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 24.0,
      );
  String get headlineSmallFamily => 'Raleway';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
      );
  String get titleLargeFamily => 'Raleway';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22.0,
      );
  String get titleMediumFamily => 'Raleway';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.raleway(
        color: theme.info,
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
      );
  String get titleSmallFamily => 'Raleway';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.raleway(
        color: theme.info,
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
      );
  String get labelLargeFamily => 'Raleway';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
      );
  String get labelMediumFamily => 'Raleway';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      );
  String get labelSmallFamily => 'Raleway';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
      );
  String get bodyLargeFamily => 'Raleway';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontSize: 16.0,
      );
  String get bodyMediumFamily => 'Raleway';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
  String get bodySmallFamily => 'Raleway';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      );
}

class TabletTypography extends Typography {
  TabletTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Raleway';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 57.0,
      );
  String get displayMediumFamily => 'Raleway';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 45.0,
      );
  String get displaySmallFamily => 'Raleway';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36.0,
      );
  String get headlineLargeFamily => 'Raleway';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 32.0,
      );
  String get headlineMediumFamily => 'Raleway';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 24.0,
      );
  String get headlineSmallFamily => 'Raleway';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
      );
  String get titleLargeFamily => 'Raleway';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22.0,
      );
  String get titleMediumFamily => 'Raleway';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.raleway(
        color: theme.info,
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
      );
  String get titleSmallFamily => 'Raleway';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.raleway(
        color: theme.info,
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
      );
  String get labelLargeFamily => 'Raleway';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
      );
  String get labelMediumFamily => 'Raleway';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      );
  String get labelSmallFamily => 'Raleway';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
      );
  String get bodyLargeFamily => 'Raleway';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontSize: 16.0,
      );
  String get bodyMediumFamily => 'Raleway';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
  String get bodySmallFamily => 'Raleway';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      );
}

class DesktopTypography extends Typography {
  DesktopTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Raleway';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 57.0,
      );
  String get displayMediumFamily => 'Raleway';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 45.0,
      );
  String get displaySmallFamily => 'Raleway';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36.0,
      );
  String get headlineLargeFamily => 'Raleway';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 32.0,
      );
  String get headlineMediumFamily => 'Raleway';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 24.0,
      );
  String get headlineSmallFamily => 'Raleway';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
      );
  String get titleLargeFamily => 'Raleway';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22.0,
      );
  String get titleMediumFamily => 'Raleway';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.raleway(
        color: theme.info,
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
      );
  String get titleSmallFamily => 'Raleway';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.raleway(
        color: theme.info,
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
      );
  String get labelLargeFamily => 'Raleway';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
      );
  String get labelMediumFamily => 'Raleway';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      );
  String get labelSmallFamily => 'Raleway';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
      );
  String get bodyLargeFamily => 'Raleway';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.raleway(
        color: theme.primaryText,
        fontSize: 16.0,
      );
  String get bodyMediumFamily => 'Raleway';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
  String get bodySmallFamily => 'Raleway';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.raleway(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      );
}

class FFDesignTokens {
  const FFDesignTokens(this.theme);
  final FlutterFlowTheme theme;
  FFSpacing get spacing => const FFSpacing();
  FFRadius get radius => const FFRadius();
  FFShadows get shadow => FFShadows(theme);
}

class FFSpacing {
  const FFSpacing();
  // Existing tokens — unchanged for backward compatibility.
  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get xl => 32.0;
  // Canonical numeric scale (Phase 0, additive). Use these going forward.
  double get s2 => 2.0;
  double get s4 => 4.0;
  double get s8 => 8.0;
  double get s12 => 12.0;
  double get s16 => 16.0;
  double get s20 => 20.0;
  double get s24 => 24.0;
  double get s32 => 32.0;
  double get s40 => 40.0;
  double get s48 => 48.0;
  double get s64 => 64.0;
}

class FFRadius {
  const FFRadius();
  // Existing tokens — unchanged for backward compatibility.
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get full => 9999.0;
  // Canonical numeric scale (Phase 0, additive). Use these going forward.
  double get r4 => 4.0;
  double get r8 => 8.0;
  double get r12 => 12.0;
  double get r16 => 16.0;
  double get r24 => 24.0;
  double get r32 => 32.0;
}

class FFOpacity {
  const FFOpacity();
  double get o04 => 0.04;
  double get o08 => 0.08;
  double get o12 => 0.12;
  double get o16 => 0.16;
  double get o24 => 0.24;
  double get o32 => 0.32;
  double get o48 => 0.48;
  double get o64 => 0.64;
  double get o80 => 0.80;
  double get o92 => 0.92;
}

class FFSizing {
  const FFSizing();
  // Icons
  double get iconXs => 16.0;
  double get iconSm => 20.0;
  double get iconMd => 24.0;
  double get iconLg => 28.0;
  double get iconXl => 32.0;
  double get icon2xl => 48.0;
  // Buttons / inputs
  double get buttonSm => 36.0;
  double get buttonMd => 44.0;
  double get buttonLg => 52.0;
  double get inputHeight => 52.0;
  // Avatars
  double get avatarXs => 24.0;
  double get avatarSm => 32.0;
  double get avatarMd => 40.0;
  double get avatarLg => 56.0;
  double get avatarXl => 80.0;
  // Border widths
  double get borderHairline => 1.0;
  double get borderThick => 2.0;
}

class FFShadows {
  const FFShadows(this.theme);
  final FlutterFlowTheme theme;
  BoxShadow get sm => const BoxShadow(
      blurRadius: 3.0,
      color: const Color(0x1A000000),
      offset: const Offset(0.0, 1.0),
      spreadRadius: 0.0);
  BoxShadow get md => const BoxShadow(
      blurRadius: 6.0,
      color: const Color(0x1A000000),
      offset: const Offset(0.0, 3.0),
      spreadRadius: 0.0);
  BoxShadow get lg => const BoxShadow(
      blurRadius: 15.0,
      color: const Color(0x1A000000),
      offset: const Offset(0.0, 8.0),
      spreadRadius: 0.0);
  BoxShadow get xl => const BoxShadow(
      blurRadius: 25.0,
      color: const Color(0x1A000000),
      offset: const Offset(0.0, 16.0),
      spreadRadius: 0.0);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null) {
      font = GoogleFonts.getFont(fontFamily,
          fontWeight: fontWeight ?? this.fontWeight,
          fontStyle: fontStyle ?? this.fontStyle);
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
