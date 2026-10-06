import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '/design_system/components/app_button.dart';
import '/design_system/components/mirra_bottom_sheet.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'card_composition.dart';
import 'card_data.dart';
import 'card_labels.dart';
import 'card_tokens.dart';
import 'skin_profile.dart' show fitScoreFor;

/// Карточка проанализированного продукта по макету от 01.10.2026.
///
/// Сверху вниз: шапка с круглым фото, рейтинг для типа кожи с кольцом,
/// плашка беременности, тип средства и время использования, описание;
/// «что делает» с минусами; защита от солнца; «как использовать» с
/// рутиной; состав; кнопки «в косметичку» и «сканировать ещё». Данные
/// приходят одним объектом [ProductCard] из `images.sa_card`.
///
/// Выбор типа кожи в списке меняет кольцо и вердикт, в профиль не пишется:
/// профиль отмечен подписью «ваш тип».
class ProductCardV3Widget extends StatefulWidget {
  const ProductCardV3Widget({
    super.key,
    required this.card,
    required this.brand,
    required this.productName,
    this.photoUrl,
    this.onOpenPhotos,
    this.profileSkinType,
    this.profileSensitive = false,
    this.profileAcneProne = false,
    this.pregnant = false,
    required this.inBag,
    required this.onToggleBag,
    required this.onScanMore,
    this.onEditProfile,
    this.onEditSkinType,
  });

  final ProductCard card;
  final String brand;
  final String productName;
  final String? photoUrl;
  final VoidCallback? onOpenPhotos;

  /// Профиль кожи из users: тип (dry / oily / combination / normal) и признаки.
  final String? profileSkinType;
  final bool profileSensitive;
  final bool profileAcneProne;

  /// В профиле беременность или кормление: плашка и перекраска
  /// противопоказанных компонентов.
  final bool pregnant;

  final bool inBag;
  final Future<void> Function() onToggleBag;
  final VoidCallback onScanMore;
  final VoidCallback? onEditProfile;

  /// Правка профиля кожи из списка типов: подпись «ваш тип» ведёт в анкету, где
  /// тип и признаки и задавались. Отдельно от [onEditProfile] — тот открывает
  /// Профиль ради беременности, а её анкета не спрашивает.
  final VoidCallback? onEditSkinType;

  @override
  State<ProductCardV3Widget> createState() => _ProductCardV3WidgetState();
}

class _ProductCardV3WidgetState extends State<ProductCardV3Widget> {
  late String _skinType;
  late bool _sensitive;
  late bool _acneProne;
  final CardCompositionController _composition = CardCompositionController();

  @override
  void initState() {
    super.initState();
    _skinType = kSkinTypes.contains(widget.profileSkinType)
        ? widget.profileSkinType!
        : 'normal';
    _sensitive = widget.profileSensitive;
    _acneProne = widget.profileAcneProne;
  }

  @override
  void didUpdateWidget(covariant ProductCardV3Widget old) {
    super.didUpdateWidget(old);
    // Профиль грузится на экране асинхронно и может прийти после первого
    // кадра: берём его, если человек ещё ничего не выбирал сам.
    if (old.profileSkinType != widget.profileSkinType &&
        kSkinTypes.contains(widget.profileSkinType) &&
        _skinType ==
            (kSkinTypes.contains(old.profileSkinType)
                ? old.profileSkinType
                : 'normal')) {
      _skinType = widget.profileSkinType!;
    }
    if (old.profileSensitive != widget.profileSensitive)
      _sensitive = widget.profileSensitive;
    if (old.profileAcneProne != widget.profileAcneProne)
      _acneProne = widget.profileAcneProne;
  }

