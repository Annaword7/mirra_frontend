import '/backend/supabase/database/database.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Shared "outline + glow" decoration used by the Косметичка cards
/// ("Твой профиль" and "Совместимость") so they look identical.
BoxDecoration glowCardDecoration(FlutterFlowTheme theme) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border:
          Border.all(color: theme.primary.withValues(alpha: 0.4), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: theme.primary.withValues(alpha: 0.18),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
      ],
    );

/// "Твой профиль" summary card: shows the user's skin type / flags / goals from
/// onboarding, or a CTA to complete it. Tapping re-opens the skin-type quiz.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({super.key, required this.profileRow, this.returnTo});

  final UsersRow? profileRow;

  /// Куда вернуть пользователя после анкеты (по умолчанию — на Главную).
  final String? returnTo;

  static const _typeKeys = {
    'dry': 'obq_type_dry',
    'oily': 'obq_type_oily',
    'combination': 'obq_type_combo',
    'normal': 'obq_type_normal',
  };
  static const _goalKeys = {
    'hydration': 'obq_goal_hydration',
    'barrier': 'obq_goal_barrier',
    'anti_aging': 'obq_goal_anti_aging',
    'pigmentation': 'obq_goal_pigmentation',
    'acne': 'obq_goal_acne',
    'pores': 'obq_goal_pores',
  };

  void _open(BuildContext context) => context.pushNamed(
        OnboardingQuizWidget.routeName,
        queryParameters: {
          if (returnTo != null)
            'returnTo': serializeParam(returnTo, ParamType.String),
        }.withoutNulls,
      );

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final t = FFLocalizations.of(context);
    final skinType = profileRow?.skinType;
    final hasProfile = skinType != null && skinType.isNotEmpty;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _open(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: glowCardDecoration(theme),
            child: hasProfile
                ? _profileView(context, theme, t, skinType)
                : _ctaView(context, theme, t),
          ),
        ),
      ),
    );
  }

  Widget _ctaView(
      BuildContext context, FlutterFlowTheme theme, FFLocalizations t) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.auto_awesome, color: theme.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.getText('home_profile_cta_title'),
                style: theme.bodyLarge.override(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0),
              ),
              const SizedBox(height: 2),
              Text(
                t.getText('home_profile_cta_sub'),
                style: theme.bodyMedium.override(
                    color: Colors.black54, fontSize: 13, letterSpacing: 0),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios, color: theme.primary, size: 16),
      ],
    );
  }

  Widget _profileView(BuildContext context, FlutterFlowTheme theme,
      FFLocalizations t, String skinType) {
    final chips = <String>[
      t.getText(_typeKeys[skinType] ?? 'obq_type_normal'),
      if (profileRow?.skinSensitivity == true) t.getText('obq_flag_sensitive'),
      if (profileRow?.acneProne == true) t.getText('obq_flag_acne'),
    ];
    final goals = (profileRow?.skinGoals ?? [])
        .map((g) => t.getText(_goalKeys[g] ?? g))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.face_retouching_natural,
                color: theme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.getText('home_profile_title'),
                style: theme.bodyMedium.override(
                    color: const Color(0xFF111111),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6),
              ),
            ),
            Text(
              t.getText('home_profile_edit'),
              style: theme.bodyMedium.override(
                  color: theme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0),
            ),
            Icon(Icons.chevron_right, color: theme.primary, size: 18),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips
              .map((c) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.border),
                    ),
                    child: Text(
                      c,
                      style: theme.bodyMedium.override(
                          color: const Color(0xFF333333),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0),
                    ),
                  ))
              .toList(),
        ),
        if (goals.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            '${t.getText('obq_result_goals_prefix')} ${goals.join(', ')}',
            style: theme.bodyMedium.override(
                color: const Color(0xFF555555), fontSize: 13, letterSpacing: 0),
          ),
        ],
      ],
    );
  }
}
