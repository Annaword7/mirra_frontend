import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/score_breakdown/score_breakdown_widget.dart';
import '/design_system/foundations/score_status.dart';
import '/index.dart';

/// Product card v2: answer-first layout.
///
/// The card leads with a verdict ("is this right for me?"), backed by the
/// skin-type fit matrix. Tapping a matrix row is an EPHEMERAL preview —
/// it re-composes the verdict locally and never writes to the profile
/// (onboarding is the single source of truth). All data is profile-independent
/// and comes from the stored analysis; no network calls happen on tap.
///
/// Порядок блоков — по порядку вопросов, которые задаёт человек:
///  - вердикт + число фита, под ним строка честности (сколько состава разобрано
///    и какова уверенность разбора)
///  - беременность: предупреждение всем, спокойный ответ — только тем, у кого
///    это указано в профиле
///  - совместимость: своя строка, остальные типы кожи — по кнопке «сравнить»
///  - что может пойти не так (warnings с адресатами)
///  - что реально работает: активы со светофором дозировок
///  - обещания с упаковки: счёт «подтверждено N из M», разбор по тапу
///  - «разбор глубже»: состав по номерам, доза против MEC, уверенность и
///    всё, что передали в [deepExtras]
class ProductCardV2Widget extends StatefulWidget {
  const ProductCardV2Widget({
    super.key,
    required this.image,
    required this.skinCompatibility,
    required this.topIngredients,
    required this.ingredientIssues,
    this.userSkinType,
    this.userIsSensitive = false,
    this.userIsAcneProne = false,
    this.isPro = false,
    this.pregnancyRelevant = false,
    this.profileCta,
    this.deepExtras = const [],
  });

  final ImagesRow image;
  final List<ImageSkinCompatibilityRow> skinCompatibility;
  final List<ImageTopIngredientsRow> topIngredients;
  final List<ImageIngredientIssuesRow> ingredientIssues;

  /// Skin type from the user's onboarding profile (null = cold start).
  final String? userSkinType;

  /// Sensitivity / acne flags from onboarding — surface warnings addressed to
  /// 'sensitive' / 'acne_prone' even when a different skin-type row is selected.
  final bool userIsSensitive;
  final bool userIsAcneProne;

  /// Whether the pro layer (1% line, evidence vs MEC, confidence) is visible.
  final bool isPro;

  /// В профиле указана беременность или кормление. Спокойный вердикт («можно»)
  /// показываем только им — остальным он отвечает на незаданный вопрос. А вот
  /// предупреждение видно всем независимо от профиля: прятать риск нельзя.
  final bool pregnancyRelevant;

  /// Приглашение заполнить профиль. Стоит ПОД вердиктом, а не над ним: сначала
  /// ответ, потом просьба поработать.
  final Widget? profileCta;

  /// Блоки, уезжающие внутрь «Разбора глубже» (состав, радар, экспертный
  /// текст). Хозяин экрана решает, что туда сложить.
  final List<Widget> deepExtras;

  @override
  State<ProductCardV2Widget> createState() => _ProductCardV2WidgetState();
}

class _ProductCardV2WidgetState extends State<ProductCardV2Widget> {
  /// Ephemeral viewing context: starts from the profile, changed by taps.
  /// Never persisted — a cosmetologist can flip through types per client.
  String? _selectedSkinType;
  bool _proExpanded = false;

  /// Разбор обещаний с упаковки раскрыт (по умолчанию виден только счёт).
  bool _claimsExpanded = false;

  /// Методика проверки на беременность раскрыта (по умолчанию — ссылкой).
  bool _pregHowExpanded = false;

  /// Set once the user taps a matrix row. After that, an async profile load
  /// must not override their manual preview (onboarding stays the cold-start
  /// default; taps are ephemeral and win locally).
  bool _userTouchedMatrix = false;

  @override
  void initState() {
    super.initState();
    _selectedSkinType = widget.userSkinType;
  }

