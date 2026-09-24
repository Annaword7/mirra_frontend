import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/confirm_dialog.dart';
import '/domain/care_planning/care_planning_service.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'skin_type_resolver.dart';
import 'onboarding_quiz_model.dart';
export 'onboarding_quiz_model.dart';

/// Онбординг профиля кожи (спека: `docs/onboarding_spec.md` в бэкенде).
///
/// Экран 0 лончер-пути для нового гостя (см. `/` в nav.dart) и он же — правка
/// профиля из Профиля и карточки «Твой профиль».
///
/// Обязательный путь — три вопроса: тип кожи (+ ветка «определим вместе»),
/// особенности (чувствительность и высыпания на одном экране) и цели. Спрашиваем
/// ровно то, что читает расчёт: `skin_type`, `skin_sensitivity`, `acne_prone`,
/// `skin_goals`. Беременность и рамки рутины живут в «Разборе косметички» — они
/// нужны только составителю режима; возраст и бюджет не спрашиваем вовсе, их не
/// читал ни один расчёт.
///
/// Ответы буферизуются в [FFAppState] (до логина) и дописываются в `users`
/// HomeWidget'ом после авторизации; если аккаунт уже есть — пишем сразу здесь.
class OnboardingQuizWidget extends StatefulWidget {
  const OnboardingQuizWidget({super.key, this.returnTo});

  /// Экран, с которого пришли менять профиль: анкету открывают не только на
  /// старте, и после сохранения логично вернуться туда же, а не на Главную.
  /// Это путь (`/itemcard2?imageid=42`), а не имя маршрута: карточка товара
  /// без своего imageid открывается пустой.
  final String? returnTo;

  static String routeName = 'OnboardingQuiz';
  static String routePath = '/onboardingQuiz';

  @override
  State<OnboardingQuizWidget> createState() => _OnboardingQuizWidgetState();
}

enum _Step { welcome, type, determine, traits, goals, result }

// Goal chips → backend goal keys (mirra _VALID_SKIN_GOALS, the shipped 6).
const _goalKeys = <List<String>>[
  ['hydration', 'obq_goal_hydration'],
  ['barrier', 'obq_goal_barrier'],
  ['anti_aging', 'obq_goal_anti_aging'],
  ['pigmentation', 'obq_goal_pigmentation'],
  ['acne', 'obq_goal_acne'],
  ['pores', 'obq_goal_pores'],
];

const _maxGoals = 3;

/// Обязательных вопросов три — столько же делений в прогрессе.
const _questionCount = 3;

class _OnboardingQuizWidgetState extends State<OnboardingQuizWidget> {
  late OnboardingQuizModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Type scale — exactly three sizes across the entire onboarding flow.
  static const double _fsTitle = 26; // large step title
  static const double _fsBody = 16; // primary text / options / buttons
  static const double _fsSub = 13; // secondary / helper text
  // Content is left-aligned with a 16px inset on every step.
  static const EdgeInsets _contentPad = EdgeInsets.fromLTRB(16, 8, 16, 24);

  _Step _step = _Step.welcome;

  /// Направление последнего перехода — только для анимации смены шага.
  bool _forward = true;

  // Answers
  String? _skinType;
  bool? _sensitive;
  bool? _acneProne;
  final List<String> _goals = [];

