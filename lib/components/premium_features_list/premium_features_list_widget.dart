import '/domain/cosmetic_bag/cosmetic_bag_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Что PRO даёт на самом деле: снимает два лимита — на сканы и на косметичку.
/// Больше за подпиской ничего не закрыто (клиентский гейт на разборе состава
/// снят), поэтому список короткий: два обещания вместо восьми, из которых шесть
/// уже были бесплатными.
///
/// Живёт на тёмной поверхности пейвола, отсюда белый текст и подложки на
/// прозрачности, а не токены фона.
class PremiumFeaturesListWidget extends StatelessWidget {
  const PremiumFeaturesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final t = FFLocalizations.of(context);

    return Padding(
      // По горизонтали отступов нет: карточки выгод должны быть той же ширины,
      // что и карточки тарифов ниже, а внешний отступ уже задан на пейволе.
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BenefitCard(
            icon: Icons.all_inclusive_rounded,
            title: t.getText('ic2_pro_unlimited'),
            body: t.getText('pro_benefit_scans_sub'),
          ),
          SizedBox(height: theme.space.s12),
          _BenefitCard(
            icon: Icons.spa_rounded,
            title: t.getText('pro_benefit_bag_title'),
            // Бесплатный лимит подставляем из той же константы, по которой
            // косметичка его и считает, — чтобы обещание не разошлось с кодом.
            body: t
                .getText('pro_benefit_bag_sub')
                .replaceAll('{n}', '$kFreeBagSlots'),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.space.s16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: theme.opacity.o08),
        borderRadius: BorderRadius.circular(theme.radii.r16),
        border: Border.all(
          color: Colors.white.withValues(alpha: theme.opacity.o12),
          width: theme.size.borderHairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: theme.size.avatarMd,
            height: theme.size.avatarMd,
            decoration:
                BoxDecoration(color: theme.primary, shape: BoxShape.circle),
            child: Icon(icon, color: theme.onPrimary, size: theme.size.iconSm),
          ),
          SizedBox(width: theme.space.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.titleMedium.override(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    lineHeight: 1.25,
                  ),
                ),
                SizedBox(height: theme.space.s4),
                Text(
                  body,
                  style: theme.bodySmall.override(
                    color: Colors.white.withValues(alpha: theme.opacity.o64),
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                    lineHeight: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