  @override
  void didUpdateWidget(covariant ProductCardV2Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Profile may arrive after the first build (loaded asynchronously on the
    // page). Adopt it as the viewing context only until the user previews a
    // type manually.
    if (widget.userSkinType != oldWidget.userSkinType && !_userTouchedMatrix) {
      _selectedSkinType = widget.userSkinType;
    }
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  String _skinTypeLabel(String skinType) {
    final label = _t('skin_$skinType');
    return label.isEmpty ? skinType : label;
  }

  // ── Severity / fit palette (single light theme; the app has no dark mode) ──
  static const Color _goodColor = Color(0xFF1B5E20); // green
  static const Color _warnColor = Color(0xFFFFB300); // amber
  static const Color _badColor = Color(0xFFD32F2F); // red

  Color _fitColor(int score) {
    if (score >= 75) return _goodColor;
    if (score >= 60) return _warnColor;
    return _badColor;
  }
  // Ingredient status colors come from statusColor() in the score_status
  // foundation (working green / borderline amber / decorative & unknown grey).

  ImageSkinCompatibilityRow? get _selectedRow {
    if (_selectedSkinType == null) return null;
    for (final row in widget.skinCompatibility) {
      if (row.skinType == _selectedSkinType) return row;
    }
    return null;
  }

  /// Warnings relevant to the selected skin type; all warnings on cold start.
  List<ImageIngredientIssuesRow> get _visibleWarnings {
    final issues = widget.ingredientIssues
        .where((i) => i.relevantFor.isNotEmpty) // [] = informational (pro only)
        .toList();
    final type = _selectedSkinType;
    if (type == null) return issues; // cold start — show all
    return issues.where((i) {
      final rf = i.relevantFor;
      return rf.contains('all') ||
          rf.contains(type) ||
          (widget.userIsSensitive && rf.contains('sensitive')) ||
          (widget.userIsAcneProne && rf.contains('acne_prone'));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      // Порядок отвечает на вопросы в том порядке, в каком их задают: что это
      // значит → это про меня? → что может пойти не так → что тут работает →
      // врут ли на упаковке → подробности по запросу.
      children: [
        _buildVerdict(theme),
        // Из чего сложилась оценка — сразу под числом, свёрнутым списком осей.
        ScoreBreakdownWidget(
          scoringLog: widget.image.saScoringLog,
          topIngredients: widget.topIngredients,
          ingredientIssues: widget.ingredientIssues,
        ),
        if (widget.profileCta != null) widget.profileCta!,
        _buildPregnancy(theme),
        _buildFit(theme),
        if (_visibleWarnings.isNotEmpty) _buildWarnings(theme),
        if (widget.topIngredients.isNotEmpty) _buildActives(theme),
        if (_claimAudit.isNotEmpty) _buildClaimAudit(theme),
        if (widget.isPro) _buildProLayer(theme),
      ],
    );
  }

  // ── Verdict ───────────────────────────────────────────────────────────────

  Widget _buildVerdict(FlutterFlowTheme theme) {
    final row = _selectedRow;
    final verdictText = (row?.verdict?.isNotEmpty ?? false)
        ? row!.verdict!
        : (widget.image.saQuickSummary ?? '');
    final fitScore = row?.compatibilityScore ??
        (widget.image.saCompositeScore?.round() ?? 0);
    // Подпись под кольцом называет тип кожи, для которого посчитано число.
    // Раньше тут было «для вас», а тот же балл дублировался строкой ниже —
    // человек видел одну оценку дважды и не понимал, зачем.
    final fitLabel = row != null
        ? _skinTypeLabel(row.skinType)
        : _t('cardv2_formula');
    final ringColor = _fitColor(fitScore);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.alternate,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              color: ringColor.withOpacity(0.28),
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.10),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated fit ring — re-animates to the new value on every matrix
            // tap (personalized score), never written to the profile.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ringColor.withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircularPercentIndicator(
                    radius: 40,
                    lineWidth: 8,
                    percent: (fitScore / 100.0).clamp(0.0, 1.0),
                    backgroundColor: ringColor.withOpacity(0.12),
                    progressColor: ringColor,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animateFromLastPercent: true,
                    center: Text(
                      '$fitScore',
                      style: theme.headlineSmall.override(
                        fontFamily: theme.headlineSmallFamily,
                        color: ringColor,
                        fontSize: 24,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts: !theme.headlineSmallIsCustom,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 92,
                  child: Text(
                    fitLabel,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.labelSmall.override(
                      fontFamily: theme.labelSmallFamily,
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.labelSmallIsCustom,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    verdictText,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontSize: 14,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                  _buildHonesty(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Из чего посчитана оценка: доля разобранного состава и уверенность разбора.
  ///
  /// Раньше доля висела пилюлей «73 %» у названия продукта и читалась как
  /// оценка самого средства — вторая цифра рядом с первой. Её место здесь:
  /// это оговорка к числу в кольце, а не свойство крема. Уверенность разбора
  /// переехала сюда же из «Разбора глубже», где её никто не находил.
  Widget _buildHonesty(FlutterFlowTheme theme) {
    final total = widget.image.saIngredientsTotal ?? 0;
    final recognized = widget.image.saIngredientsRecognized ?? 0;
    final level =
        widget.image.saConfidenceLevel ?? '${_confidence['level'] ?? ''}';

    final parts = <String>[
      if (total > 0)
        _t('cardv2_based_on')
            .replaceAll('{percent}', '${(recognized / total * 100).round()}'),
      if (level.isNotEmpty && _t('cardv2_conf_$level').isNotEmpty)
        '${_t('cardv2_confidence_title')}: ${_t('cardv2_conf_$level')}',
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        parts.join(' · '),
        style: theme.labelSmall.override(
          fontFamily: theme.labelSmallFamily,
          color: theme.secondaryText,
          fontSize: 11,
          letterSpacing: 0.0,
          useGoogleFonts: !theme.labelSmallIsCustom,
        ),
      ),
    );
  }

  // ── Skin type matrix (tappable, ephemeral) ───────────────────────────────

  /// Переключатель типа кожи. Ничего, кроме выбора: балл и вердикт уже стоят
  /// в кольце выше, и повторять их строкой значило показывать одну и ту же
  /// оценку дважды. Тап пересчитывает карточку на месте и профиль не трогает —
  /// косметолог так листает типы под каждого клиента.
  static const _skinTypeOrder = [
    'dry',
    'oily',
    'normal',
    'combination',
    'sensitive',
    'acne_prone',
  ];

  Widget _buildFit(FlutterFlowTheme theme) {
    if (widget.skinCompatibility.isEmpty) return const SizedBox.shrink();
    // Порядок постоянный, а не по убыванию балла: иначе чипы прыгали бы с
    // карточки на карточку и свой тип каждый раз приходилось бы искать заново.
    final rows = [...widget.skinCompatibility]..sort((a, b) {
        final ia = _skinTypeOrder.indexOf(a.skinType);
        final ib = _skinTypeOrder.indexOf(b.skinType);
        return (ia < 0 ? 99 : ia).compareTo(ib < 0 ? 99 : ib);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Text(
            _t('cardv2_score_for_type'),
            style: theme.labelMedium.override(
              fontFamily: theme.labelMediumFamily,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.labelMediumIsCustom,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final row in rows) _skinTypeChip(theme, row.skinType),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skinTypeChip(FlutterFlowTheme theme, String skinType) {
    final selected = skinType == _selectedSkinType;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(theme.radii.full),
        onTap: () => setState(() {
          // Эфемерный просмотр: в профиль ничего не пишется.
          _userTouchedMatrix = true;
          _selectedSkinType = selected ? null : skinType;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? theme.primary : theme.surfaceMuted,
            borderRadius: BorderRadius.circular(theme.radii.full),
            border: Border.all(
              color: selected ? theme.primary : theme.border,
              width: selected
                  ? theme.size.borderThick
                  : theme.size.borderHairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded,
                    size: theme.size.iconXs, color: theme.onPrimary),
                const SizedBox(width: 6),
              ],
              Text(
                _skinTypeLabel(skinType),
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: selected ? theme.onPrimary : theme.primaryText,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── "What really works": actives with dose-status traffic light ──────────

  Widget _buildActives(FlutterFlowTheme theme) {
    // Freemium: free users see the first 3 actives; the rest are gated behind
    // the paywall (hidden entirely, not blurred). Pro sees the full list.
    final all = widget.topIngredients;
    final shown = widget.isPro ? all : all.take(3).toList();
    final hiddenCount = all.length - shown.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 8),
          child: Text(
            _t('cardv2_what_works'),
            style: theme.labelMedium.override(
              fontFamily: theme.labelMediumFamily,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.labelMediumIsCustom,
            ),
          ),
        ),
        ...shown.map((ing) {
          final status = ing.status;
          final statusLabel = status == null ? '' : _t('cardv2_status_$status');
          final conc = ing.estimatedConcentration;
          final subtitle = () {
            if (statusLabel.isEmpty) return '';
            // Decorative actives have no meaningful dose — show where they sit
            // in the list instead of an empty/zero concentration.
            if (status == 'decorative') {
              return '$statusLabel · ${_t('cardv2_trace_position')}';
            }
            return conc != null ? '~$conc — $statusLabel' : statusLabel;
          }();
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    statusIcon(status),
                    size: 16,
                    color: statusColor(status),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitle.isEmpty
                            ? ing.ingredientName
                            : '${ing.ingredientName} · $subtitle',
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontSize: 14,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                      if ((ing.description ?? '').isNotEmpty)
                        Text(
                          ing.description!,
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        if (!widget.isPro && hiddenCount > 0)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
            child: InkWell(
              onTap: () {
                unawaited(AnalyticsService.instance.trackUpgradePromptTapped(
                    trigger: 'card_hidden_ingredients'));
                context.pushNamed(PaywallpageWidget.routeName);
              },
              child: Text(
                '+$hiddenCount ${_t('cardv2_more_in_pro')}',
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  fontSize: 14,
                  color: theme.primary,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Pregnancy safety ──────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _pregFlags {
    final raw = widget.image.saPregnancyFlags;
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  String _pregClassLabel(String cls) {
    const keys = {
      'retinoid': 'preg_class_retinoid',
      'hydroquinone': 'preg_class_hydroquinone',
      'arbutin': 'preg_class_arbutin',
      'bha': 'preg_class_bha',
    };
    final key = keys[cls];
    return key != null ? _t(key) : cls;
  }

  /// Product-intrinsic pregnancy verdict (backend knowledge.pregnancy_verdict).
  /// Only a limited set of contraindicated actives is screened — the always-on
  /// methodology block (preg_how_body) states that explicitly, so the badge is
  /// never read as a complete safety guarantee. Hidden until computed (null).
  Widget _buildPregnancy(FlutterFlowTheme theme) {
    final safe = widget.image.saPregnancySafe;
    if (safe == null) return const SizedBox.shrink();
    final flags = _pregFlags;
    final ok = safe && flags.isEmpty;
    // «Можно» показываем только тем, кто спрашивал: в профиле указана
    // беременность или кормление. Предупреждение — всем, кто открыл карточку:
    // человек мог не заполнить профиль, а ретиноид от этого никуда не делся.
    if (ok && !widget.pregnancyRelevant) return const SizedBox.shrink();
    final accent = ok ? _goodColor : _warnColor;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(0.30)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  ok ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                  size: 18,
                  color: accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ok ? _t('preg_safe') : _t('preg_caution'),
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                ),
              ],
            ),
            if (flags.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 6, 0, 0),
                child: Text(
                  '${_t('preg_contains')} '
                  '${flags.map((f) => _pregClassLabel('${f['class']}')).join(', ')}',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
            // Методика — под ссылкой, а не абзацем на девять строк. Она
            // отзывала обратно только что выданный ответ: сначала «можно»,
            // следом мелким шрифтом «но мы проверяем не всё».
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 8, 0, 0),
              child: InkWell(
                onTap: () =>
                    setState(() => _pregHowExpanded = !_pregHowExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _t('preg_how_title'),
                        style: theme.labelSmall.override(
                          fontFamily: theme.labelSmallFamily,
                          color: theme.secondaryText,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.labelSmallIsCustom,
                        ),
                      ),
                      Icon(
                        _pregHowExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 16,
                        color: theme.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_pregHowExpanded)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 2, 0, 0),
                child: Text(
                  _t('preg_how_body'),
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 12,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Warnings with addressees ──────────────────────────────────────────────

  Widget _buildWarnings(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 8),
          child: Text(
            _t('cardv2_watch_out'),
            style: theme.labelMedium.override(
              fontFamily: theme.labelMediumFamily,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.labelMediumIsCustom,
            ),
          ),
        ),
        ..._visibleWarnings.map((issue) {
          final addressees = issue.relevantFor.contains('all')
              ? _t('cardv2_for_all')
              : issue.relevantFor.map(_skinTypeLabel).join(', ');
          // Safety warnings are never paywalled: the ingredient name and its
          // addressees stay visible to everyone. Only the explanatory
          // description is reserved for Pro.
          final showDescription =
              widget.isPro && (issue.description ?? '').isNotEmpty;
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: issue.severity == 'high' ? _badColor : _warnColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${issue.ingredientName}'
                        '${showDescription ? ' — ${issue.description}' : ''}',
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontSize: 14,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                      Text(
                        '${_t('cardv2_matters_for')} $addressees',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Claim audit ───────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _claimAudit {
    final raw = widget.image.saClaimAudit;
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  /// Обещания на упаковке: счёт одной строкой, разбор по пунктам — по тапу.
  ///
  /// Это самый убедительный блок карточки («на коробке написали — проверили»),
  /// но восемь строк прозы его прятали. Счёт «подтверждено 4 из 6» отвечает на
  /// вопрос «врут или нет» до раскрытия.
  Widget _buildClaimAudit(FlutterFlowTheme theme) {
    final supported =
        _claimAudit.where((c) => c['verdict'] == 'supported').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 8),
          child: InkWell(
            onTap: () => setState(() => _claimsExpanded = !_claimsExpanded),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_t('cardv2_claims_title')} · '
                    '${_t('cardv2_claims_count').replaceAll('{n}', '$supported').replaceAll('{total}', '${_claimAudit.length}')}',
                    style: theme.labelMedium.override(
                      fontFamily: theme.labelMediumFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.labelMediumIsCustom,
                    ),
                  ),
                ),
                Icon(
                  _claimsExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.secondaryText,
                ),
              ],
            ),
          ),
        ),
        if (_claimsExpanded)
          ..._claimAudit.map((claim) {
            final claimKey = claim['claim'] as String? ?? '';
            final verdict = claim['verdict'] as String? ?? 'unsupported';
            final claimLabel = () {
              final l = _t('cardv2_claim_$claimKey');
              return l.isEmpty ? claimKey : l;
            }();
            final verdictLabel = _t('cardv2_verdict_$verdict');
            final verdictColor = verdict == 'supported'
                ? _goodColor
                : verdict == 'weak'
                    ? _warnColor
                    : _badColor;
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 3, 16, 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '«$claimLabel»',
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontSize: 14,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ),
                  Text(
                    verdictLabel,
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: verdictColor,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ── Pro layer: 1% line composition, evidence vs MEC, confidence ──────────

  Map<String, dynamic> get _confidence {
    final raw = widget.image.saConfidence;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  /// INCI positions in order. Prefers the backend's pre-parsed array (which
  /// keeps multi-part names like "1,2-Hexanediol" intact); falls back to a
  /// client split that does NOT break on the comma inside "1,2-…"/"2,3-…".
  List<String> get _inciList {
    final stored = widget.image.saInciList;
    if (stored.isNotEmpty) {
      return stored.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return (widget.image.ingredients ?? '')
        .split(RegExp(r',(?!\s*\d)|\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Widget _buildProLayer(FlutterFlowTheme theme) {
    final linePos = widget.image.saOnePercentLinePos;
    final marker = widget.image.saOnePercentLineMarker;
    final inci = _inciList;
    final conf = _confidence;
    final mecRows = widget.topIngredients
        .where((i) => i.status != null || i.mec != null)
        .toList();
    // Issues with no addressees are informational (not skin-type warnings) —
    // surfaced here in the pro layer rather than in the warnings block.
    final infoIssues =
        widget.ingredientIssues.where((i) => i.relevantFor.isEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
          child: InkWell(
            onTap: () => setState(() => _proExpanded = !_proExpanded),
            child: Row(
              children: [
                Text(
                  _t('cardv2_pro_title'),
                  style: theme.labelMedium.override(
                    fontFamily: theme.labelMediumFamily,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts: !theme.labelMediumIsCustom,
                  ),
                ),
                Icon(
                  _proExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.secondaryText,
                ),
              ],
            ),
          ),
        ),
        if (_proExpanded) ...[
          // Composition split at the 1% line
          if (inci.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < inci.length; i++) ...[
                    if (linePos != null && i + 1 == linePos)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                                child: Divider(color: theme.secondaryText)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                marker != null
                                    ? '${_t('cardv2_one_percent_line')} ($marker)'
                                    : _t('cardv2_one_percent_line'),
                                style: theme.bodySmall.override(
                                  fontFamily: theme.bodySmallFamily,
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.bodySmallIsCustom,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(color: theme.secondaryText)),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '${i + 1} · ${inci[i]}',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: linePos != null && i + 1 >= linePos
                              ? theme.secondaryText
                              : theme.primaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Evidence vs MEC
          if (mecRows.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
              child: Text(
                _t('cardv2_evidence_title'),
                style: theme.labelMedium.override(
                  fontFamily: theme.labelMediumFamily,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.labelMediumIsCustom,
                ),
              ),
            ),
            ...mecRows.map((ing) {
              final mecText = ing.mec != null ? '≥ ${ing.mec}%' : '';
              final concText = ing.estimatedConcentration ?? '';
              final statusLabel =
                  ing.status == null ? '' : _t('cardv2_status_${ing.status}');
              return Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        ing.ingredientName,
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    Text(
                      [
                        if (concText.isNotEmpty) '~$concText',
                        if (mecText.isNotEmpty) mecText,
                        if (statusLabel.isNotEmpty) statusLabel,
                      ].join(' · '),
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          // Informational issues (no addressees) — same look as warnings but
          // with an info icon instead of the warning triangle.
          if (infoIssues.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
              child: Text(
                _t('cardv2_informational'),
                style: theme.labelMedium.override(
                  fontFamily: theme.labelMediumFamily,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.labelMediumIsCustom,
                ),
              ),
            ),
            ...infoIssues.map((issue) {
              return Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${issue.ingredientName}'
                        '${(issue.description ?? '').isNotEmpty ? ' — ${issue.description}' : ''}',
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontSize: 14,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          // Honest confidence
          if (conf.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_t('cardv2_confidence_title')}: '
                      '${_t('cardv2_conf_${conf['level'] ?? 'medium'}')}',
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontSize: 13,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                    if (conf['composite_range'] is List &&
                        (conf['composite_range'] as List).length == 2)
                      Text(
                        '${(conf['composite_range'] as List)[0]} – '
                        '${(conf['composite_range'] as List)[1]}',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    if (conf['reasons'] is List)
                      ...((conf['reasons'] as List).map((r) => Text(
                            '· $r',
                            style: theme.bodySmall.override(
                              fontFamily: theme.bodySmallFamily,
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            ),
                          ))),
                  ],
                ),
              ),
            ),
          // Блоки экрана, которым место в подробностях: полный состав, радар
          // оценки, экспертный текст. Здесь они на своём месте — их читают
          // единицы, а в основном потоке они занимали больше тысячи пикселей.
          ...widget.deepExtras,
        ],
      ],
    );
  }
}
