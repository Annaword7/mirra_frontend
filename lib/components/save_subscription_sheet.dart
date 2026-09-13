import 'package:flutter/material.dart';

import '/design_system/components/app_button.dart';
import '/design_system/components/mirra_bottom_sheet.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Offered once to a guest who has just paid: the subscription is theirs, but
/// the identity holding it is an anonymous session that only exists on this
/// device. An account is what makes it recoverable.
///
/// Shown AFTER the charge, never before it — access is not withheld pending
/// registration, and dismissing costs the user nothing: the profile keeps its
/// "create account" and "sign in" entries.
class SaveSubscriptionSheet extends StatelessWidget {
  const SaveSubscriptionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final t = FFLocalizations.of(context);

    return MirraBottomSheet(
      // Explicit white, like guest_prefs_sheet and negative_feedback: the
      // default secondaryBackground is the pale blue, and the sheet reads as a
      // different surface from every other popup in the app.
      surfaceColor: Colors.white,
      crossAxisAlignment: CrossAxisAlignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.workspace_premium_rounded,
                color: theme.primary, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            t.getText('savepro_title'),
            textAlign: TextAlign.center,
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              color: theme.primaryText,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.headlineSmallIsCustom,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            t.getText('savepro_body'),
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: t.getText('savepro_cta'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: t.getText('savepro_later'),
            variant: AppButtonVariant.text,
            size: AppButtonSize.sm,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