  @override
  void dispose() {
    _composition.dispose();
    super.dispose();
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  String _skinLabel(String type) {
    final l = _t('skin_$type');
    return l.isEmpty ? type : l;
  }

  /// Балл для выбранной кожи. Считает общий [skinFitScore] — тот же, что у
  /// кружка в ленте Главной.
  int? _scoreFor(String type, {required bool sensitive, required bool acne}) =>
      fitScoreFor(widget.card.skinScores,
          skinType: type, sensitive: sensitive, acneProne: acne);

  Color _fitColor(FlutterFlowTheme theme, int score) => fitColor(score,
      success: theme.success, warning: theme.warning, error: theme.error);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final card = widget.card;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          CardTokens.gutter, 4, CardTokens.gutter, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOverview(theme),
          const SizedBox(height: CardTokens.sectionGap),
          _buildFunctions(theme),
          if (card.hasSpf && card.usedInMorning) ...[
            const SizedBox(height: CardTokens.sectionGap),
            _buildSpf(theme, card.spf!),
          ],
          const SizedBox(height: CardTokens.sectionGap),
          _buildHowToUse(theme),
          const SizedBox(height: CardTokens.sectionGap),
          CardComposition(
              card: card, pregnant: widget.pregnant, controller: _composition),
          const SizedBox(height: 20),
          AppButton(
            label: _t(widget.inBag ? 'card_remove_bag' : 'card_add_bag'),
            icon: LucideIcons.toolCase,
            onPressed: widget.onToggleBag,
          ),
          const SizedBox(height: 10),
          AppButton(
            label: _t('card_scan_more'),
            icon: LucideIcons.scanText,
            variant: AppButtonVariant.outline,
            onPressed: widget.onScanMore,
          ),
        ],
      ),
    );
  }

  // ── 1. Шапка, рейтинг, беременность, тип, описание ───────────────────────

  Widget _buildOverview(FlutterFlowTheme theme) {
    final card = widget.card;
    final showPregnancy =
        widget.pregnant && card.pregnancy.ingredients.isNotEmpty;
    return CardSection(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: _buildSkinRating(theme),
          ),
          if (showPregnancy)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _buildPregnancy(theme),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: _buildTypeAndUsage(theme),
          ),
          if (card.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Text(card.description,
                  style: cardText(theme, size: 15, height: 1.5)),
            )
          else
            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(FlutterFlowTheme theme) {
    final photo = widget.photoUrl;
    // Ширина на всю секцию: иначе колонка сжимается до самого широкого
    // ребёнка, и при коротком названии шапка прижимается к левому краю.
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: photo == null ? null : widget.onOpenPhotos,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CardTokens.surfaceMuted,
                  border: Border.all(color: theme.alternate, width: 6),
                  boxShadow: [BoxShadow(color: theme.border, spreadRadius: 1)],
                ),
                clipBehavior: Clip.antiAlias,
                child: photo == null
                    ? Icon(LucideIcons.flower,
                        size: 44, color: theme.secondaryBackground)
                    : Image.network(
                        photo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(LucideIcons.flower,
                            size: 44, color: theme.secondaryBackground),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            if (widget.brand.isNotEmpty)
              Text(
                widget.brand.toUpperCase(),
                textAlign: TextAlign.center,
                style: cardText(theme,
                    size: 12,
                    weight: FontWeight.w600,
                    color: theme.secondaryText,
                    letterSpacing: 1.7),
              ),
            const SizedBox(height: 6),
            SelectableText(
              widget.productName,
              textAlign: TextAlign.center,
              style: cardText(theme,
                  size: 21, weight: FontWeight.w500, height: 1.25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinRating(FlutterFlowTheme theme) {
    final score = _scoreFor(_skinType, sensitive: _sensitive, acne: _acneProne);
    if (score == null) return const SizedBox.shrink();
    final color = _fitColor(theme, score);
    // Триггер как у shadcn Select: одна строка с многоточием, фиксированная
    // высота, признаки кожи сворачиваются в счётчик «+N», полный список в шите.
    final extras = (_sensitive ? 1 : 0) + (_acneProne ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: CardTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('card_for_skin_type'),
                    style:
                        cardText(theme, size: 13, color: theme.secondaryText)),
                const SizedBox(height: 4),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openSkinSheet,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.fromLTRB(14, 0, 12, 0),
                      decoration: BoxDecoration(
                        color: theme.alternate,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: theme.primary, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(_skinLabel(_skinType).toLowerCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: cardText(theme,
                                    size: 16,
                                    weight: FontWeight.w600,
                                    color: theme.primaryVariant)),
                          ),
                          if (extras > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 1),
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('+$extras',
                                  style: cardText(theme,
                                      size: 12,
                                      weight: FontWeight.w600,
                                      color: theme.primaryVariant)),
                            ),
                          ],
                          const SizedBox(width: 8),
                          Icon(LucideIcons.chevronDown,
                              size: 16, color: theme.primaryVariant),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(_t(fitKey(score)),
                    style: cardText(theme, size: 12, weight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircularPercentIndicator(
            radius: 38,
            lineWidth: 7,
            percent: (score / 100).clamp(0.0, 1.0),
            backgroundColor: theme.border,
            progressColor: color,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animateFromLastPercent: true,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$score',
                    style: cardText(theme,
                        size: 22,
                        weight: FontWeight.w700,
                        height: 1,
                        lining: true)),
                Text('/100',
                    style: cardText(theme,
                        size: 11, color: theme.secondaryText, lining: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Список типов кожи: четыре типа из онбординга и два признака. Выбор
  /// меняет кольцо и вердикт здесь, в профиль не пишется.
  Future<void> _openSkinSheet() async {
    final theme = FlutterFlowTheme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          // «Ваш тип» ведёт в анкету: список здесь только примеряет чужой тип,
          // а менять свой нужно там, где его и спрашивали.
          void editSkinType() {
            HapticFeedback.lightImpact();
            Navigator.of(sheetContext).pop();
            widget.onEditSkinType?.call();
          }

          Widget row({
            required String type,
            required bool selected,
            required bool isProfile,
            required VoidCallback onTap,
            Widget? trailing,
          }) {
            final score = widget.card.skinScores[type];
            return Material(
              color: selected ? CardTokens.surfaceMuted : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_skinLabel(type),
                                    style: cardText(theme,
                                        size: 14, weight: FontWeight.w500)),
                                if (isProfile) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: editSkinType,
                                    // Подпись мелкая, без запаса по краям в неё
                                    // не попасть пальцем.
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2, vertical: 6),
                                      child: Text(_t('card_your_type'),
                                          style: cardText(theme,
                                                  size: 11,
                                                  weight: FontWeight.w600,
                                                  color: theme.primaryVariant)
                                              // Подчёркивание — единственный
                                              // признак, что подпись нажимается;
                                              // так же помечена «изменить» в
                                              // плашке беременности.
                                              .copyWith(
                                                  decoration:
                                                      TextDecoration.underline)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Container(
                                height: 4,
                                color: theme.divider,
                                alignment: AlignmentDirectional.centerStart,
                                child: FractionallySizedBox(
                                  widthFactor:
                                      ((score ?? 0) / 100).clamp(0.0, 1.0),
                                  child: Container(
                                      color: _fitColor(theme, score ?? 0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 34,
                        child: Text(score == null ? '' : '$score',
                            textAlign: TextAlign.right,
                            style: cardText(theme,
                                size: 15,
                                weight: FontWeight.w700,
                                lining: true)),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 4),
                        trailing
                      ],
                    ],
                  ),
                ),
              ),
            );
          }

          void pickType(String type) {
            HapticFeedback.lightImpact();
            unawaited(
                AnalyticsService.instance.trackProductSkin(skinName: type));
            setState(() => _skinType = type);
            Navigator.of(sheetContext).pop();
          }

          void toggle(String flag, bool value) {
            HapticFeedback.lightImpact();
            setState(() {
              if (flag == 'sensitive') _sensitive = value;
              if (flag == 'acne_prone') _acneProne = value;
            });
            setSheet(() {});
          }

          return MirraBottomSheet(
            surfaceColor: theme.alternate,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('card_skin_picker_title'),
                    style:
                        cardText(theme, size: 12, color: theme.secondaryText)),
                const SizedBox(height: 8),
                for (final type in kSkinTypes)
                  row(
                    type: type,
                    selected: type == _skinType,
                    isProfile: type == widget.profileSkinType,
                    onTap: () => pickType(type),
                  ),
                Divider(height: 16, color: theme.divider),
                for (final flag in kSkinFlags)
                  row(
                    type: flag,
                    selected: false,
                    isProfile: flag == 'sensitive'
                        ? widget.profileSensitive
                        : widget.profileAcneProne,
                    onTap: () => toggle(
                        flag, !(flag == 'sensitive' ? _sensitive : _acneProne)),
                    trailing: Switch.adaptive(
                      value: flag == 'sensitive' ? _sensitive : _acneProne,
                      activeColor: theme.primary,
                      onChanged: (v) => toggle(flag, v),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPregnancy(FlutterFlowTheme theme) {
    final preg = widget.card.pregnancy;
    return Container(
      decoration: BoxDecoration(
          color: theme.errorBg, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: theme.error, shape: BoxShape.circle),
            child: const Icon(LucideIcons.triangleAlert,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('card_preg_title'),
                    style: cardText(theme, size: 15, weight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(_t('card_preg_body'),
                    style: cardText(theme, size: 13, height: 1.45)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final name in preg.ingredients)
                      Material(
                        color: theme.alternate,
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          onTap: () => _composition.reveal(name),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            child: Text(name, style: cardText(theme, size: 13)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style:
                        cardText(theme, size: 12, color: theme.secondaryText),
                    children: [
                      TextSpan(text: '${_t('card_preg_profile')} · '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: widget.onEditProfile,
                          child: Text(_t('card_preg_change'),
                              style: cardText(theme,
                                      size: 12, color: theme.primaryText)
                                  .copyWith(
                                      decoration: TextDecoration.underline)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeAndUsage(FlutterFlowTheme theme) {
    final card = widget.card;
    final typeLabel = _t(productTypeLabelKey(card.productType));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t('card_product_type'),
                  style: cardText(theme, size: 12, color: theme.secondaryText)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: CardTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  typeLabel.isEmpty ? card.productType : typeLabel,
                  style: cardText(theme,
                      size: 14,
                      weight: FontWeight.w600,
                      color: theme.primaryVariant),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _usageIcon(
          theme,
          active: card.usedInMorning,
          icon: LucideIcons.sun,
          label: _t('card_day'),
          activeBg: theme.secondary,
          activeFg: theme.primaryText,
          badge:
              card.hasSpf && card.usedInMorning ? _t('card_spf_badge') : null,
        ),
        const SizedBox(width: 8),
        _usageIcon(
          theme,
          active: card.usedInEvening,
          icon: LucideIcons.moon,
          label: _t('card_night'),
          activeBg: theme.secondaryBackground,
          activeFg: theme.primaryVariant,
        ),
      ],
    );
  }

  Widget _usageIcon(
    FlutterFlowTheme theme, {
    required bool active,
    required IconData icon,
    required String label,
    required Color activeBg,
    required Color activeFg,
    String? badge,
  }) =>
      SizedBox(
        width: 56,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: active ? activeBg : CardTokens.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 22, color: active ? activeFg : theme.textDisabled),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: cardText(theme,
                    size: 12,
                    weight: FontWeight.w500,
                    color: active ? theme.primaryText : theme.secondaryText)),
            if (badge != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: theme.secondary,
                    borderRadius: BorderRadius.circular(999)),
                child: Text(badge,
                    style: cardText(theme,
                        size: 11, weight: FontWeight.w700, letterSpacing: 0.2)),
              ),
            ],
          ],
        ),
      );

  // ── 2. Что делает ─────────────────────────────────────────────────────────

  Widget _buildFunctions(FlutterFlowTheme theme) {
    final card = widget.card;
    if (card.functions.isEmpty && card.drawbacks.isEmpty)
      return const SizedBox.shrink();
    return CardSection(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CardSectionTitle(_t('card_what_it_does')),
          ),
          const SizedBox(height: 16),
          if (card.functions.isNotEmpty)
            _iconGrid(theme, [
              for (final f in card.functions)
                (
                  icon: kFunctionIcons[f.key] ?? LucideIcons.circleCheck,
                  label: _labelOr(functionLabelKey(f.key), f.key),
                  bg: CardTokens.surfaceMuted,
                  fg: theme.primaryVariant,
                ),
            ]),
          if (card.functions.isNotEmpty && card.drawbacks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: theme.divider, indent: 4, endIndent: 4),
            const SizedBox(height: 16),
          ],
          if (card.drawbacks.isNotEmpty)
            _iconGrid(theme, [
              for (final d in card.drawbacks)
                (
                  icon: kDrawbackIcons[d.key] ?? LucideIcons.circleMinus,
                  label: _labelOr(drawbackLabelKey(d.key), d.key),
                  bg: theme.errorBg,
                  fg: CardTokens.minusIcon,
                ),
            ]),
        ],
      ),
    );
  }

  String _labelOr(String key, String fallback) {
    final l = _t(key);
    return l.isEmpty ? fallback : l;
  }

  /// Сетка из пяти колонок: иконка 52 × 52 и подпись под ней.
  Widget _iconGrid(FlutterFlowTheme theme,
          List<({IconData icon, String label, Color bg, Color fg})> items) =>
      LayoutBuilder(
        builder: (context, constraints) {
          const gap = 6.0;
          final cell = (constraints.maxWidth - gap * 4) / 5;
          return Wrap(
            spacing: gap,
            runSpacing: 12,
            children: [
              for (final item in items)
                SizedBox(
                  width: cell,
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: item.bg,
                            borderRadius: BorderRadius.circular(18)),
                        child: Icon(item.icon, size: 24, color: item.fg),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: cardText(theme,
                            size: 12, weight: FontWeight.w500, height: 1.25),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      );

  // ── 3. Защита от солнца ───────────────────────────────────────────────────

  Widget _buildSpf(FlutterFlowTheme theme, CardSpf spf) {
    final caption = cardText(theme, size: 12, color: theme.secondaryText);
    Widget spectrum(String label, String note, bool ok) => Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: ok ? theme.successBg : theme.errorBg,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: ok ? theme.success : theme.error,
                      shape: BoxShape.circle),
                  child: Icon(ok ? LucideIcons.check : LucideIcons.x,
                      size: 12, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: cardText(theme, size: 13, height: 1.25),
                      children: [
                        TextSpan(
                            text: label,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(text: ' · $note'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

    Widget tag(String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
              color: CardTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(6)),
          child: Text(text, style: cardText(theme, size: 11)),
        );

    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardSectionTitle(
            _t('card_sun_protection'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: theme.secondary,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(_t('card_spf_badge'),
                  style: cardText(theme, size: 13, weight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),
          Text(_t('card_filter_type'), style: caption),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: CardTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                for (final type in const ['mineral', 'hybrid', 'chemical'])
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 9, horizontal: 4),
                      decoration: BoxDecoration(
                        color: spf.filterType == type ? theme.primary : null,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        _t('card_filter_$type'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: cardText(theme,
                            size: 13,
                            weight: spf.filterType == type
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: spf.filterType == type
                                ? Colors.white
                                : theme.secondaryText),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(_t('card_filter_${spf.filterType}_text'),
              style: cardText(theme, size: 13, height: 1.45)),
          const SizedBox(height: 16),
          Text(_t('card_spectrum'), style: caption),
          const SizedBox(height: 8),
          Row(
            children: [
              spectrum('UVB', _t('card_uvb_note'), spf.uvb),
              const SizedBox(width: 8),
              spectrum('UVA', _t('card_uva_note'), spf.uva),
            ],
          ),
          if (spf.filters.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(_t('card_filters_in_formula'), style: caption),
            const SizedBox(height: 8),
            for (final f in spf.filters)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.border, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child:
                              Text(f.name, style: cardText(theme, size: 14))),
                      const SizedBox(width: 10),
                      Wrap(
                        spacing: 4,
                        children: [
                          tag(_t(f.type == 'mineral'
                              ? 'card_tag_mineral'
                              : 'card_tag_chemical')),
                          for (final band in f.spectrum) tag(band),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (!spf.uva) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                  color: theme.warningBg,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(LucideIcons.info, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(_t('card_uva_missing'),
                          style: cardText(theme, size: 13, height: 1.45))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── 4. Как использовать и рутина ──────────────────────────────────────────

  Widget _buildHowToUse(FlutterFlowTheme theme) {
    final card = widget.card;
    // Трек рисуем только с шагами: у типа «other» их нет, и пустые кружки
    // читались как сломанная рутина.
    final morning = card.usedInMorning && card.routineMorning.isNotEmpty;
    final evening = card.usedInEvening && card.routineEvening.isNotEmpty;
    if (card.howToUse.isEmpty && !morning && !evening) {
      return const SizedBox.shrink();
    }
    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardSectionTitle(_t('card_how_to_use')),
          if (card.howToUse.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: CardTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: theme.alternate, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.lightbulb, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(card.howToUse,
                          style: cardText(theme, size: 14, height: 1.5))),
                ],
              ),
            ),
          ],
          if (morning) ...[
            const SizedBox(height: 18),
            _routineTrack(theme,
                title: _t('card_routine_morning'),
                icon: LucideIcons.sun,
                iconBg: theme.secondary,
                iconFg: theme.primaryText,
                stepKeys: kMorningStepKeys,
                active: card.routineMorning),
          ],
          if (evening) ...[
            const SizedBox(height: 18),
            _routineTrack(theme,
                title: _t('card_routine_evening'),
                icon: LucideIcons.moon,
                iconBg: theme.secondaryBackground,
                iconFg: theme.primaryVariant,
                stepKeys: kEveningStepKeys,
                active: card.routineEvening),
          ],
        ],
      ),
    );
  }

  Widget _routineTrack(
    FlutterFlowTheme theme, {
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required List<String> stepKeys,
    required List<int> active,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration:
                    BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 15, color: iconFg),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: cardText(theme, size: 14, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 17,
                child: FractionallySizedBox(
                  alignment: Alignment.center,
                  widthFactor: 0.8,
                  child: Container(height: 2, color: theme.border),
                ),
              ),
              Row(
                // По верхнему краю, а не по центру: подписи под шагами разной
                // длины, и центрирование разводило кружки с цифрами по разной
                // высоте — заодно линия, прибитая к top: 17, проходила мимо их
                // центров.
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < stepKeys.length; i++)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: active.contains(i)
                                  ? theme.primary
                                  : theme.alternate,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: active.contains(i)
                                      ? theme.primary
                                      : theme.border,
                                  width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text('${i + 1}',
                                style: cardText(theme,
                                    size: 14,
                                    weight: FontWeight.w600,
                                    lining: true,
                                    color: active.contains(i)
                                        ? Colors.white
                                        : theme.secondaryText)),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            // Под подпись отведены два ряда всегда, даже если
                            // слово короткое: высота трека не должна зависеть
                            // от того, переносится ли текст. Считаем по
                            // системному масштабу шрифта, иначе на крупном
                            // тексте подпись обрежется.
                            height: MediaQuery.textScalerOf(context).scale(11) *
                                1.25 *
                                2,
                            // Длинные слова ломаются по мягким переносам из
                            // локализации («Увлаж‑нение»), а не по последней
                            // букве; многоточие только на случай очень
                            // крупного системного шрифта.
                            child: Text(
                              _t(stepKeys[i]),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: cardText(theme,
                                  size: 11,
                                  height: 1.25,
                                  weight: active.contains(i)
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: active.contains(i)
                                      ? theme.primaryVariant
                                      : theme.secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      );
}