  // «Не знаю» sub-quiz
  bool _typeViaDetermine = false;
  ShineLevel? _shine;
  TightLevel? _tight;
  PoreLevel? _pores;
  String? get _detResult => (_shine != null && _tight != null && _pores != null)
      ? resolveSkinType(shine: _shine!, tight: _tight!, pores: _pores!)
      : null;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingQuizModel());
    // Повторное прохождение: welcome-шаг («настроим под тебя») не нужен —
    // стартуем сразу с первого вопроса, синхронно, без мигания welcome
    // на время асинхронного префилла.
    if (FFAppState().onboardingDone && currentUserUid.isNotEmpty) {
      _step = _Step.type;
    }
    if (currentUserUid.isNotEmpty) _loadExistingProfile();
  }

  /// Re-entry (from Профиль / карточка «Твой профиль»): prefill answers from the
  /// saved profile so the user edits rather than starts over (spec §5 edge
  /// case 2). Skips the value-sell welcome step when a profile already exists.
  Future<void> _loadExistingProfile() async {
    try {
      final rows = await UsersTable().queryRows(
        queryFn: (q) => q.eqOrNull('id', currentUserUid),
      );
      final row = rows.firstOrNull;
      final st = row?.skinType;
      if (!mounted || row == null || st == null || st.isEmpty) return;
      safeSetState(() {
        _skinType = st;
        _sensitive = row.skinSensitivity;
        _acneProne = row.acneProne;
        _goals
          ..clear()
          ..addAll(row.skinGoals);
        if (_step == _Step.welcome) _step = _Step.type;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  String _typeNameKey(String type) {
    switch (type) {
      case 'dry':
        return 'obq_type_dry';
      case 'oily':
        return 'obq_type_oily';
      case 'combination':
        return 'obq_type_combo';
      default:
        return 'obq_type_normal';
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  void _go(_Step s, {bool forward = true}) => safeSetState(() {
        _forward = forward;
        _step = s;
      });

  void _back() {
    unawaited(AnalyticsService.instance.trackTapBack(from: _step.name));
    switch (_step) {
      case _Step.determine:
        _go(_Step.type, forward: false);
        break;
      case _Step.traits:
        _go(_typeViaDetermine ? _Step.determine : _Step.type, forward: false);
        break;
      case _Step.goals:
        _go(_Step.traits, forward: false);
        break;
      case _Step.result:
        _go(_Step.goals, forward: false);
        break;
      // Шаги без стрелки в шапке: возвращаться некуда.
      case _Step.welcome:
      case _Step.type:
        break;
    }
  }

  Future<void> _finish({required bool save, String? dest}) async {
    final app = FFAppState();
    if (save) {
      if (currentUserUid.isNotEmpty) {
        // Already authenticated (re-edit from settings): write now.
        // Беременность и care_preferences здесь не трогаем — их задают в
        // «Разборе косметички», и повторная анкета не должна их стирать.
        await UsersTable().update(
          data: {
            'skin_type': _skinType,
            'skin_sensitivity': _sensitive,
            'acne_prone': _acneProne,
            'skin_goals': _goals,
            'onboarded': true,
          },
          matchingRows: (rows) => rows.eqOrNull('id', currentUserUid),
        );
        // Анамнез — вход составителя режима: разбор, совместимость и рутина
        // после правки профиля пересчитываются.
        CarePlanningService.instance.invalidateCare();
        app.clearOnboardingBuffer();
      } else {
        // Pre-login: buffer and flush after auth (HomeWidget).
        app.update(() {
          app.obSkinType = _skinType;
          app.obSensitive = _sensitive;
          app.obAcneProne = _acneProne;
          app.obGoals = List<String>.from(_goals);
          app.obPendingFlush = true;
        });
      }
    } else {
      // Skipped: no profile, app runs in "all skin types" mode.
      app.clearOnboardingBuffer();
    }
    app.onboardingDone = true;
    if (!mounted) return;
    // Мостик один для всех выходов: и «Сохранить и сканировать», и «Пропустить»
    // ведут к сканеру — это то, ради чего приложение открывают.
    context.go(dest ?? widget.returnTo ?? TakeorUploadPageWidget.routePath);
  }

  /// ✕ в шапке. Правка профиля (анкету уже проходили) — просто выход без
  /// записи: спрашивать «пропустить настройку?» там нечего, настройка уже была.
  Future<void> _dismiss() async {
    unawaited(AnalyticsService.instance.trackOnboardingClose());
    if (!FFAppState().onboardingDone) {
      await _confirmSkip();
      return;
    }
    HapticFeedback.lightImpact();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(widget.returnTo ?? TakeorUploadPageWidget.routePath);
    }
  }

  Future<void> _confirmSkip() async {
    HapticFeedback.lightImpact();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ConfirmDialog(
        icon: Icons.auto_awesome,
        title: _t('obq_skip_confirm_title'),
        body: _t('obq_skip_confirm_body'),
        // Prominent = остаться в настройке; уход — вторичным действием.
        confirmLabel: _t('obq_skip_confirm_no'),
        onConfirm: () => Navigator.pop(ctx, false),
        cancelLabel: _t('obq_skip_confirm_yes'),
        onCancel: () => Navigator.pop(ctx, true),
        onBackgroundTap: () => Navigator.pop(ctx, false),
      ),
    );
    if (ok == true) {
      unawaited(AnalyticsService.instance.trackOnboardingSkipAll());
      await _finish(save: false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  /// Сколько делений прогресса закрашено. Ветка «определим вместе» держит то же
  /// деление, что и сам вопрос о типе: экранов она не добавляет.
  int get _progressActive {
    switch (_step) {
      case _Step.type:
      case _Step.determine:
        return 1;
      case _Step.traits:
        return 2;
      case _Step.goals:
        return 3;
      case _Step.welcome:
      case _Step.result:
        return 0;
    }
  }

  bool get _canGoBack =>
      _step != _Step.welcome && _step != _Step.type;

  /// ✕ — сквозной выход из настройки. На велкоме его роль играет текстовая
  /// кнопка «Пропустить», на результате выходить уже некуда: оба действия там
  /// завершают анкету.
  bool get _canDismiss => _step != _Step.welcome && _step != _Step.result;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(_forward ? 0.05 : -0.05, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: _contentPad,
                  child: _buildStep(theme),
                ),
              ),
            ),
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: _canGoBack
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        size: theme.size.iconSm, color: theme.primaryText),
                    onPressed: _back,
                  )
                : null,
          ),
          Expanded(
            child: _progressActive == 0
                ? const SizedBox.shrink()
                : Row(
                    children: List.generate(_questionCount, (i) {
                      final active = i < _progressActive;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: active ? theme.primary : theme.surfaceMuted,
                            borderRadius:
                                BorderRadius.circular(theme.radii.r4),
                          ),
                        ),
                      );
                    }),
                  ),
          ),
          SizedBox(
            width: 44,
            child: _canDismiss
                ? IconButton(
                    icon: Icon(Icons.close,
                        size: theme.size.iconMd, color: theme.secondaryText),
                    onPressed: _dismiss,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(FlutterFlowTheme theme) {
    switch (_step) {
      case _Step.welcome:
        return _buildWelcome(theme);
      case _Step.type:
        return _buildType(theme);
      case _Step.determine:
        return _buildDetermine(theme);
      case _Step.traits:
        return _buildTraits(theme);
      case _Step.goals:
        return _buildGoals(theme);
      case _Step.result:
        return _buildResult(theme);
    }
  }

  // ── Shared pieces ───────────────────────────────────────────────────────

  // Title + "why" helper.
  Widget _heading(FlutterFlowTheme theme, String titleKey, String? whyKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_t(titleKey),
            style: theme.headlineSmall.override(
                color: theme.primaryText,
                fontSize: _fsTitle,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                lineHeight: 1.2)),
        if (whyKey != null) ...[
          const SizedBox(height: 8),
          Text(_t(whyKey),
              style: theme.bodyMedium.override(
                  color: theme.secondaryText,
                  fontSize: _fsSub,
                  letterSpacing: 0)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  /// Крупная карточка-вариант: иконка в кружке, заголовок, подпись и галочка у
  /// выбранного. Тап по карточке = выбор (и переход, если шаг одновопросный).
  Widget _optionCard(
    FlutterFlowTheme theme, {
    required String title,
    String? subtitle,
    IconData? icon,
    required bool selected,
    required VoidCallback onTap,
    bool quiet = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(theme.radii.r16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 68),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              // «Тихий» вариант («не знаю») — контурная карточка: он не
              // равноправный ответ, а отвод в под-квиз.
              color: quiet
                  ? Colors.transparent
                  : (selected
                      ? theme.primary.withValues(alpha: theme.opacity.o08)
                      : theme.surfaceMuted),
              borderRadius: BorderRadius.circular(theme.radii.r16),
              border: Border.all(
                color: selected
                    ? theme.primary
                    : (quiet ? theme.border : Colors.transparent),
                width: selected
                    ? theme.size.borderThick
                    : theme.size.borderHairline,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.primary
                          : theme.primary
                              .withValues(alpha: theme.opacity.o08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon,
                        size: theme.size.iconSm,
                        color: selected ? theme.onPrimary : theme.primary),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          style: theme.titleMedium.override(
                              color: theme.primaryText,
                              fontSize: _fsBody,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0)),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: theme.bodySmall.override(
                                color: theme.secondaryText,
                                fontSize: _fsSub,
                                letterSpacing: 0)),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded,
                      size: theme.size.iconMd, color: theme.primary),
                if (quiet)
                  Icon(Icons.chevron_right_rounded,
                      size: theme.size.iconMd, color: theme.secondaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Компактная пара «да/нет» в одну строку: два таких вопроса помещаются на
  /// один экран, ради чего чувствительность и высыпания и слиты вместе.
  /// Только заголовок — строки «зачем» здесь нет: варианты сами всё говорят.
  Widget _binaryQuestion(
    FlutterFlowTheme theme, {
    required String titleKey,
    required String yesKey,
    required String noKey,
    required bool? value,
    required void Function(bool) onPick,
  }) {
    Widget pill(bool option, String labelKey) {
      final selected = value == option;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(theme.radii.r12),
            onTap: () {
              HapticFeedback.lightImpact();
              safeSetState(() => onPick(option));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 52,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: selected ? theme.primary : theme.surfaceMuted,
                borderRadius: BorderRadius.circular(theme.radii.r12),
                border: Border.all(
                  color: selected ? theme.primary : theme.border,
                  width: selected
                      ? theme.size.borderThick
                      : theme.size.borderHairline,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _t(labelKey),
                  maxLines: 1,
                  style: theme.titleSmall.override(
                      color: selected ? theme.onPrimary : theme.primaryText,
                      fontSize: _fsBody,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_t(titleKey),
            style: theme.titleMedium.override(
                color: theme.primaryText,
                fontSize: _fsBody,
                fontWeight: FontWeight.w600,
                letterSpacing: 0)),
        const SizedBox(height: 10),
        Row(children: [
          pill(true, yesKey),
          const SizedBox(width: 10),
          pill(false, noKey),
        ]),
      ],
    );
  }

  /// Чип мультивыбора/одновыбора в едином виде.
  Widget _chip(
    FlutterFlowTheme theme, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool dimmed = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(theme.radii.full),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? theme.primary : theme.surfaceMuted,
            borderRadius: BorderRadius.circular(theme.radii.full),
            border: Border.all(
              color: selected ? theme.primary : theme.border,
              width:
                  selected ? theme.size.borderThick : theme.size.borderHairline,
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
              Text(label,
                  style: theme.bodyMedium.override(
                      color: selected
                          ? theme.onPrimary
                          : (dimmed ? theme.textDisabled : theme.primaryText),
                      fontSize: _fsBody,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0)),
            ],
          ),
        ),
      ),
    );
  }

  void _pickTap(VoidCallback apply) {
    HapticFeedback.lightImpact();
    safeSetState(apply);
  }

  // ── Steps ─────────────────────────────────────────────────────────────

  Widget _buildWelcome(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primary.withValues(alpha: theme.opacity.o16),
                theme.primary.withValues(alpha: theme.opacity.o04),
              ],
            ),
            borderRadius: BorderRadius.circular(theme.radii.r24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration:
                    BoxDecoration(color: theme.primary, shape: BoxShape.circle),
                child: Icon(Icons.auto_awesome,
                    color: theme.onPrimary, size: theme.size.iconLg),
              ),
              const SizedBox(height: 20),
              Text(_t('obq_welcome_title'),
                  style: theme.displaySmall.override(
                      color: theme.primaryText,
                      fontSize: _fsTitle + 2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      lineHeight: 1.2)),
              const SizedBox(height: 12),
              Text(_t('obq_welcome_sub'),
                  style: theme.bodyLarge.override(
                      color: theme.primaryText,
                      fontSize: _fsBody,
                      letterSpacing: 0,
                      lineHeight: 1.4)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: theme.size.iconXs, color: theme.secondaryText),
                  const SizedBox(width: 6),
                  Text(_t('obq_welcome_time'),
                      style: theme.bodySmall.override(
                          color: theme.secondaryText,
                          fontSize: _fsSub,
                          letterSpacing: 0)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildType(FlutterFlowTheme theme) {
    void pick(String t) => _pickTap(() {
          unawaited(AnalyticsService.instance
              .trackOnboardingSkin(typeSkin: t, via: 'direct'));
          _skinType = t;
          _typeViaDetermine = false;
          _forward = true;
          _step = _Step.traits;
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'obq_type_title', null),
        _optionCard(theme,
            title: _t('obq_type_dry'),
            subtitle: _t('obq_type_dry_sub'),
            icon: Icons.water_drop_outlined,
            selected: _skinType == 'dry',
            onTap: () => pick('dry')),
        _optionCard(theme,
            title: _t('obq_type_oily'),
            subtitle: _t('obq_type_oily_sub'),
            icon: Icons.auto_awesome_outlined,
            selected: _skinType == 'oily',
            onTap: () => pick('oily')),
        _optionCard(theme,
            title: _t('obq_type_combo'),
            subtitle: _t('obq_type_combo_sub'),
            icon: Icons.contrast_rounded,
            selected: _skinType == 'combination',
            onTap: () => pick('combination')),
        _optionCard(theme,
            title: _t('obq_type_normal'),
            subtitle: _t('obq_type_normal_sub'),
            icon: Icons.sentiment_satisfied_outlined,
            selected: _skinType == 'normal',
            onTap: () => pick('normal')),
        const SizedBox(height: 4),
        _optionCard(theme,
            title: _t('obq_type_unknown'),
            icon: Icons.help_outline_rounded,
            quiet: true,
            selected: false,
            onTap: () => _pickTap(() {
                  _forward = true;
                  _step = _Step.determine;
                })),
      ],
    );
  }

  Widget _buildDetermine(FlutterFlowTheme theme) {
    Widget miniRow<T>(String labelKey, List<List<dynamic>> opts, T? current,
        void Function(T) onPick) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: Text(_t(labelKey),
                style: theme.titleSmall.override(
                    color: theme.primaryText,
                    fontSize: _fsBody,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opts.map((o) {
              final value = o[0] as T;
              return _chip(theme,
                  label: _t(o[1] as String),
                  selected: current == value,
                  onTap: () => _pickTap(() => onPick(value)));
            }).toList(),
          ),
          const SizedBox(height: 18),
        ],
      );
    }

    final result = _detResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'obq_det_title', 'obq_det_why'),
        miniRow<ShineLevel>(
          'obq_det_q_shine',
          const [
            [ShineLevel.none, 'obq_shine_none'],
            [ShineLevel.tzone, 'obq_shine_tzone'],
            [ShineLevel.all, 'obq_shine_all'],
          ],
          _shine,
          (v) => _shine = v,
        ),
        miniRow<TightLevel>(
          'obq_det_q_tight',
          const [
            [TightLevel.no, 'obq_tight_no'],
            [TightLevel.some, 'obq_tight_some'],
            [TightLevel.strong, 'obq_tight_strong'],
          ],
          _tight,
          (v) => _tight = v,
        ),
        miniRow<PoreLevel>(
          'obq_det_q_pores',
          const [
            [PoreLevel.none, 'obq_pores_none'],
            [PoreLevel.tzone, 'obq_pores_tzone'],
            [PoreLevel.wide, 'obq_pores_wide'],
          ],
          _pores,
          (v) => _pores = v,
        ),
        if (result != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: theme.opacity.o08),
              borderRadius: BorderRadius.circular(theme.radii.r16),
              border: Border.all(
                  color: theme.primary
                      .withValues(alpha: theme.opacity.o24),
                  width: theme.size.borderHairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('obq_det_result'),
                    style: theme.bodySmall.override(
                        color: theme.secondaryText,
                        fontSize: _fsSub,
                        letterSpacing: 0)),
                const SizedBox(height: 4),
                Text(_t(_typeNameKey(result)),
                    style: theme.titleLarge.override(
                        color: theme.primaryText,
                        fontSize: _fsBody + 4,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0)),
                const SizedBox(height: 16),
                AppButton(
                  label: _t('obq_det_confirm'),
                  size: AppButtonSize.md,
                  onPressed: () => _pickTap(() {
                    unawaited(AnalyticsService.instance
                        .trackOnboardingSkin(typeSkin: result, via: 'determine'));
                    _skinType = result;
                    _typeViaDetermine = true;
                    _forward = true;
                    _step = _Step.traits;
                  }),
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: _t('obq_det_change'),
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.md,
                  onPressed: () => _go(_Step.type, forward: false),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Чувствительность + высыпания на одном экране: оба вопроса про то, к чему
  /// расчёт должен быть строже, и оба — в одно касание.
  Widget _buildTraits(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'obq_traits_title', null),
        _binaryQuestion(theme,
            titleKey: 'obq_sens_title',
            yesKey: 'obq_sens_yes_short',
            noKey: 'obq_sens_no_short',
            value: _sensitive,
            onPick: (v) {
              unawaited(AnalyticsService.instance
                  .trackOnboardingSkinNew(typeNew: v));
              _sensitive = v;
            }),
        const SizedBox(height: 28),
        _binaryQuestion(theme,
            titleKey: 'obq_acne_title',
            yesKey: 'obq_acne_yes_short',
            noKey: 'obq_acne_no_short',
            value: _acneProne,
            onPick: (v) {
              unawaited(AnalyticsService.instance
                  .trackOnboardingSkinEruption(typeEruption: v));
              _acneProne = v;
            }),
      ],
    );
  }

  Widget _buildGoals(FlutterFlowTheme theme) {
    void toggle(String key) {
      _pickTap(() {
        if (_goals.contains(key)) {
          _goals.remove(key);
        } else if (_goals.length < _maxGoals) {
          _goals.add(key);
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(_t('obq_goals_max'))));
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'obq_goals_title', 'obq_goals_sub'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _goalKeys.map((g) {
            final selected = _goals.contains(g[0]);
            return _chip(theme,
                label: _t(g[1]),
                selected: selected,
                dimmed: _goals.length >= _maxGoals && !selected,
                onTap: () => toggle(g[0]));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResult(FlutterFlowTheme theme) {
    final parts = <String>[
      if (_skinType != null) _t(_typeNameKey(_skinType!)),
      if (_sensitive == true) _t('obq_flag_sensitive'),
      if (_acneProne == true) _t('obq_flag_acne'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primary.withValues(alpha: theme.opacity.o16),
                theme.primary.withValues(alpha: theme.opacity.o04),
              ],
            ),
            borderRadius: BorderRadius.circular(theme.radii.r24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: theme.primary, size: theme.size.iconMd),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_t('obq_result_title'),
                        style: theme.headlineSmall.override(
                            color: theme.primaryText,
                            fontSize: _fsTitle - 4,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(parts.join(' · '),
                  style: theme.titleMedium.override(
                      color: theme.primaryText,
                      fontSize: _fsBody + 2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0)),
              if (_goals.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_t('obq_result_goals_prefix'),
                    style: theme.bodySmall.override(
                        color: theme.secondaryText,
                        fontSize: _fsSub,
                        letterSpacing: 0)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _goals
                      .map((k) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(theme.radii.full),
                            ),
                            child: Text(
                                _t(_goalKeys
                                    .firstWhere((g) => g[0] == k)[1]),
                                style: theme.bodySmall.override(
                                    color: theme.primaryText,
                                    fontSize: _fsSub,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0)),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: theme.size.iconSm, color: theme.secondaryText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_t('obq_result_bridge'),
                  style: theme.bodyMedium.override(
                      color: theme.secondaryText,
                      fontSize: _fsBody,
                      letterSpacing: 0,
                      lineHeight: 1.4)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Footer (per-step action buttons) ────────────────────────────────────

  Widget _buildFooter(FlutterFlowTheme theme) {
    final children = <Widget>[];
    switch (_step) {
      case _Step.welcome:
        children.add(AppButton(
          label: _t('obq_welcome_start'),
          trailingIcon: Icons.arrow_forward_rounded,
          onPressed: () {
            unawaited(AnalyticsService.instance.trackOnboardingGo());
            _go(_Step.type);
          },
        ));
        children.add(const SizedBox(height: 4));
        children.add(AppButton(
          label: _t('obq_welcome_skip'),
          variant: AppButtonVariant.text,
          size: AppButtonSize.md,
          onPressed: () {
            unawaited(AnalyticsService.instance.trackOnboardingSkip());
            _confirmSkip();
          },
        ));
        break;
      case _Step.traits:
        children.add(AppButton(
          label: _t('obq_next'),
          onPressed: (_sensitive == null || _acneProne == null)
              ? null
              : () {
                  unawaited(AnalyticsService.instance
                      .trackOnboardingSkinContinue(
                          typeNew: _sensitive!, typeEruption: _acneProne!));
                  _go(_Step.goals);
                },
        ));
        break;
      case _Step.goals:
        children.add(AppButton(
          label: _t('obq_next'),
          onPressed: _goals.isEmpty
              ? null
              : () {
                  unawaited(AnalyticsService.instance
                      .trackOnboardingImportantContinue(typeImportant: _goals));
                  _go(_Step.result);
                },
        ));
        children.add(const SizedBox(height: 4));
        children.add(AppButton(
          label: _t('obq_goals_none'),
          variant: AppButtonVariant.text,
          size: AppButtonSize.md,
          onPressed: () {
            unawaited(AnalyticsService.instance.trackOnboardingNoGoal());
            _goals.clear();
            _go(_Step.result);
          },
        ));
        break;
      case _Step.result:
        children.add(AppButton(
          label: _t('obq_result_save'),
          onPressed: () {
            unawaited(AnalyticsService.instance.trackOnboardingDone(
              skinType: _skinType,
              sensitive: _sensitive,
              acneProne: _acneProne,
              goalsCount: _goals.length,
            ));
            _finish(save: true);
          },
        ));
        children.add(const SizedBox(height: 4));
        children.add(AppButton(
          label: _t('obq_result_edit'),
          variant: AppButtonVariant.text,
          size: AppButtonSize.md,
          onPressed: () {
            unawaited(AnalyticsService.instance.trackOnboardingEdit());
            _go(_Step.type, forward: false);
          },
        ));
        break;
      // type / determine advance on tap — no footer button.
      default:
        return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
