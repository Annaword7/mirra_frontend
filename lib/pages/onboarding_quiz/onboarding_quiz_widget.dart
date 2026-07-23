import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_text_field.dart';
import '/design_system/components/app_button.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'skin_type_resolver.dart';
import 'onboarding_quiz_model.dart';
export 'onboarding_quiz_model.dart';

/// Skin-profile onboarding (spec: docs/onboarding_spec.md).
///
/// Single stepper widget covering the 6 spec steps + the «не знаю» sub-quiz.
/// Answers are buffered in [FFAppState] (pre-login) and flushed to `users`
/// after auth by HomeWidget; if the user is already logged in (re-edit from
/// settings) the write happens immediately here.
class OnboardingQuizWidget extends StatefulWidget {
  const OnboardingQuizWidget({super.key});

  static String routeName = 'OnboardingQuiz';
  static String routePath = '/onboardingQuiz';

  @override
  State<OnboardingQuizWidget> createState() => _OnboardingQuizWidgetState();
}

enum _Step {
  welcome,
  type,
  determine,
  sensitivity,
  acne,
  pregnancy,
  goals,
  optional,
  result,
}

// Карта клиента (M1): значения pregnancy_status в users.
const kPregnancyPregnantOrNursing = 'pregnant_or_nursing';
const kPregnancyNone = 'none';
const kPregnancyUndisclosed = 'undisclosed';

// Goal chips → backend goal keys (mirra _VALID_SKIN_GOALS, the shipped 6).
const _goalKeys = <List<String>>[
  ['hydration', 'obq_goal_hydration'],
  ['barrier', 'obq_goal_barrier'],
  ['anti_aging', 'obq_goal_anti_aging'],
  ['pigmentation', 'obq_goal_pigmentation'],
  ['acne', 'obq_goal_acne'],
  ['pores', 'obq_goal_pores'],
];

const _ageOptions = <List<String>>[
  ['under_18', 'obq_age_u18'],
  ['18_24', 'obq_age_18_24'],
  ['25_34', 'obq_age_25_34'],
  ['35_44', 'obq_age_35_44'],
  ['45_54', 'obq_age_45_54'],
  ['55_plus', 'obq_age_55'],
];

const _budgetOptions = <List<String>>[
  ['under_15', 'obq_budget_u15'],
  ['15_40', 'obq_budget_15_40'],
  ['40_80', 'obq_budget_40_80'],
  ['80_plus', 'obq_budget_80'],
];

const _maxGoals = 3;

class _OnboardingQuizWidgetState extends State<OnboardingQuizWidget> {
  late OnboardingQuizModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Onboarding palette: white background, black text, neutral answer cards.
  // Accent (selected state / primary button) still uses the app theme primary.
  static const Color _ink = Color(0xFF1A1A1A); // black-ish text
  static const Color _muted = Color(0xFF6B7280); // secondary text
  static const Color _card = Color(0xFFF3F4F6); // answer background
  static const Color _border = Color(0xFFE6E6E9); // subtle outline

  // Type scale — exactly three sizes across the entire onboarding flow.
  static const double _fsTitle = 24; // large step title
  static const double _fsBody = 16; // primary text / options / buttons
  static const double _fsSub = 13; // secondary / helper text
  // Content is left-aligned with a 16px inset on every step.
  static const EdgeInsets _contentPad = EdgeInsets.fromLTRB(16, 8, 16, 16);

  _Step _step = _Step.welcome;

  // Answers
  String? _skinType;
  bool? _sensitive;
  bool? _acneProne;
  String? _pregnancy;
  final List<String> _goals = [];
  String? _ageRange;
  String? _budgetRange;
  final List<String> _brands = [];

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
    _model.brandsTextController ??= TextEditingController();
    _model.brandsFocusNode ??= FocusNode();
    if (currentUserUid.isNotEmpty) _loadExistingProfile();
  }

  /// Re-entry (from Home / settings): prefill answers from the saved profile so
  /// the user edits rather than starts over (spec §5 edge case 2). Skips the
  /// value-sell welcome step when a profile already exists.
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
        _pregnancy = row.pregnancyStatus;
        _goals
          ..clear()
          ..addAll(row.skinGoals);
        _ageRange = row.ageRange;
        _budgetRange = row.budgetRange;
        _brands
          ..clear()
          ..addAll(row.trustedBrands);
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

  void _go(_Step s) => safeSetState(() => _step = s);

  void _back() {
    switch (_step) {
      case _Step.type:
        _go(_Step.welcome);
        break;
      case _Step.determine:
        _go(_Step.type);
        break;
      case _Step.sensitivity:
        _go(_typeViaDetermine ? _Step.determine : _Step.type);
        break;
      case _Step.acne:
        _go(_Step.sensitivity);
        break;
      case _Step.pregnancy:
        _go(_Step.acne);
        break;
      case _Step.goals:
        _go(_Step.pregnancy);
        break;
      case _Step.optional:
        _go(_Step.goals);
        break;
      case _Step.result:
        _go(_Step.optional);
        break;
      case _Step.welcome:
        break;
    }
  }

  /// Selected brands + any text typed but not yet committed via select/enter.
  List<String> _collectBrands() {
    final pending = _model.brandsTextController?.text.trim() ?? '';
    final out = List<String>.from(_brands);
    if (pending.isNotEmpty &&
        !out.any((b) => b.toLowerCase() == pending.toLowerCase())) {
      out.add(pending);
    }
    return out;
  }

  void _addBrand(String raw) {
    final v = raw.trim();
    safeSetState(() {
      if (v.isNotEmpty &&
          !_brands.any((b) => b.toLowerCase() == v.toLowerCase())) {
        _brands.add(v);
      }
      _model.brandsTextController?.clear();
    });
    _model.brandsFocusNode?.requestFocus();
  }

  Future<List<String>> _brandSuggestions(String query) async {
    try {
      final res = await SupaFlow.client.rpc(
        'search_brands',
        params: {'p_query': query.trim(), 'p_limit': 8},
      );
      final list =
          (res as List).map((e) => (e as Map)['brand'] as String).toList();
      // Drop already-selected brands.
      return list
          .where((b) =>
              !_brands.any((sel) => sel.toLowerCase() == b.toLowerCase()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _finish({required bool save, String? dest}) async {
    final app = FFAppState();
    if (save) {
      final brands = _collectBrands();
      if (currentUserUid.isNotEmpty) {
        // Already authenticated (re-edit from settings): write now.
        await UsersTable().update(
          data: {
            'skin_type': _skinType,
            'skin_sensitivity': _sensitive,
            'acne_prone': _acneProne,
            'pregnancy_status': _pregnancy,
            'skin_goals': _goals,
            'age_range': _ageRange,
            'budget_range': _budgetRange,
            'trusted_brands': brands,
            'onboarded': true,
          },
          matchingRows: (rows) => rows.eqOrNull('id', currentUserUid),
        );
        app.clearOnboardingBuffer();
      } else {
        // Pre-login: buffer and flush after auth (HomeWidget).
        app.update(() {
          app.obSkinType = _skinType;
          app.obSensitive = _sensitive;
          app.obAcneProne = _acneProne;
          app.obPregnancy = _pregnancy;
          app.obGoals = List<String>.from(_goals);
          app.obAgeRange = _ageRange;
          app.obBudgetRange = _budgetRange;
          app.obTrustedBrands = brands;
          app.obPendingFlush = true;
        });
      }
    } else {
      // Skipped: no profile, app runs in "all skin types" mode.
      app.clearOnboardingBuffer();
    }
    app.onboardingDone = true;
    if (!mounted) return;
    context.goNamed(dest ??
        (currentUserUid.isNotEmpty
            ? HomeWidget.routeName
            : PaywallpageWidget.routeName));
  }

  Future<void> _confirmSkip() async {
    final theme = FlutterFlowTheme.of(context);
    final ok = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: _t('obq_skip_confirm_title'),
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.92 + 0.08 * curved.value.clamp(0.0, 1.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.auto_awesome,
                              color: theme.primary, size: 30),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _t('obq_skip_confirm_title'),
                          textAlign: TextAlign.center,
                          style: theme.headlineSmall.override(
                              color: _ink, fontSize: _fsBody,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _t('obq_skip_confirm_body'),
                          textAlign: TextAlign.center,
                          style: theme.bodyMedium
                              .override(color: _ink, fontSize: _fsBody, letterSpacing: 0),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: _t('obq_skip_confirm_no'),
                          onPressed: () => Navigator.pop(ctx, false),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            _t('obq_skip_confirm_yes'),
                            style: theme.bodyMedium.override(
                                color: _ink, fontSize: _fsBody,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (ok == true) await _finish(save: false);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  int get _progressActive {
    switch (_step) {
      case _Step.type:
      case _Step.determine:
        return 1;
      case _Step.sensitivity:
        return 2;
      case _Step.acne:
        return 3;
      case _Step.pregnancy:
        return 4;
      case _Step.goals:
        return 5;
      default:
        return 0;
    }
  }

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
                duration: const Duration(milliseconds: 180),
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
            child: _step == _Step.welcome
                ? null
                : IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        size: 20, color: _ink),
                    onPressed: _back,
                  ),
          ),
          Expanded(
            child: _progressActive == 0
                ? const SizedBox.shrink()
                : Row(
                    children: List.generate(5, (i) {
                      final active = i < _progressActive;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: active ? theme.primary : _card,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
          ),
          SizedBox(
            width: 44,
            child: IconButton(
              icon: Icon(Icons.close, size: 22, color: _muted),
              onPressed: _confirmSkip,
            ),
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
      case _Step.sensitivity:
        return _buildSensitivity(theme);
      case _Step.acne:
        return _buildAcne(theme);
      case _Step.pregnancy:
        return _buildPregnancy(theme);
      case _Step.goals:
        return _buildGoals(theme);
      case _Step.optional:
        return _buildOptional(theme);
      case _Step.result:
        return _buildResult(theme);
    }
  }

  // Title + "why" helper.
  Widget _heading(FlutterFlowTheme theme, String titleKey, String? whyKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_t(titleKey),
            style: theme.headlineSmall.override(
                color: _ink,
                fontSize: _fsTitle,
                fontWeight: FontWeight.w700,
                letterSpacing: 0)),
        if (whyKey != null) ...[
          const SizedBox(height: 8),
          Text(_t(whyKey),
              style: theme.bodyMedium
                  .override(color: _ink, fontSize: _fsSub, letterSpacing: 0)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  // Large selectable card.
  Widget _optionCard(
    FlutterFlowTheme theme, {
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? theme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.titleMedium.override(
                        color: _ink,
                        fontSize: _fsBody,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0)),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.bodySmall.override(
                          color: _ink, fontSize: _fsSub, letterSpacing: 0)),
                ],
              ],
            ),
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
        const SizedBox(height: 32),
        Text(_t('obq_welcome_title'),
            style: theme.displaySmall.override(
                color: _ink,
                fontSize: _fsTitle,
                fontWeight: FontWeight.w700,
                letterSpacing: 0)),
        const SizedBox(height: 16),
        Text(_t('obq_welcome_sub'),
            style: theme.bodyLarge
                .override(color: _ink, fontSize: _fsBody, letterSpacing: 0)),
      ],
    );
  }

  Widget _buildType(FlutterFlowTheme theme) {
    void pick(String t) => _pickTap(() {
          _skinType = t;
          _typeViaDetermine = false;
          _go(_Step.sensitivity);
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'obq_type_title', 'obq_why_type'),
        _optionCard(theme,
            title: _t('obq_type_dry'),
            subtitle: _t('obq_type_dry_sub'),
            selected: _skinType == 'dry',
            onTap: () => pick('dry')),
        _optionCard(theme,
            title: _t('obq_type_oily'),
            subtitle: _t('obq_type_oily_sub'),
            selected: _skinType == 'oily',
            onTap: () => pick('oily')),
        _optionCard(theme,
            title: _t('obq_type_combo'),
            subtitle: _t('obq_type_combo_sub'),
            selected: _skinType == 'combination',
            onTap: () => pick('combination')),
        _optionCard(theme,
            title: _t('obq_type_normal'),
            subtitle: _t('obq_type_normal_sub'),
            selected: _skinType == 'normal',
            onTap: () => pick('normal')),
        const SizedBox(height: 4),
        _optionCard(theme,
            title: _t('obq_type_unknown'),
            selected: false,
            onTap: () => _pickTap(() => _go(_Step.determine))),
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
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(_t(labelKey),
                style: theme.titleSmall.override(color: _ink, fontSize: _fsBody, fontWeight: FontWeight.w600, letterSpacing: 0)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opts.map((o) {
              final value = o[0] as T;
              final selected = current == value;
              return ChoiceChip(
                label: Text(_t(o[1] as String)),
                selected: selected,
                onSelected: (_) => _pickTap(() => onPick(value)),
                showCheckmark: false,
                selectedColor: theme.primary,
                backgroundColor: _card,
                side: BorderSide(
                    color: selected ? theme.primary : _border,
                    width: selected ? 2 : 1),
                labelStyle: theme.bodyMedium.override(
                    color: selected ? Colors.white : _ink, fontSize: _fsBody,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    letterSpacing: 0),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
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
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('obq_det_result'),
                    style: theme.bodySmall.override(
                        color: _ink, fontSize: _fsSub, letterSpacing: 0)),
                const SizedBox(height: 4),
                Text(_t(_typeNameKey(result)),
                    style: theme.titleLarge.override(color: _ink, fontSize: _fsBody, fontWeight: FontWeight.w700, letterSpacing: 0)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: _t('obq_det_confirm'),
                        size: AppButtonSize.md,
                        onPressed: () => _pickTap(() {
                          _skinType = result;
                          _typeViaDetermine = true;
                          _go(_Step.sensitivity);
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: _t('obq_det_change'),
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.md,
                        onPressed: () => _go(_Step.type),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSensitivity(FlutterFlowTheme theme) {
    void pick(bool v) => _pickTap(() {
          _sensitive = v;
          _go(_Step.acne);
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'obq_sens_title', 'obq_sens_why'),
        _optionCard(theme,
            title: _t('obq_sens_yes'),
            selected: _sensitive == true,
            onTap: () => pick(true)),
        _optionCard(theme,
            title: _t('obq_sens_no'),
            selected: _sensitive == false,
            onTap: () => pick(false)),
      ],
    );
  }

  Widget _buildPregnancy(FlutterFlowTheme theme) {
    void pick(String v) => _pickTap(() {
          _pregnancy = v;
          _go(_Step.goals);
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'obq_preg_title', 'obq_preg_why'),
        _optionCard(theme,
            title: _t('obq_preg_yes'),
            selected: _pregnancy == kPregnancyPregnantOrNursing,
            onTap: () => pick(kPregnancyPregnantOrNursing)),
        _optionCard(theme,
            title: _t('obq_preg_no'),
            selected: _pregnancy == kPregnancyNone,
            onTap: () => pick(kPregnancyNone)),
        _optionCard(theme,
            title: _t('obq_preg_skip'),
            selected: _pregnancy == kPregnancyUndisclosed,
            onTap: () => pick(kPregnancyUndisclosed)),
      ],
    );
  }

  Widget _buildAcne(FlutterFlowTheme theme) {
    void pick(bool v) => _pickTap(() {
          _acneProne = v;
          _go(_Step.pregnancy);
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'obq_acne_title', 'obq_acne_why'),
        _optionCard(theme,
            title: _t('obq_acne_yes'),
            selected: _acneProne == true,
            onTap: () => pick(true)),
        _optionCard(theme,
            title: _t('obq_acne_no'),
            selected: _acneProne == false,
            onTap: () => pick(false)),
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
            final atMax = _goals.length >= _maxGoals && !selected;
            return ChoiceChip(
              label: Text(_t(g[1])),
              selected: selected,
              // Keep enabled at the limit so the chip keeps its light bg
              // (a null onSelected would render Material's dark disabledColor);
              // toggle() shows the "хватит трёх" hint instead.
              onSelected: (_) => toggle(g[0]),
              showCheckmark: false,
              selectedColor: theme.primary,
              backgroundColor: _card,
              disabledColor: _card,
              side: BorderSide(
                  color: selected ? theme.primary : _border,
                  width: selected ? 2 : 1),
              labelStyle: theme.bodyMedium.override(
                  color: selected
                      ? Colors.white
                      : (atMax ? _muted : _ink), fontSize: _fsBody,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  letterSpacing: 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptional(FlutterFlowTheme theme) {
    Widget pillRow(List<List<String>> opts, String? current,
        void Function(String?) onPick) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: opts.map((o) {
          final selected = current == o[0];
          return ChoiceChip(
            label: Text(_t(o[1])),
            selected: selected,
            onSelected: (_) =>
                _pickTap(() => onPick(selected ? null : o[0])),
            showCheckmark: false,
            selectedColor: theme.primary,
            backgroundColor: _card,
            side: BorderSide(
                color: selected ? theme.primary : _border,
                width: selected ? 2 : 1),
            labelStyle: theme.bodyMedium.override(
                color: selected ? Colors.white : _ink, fontSize: _fsBody,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0),
          );
        }).toList(),
      );
    }

    Widget field(String labelKey, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t(labelKey),
                  style: theme.titleSmall.override(color: _ink, fontSize: _fsBody, fontWeight: FontWeight.w600, letterSpacing: 0)),
              const SizedBox(height: 10),
              child,
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'obq_opt_title', 'obq_opt_sub'),
        field('obq_opt_age',
            pillRow(_ageOptions, _ageRange, (v) => _ageRange = v)),
        field('obq_opt_budget',
            pillRow(_budgetOptions, _budgetRange, (v) => _budgetRange = v)),
        field('obq_opt_brands', _buildBrandsInput(theme)),
      ],
    );
  }

  // Brands: chips for chosen brands + a DB-backed typeahead to add more.
  Widget _buildBrandsInput(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_brands.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _brands
                  .map((b) => Chip(
                        label: Text(b,
                            style: theme.bodyMedium
                                .override(color: _ink, fontSize: _fsBody, letterSpacing: 0)),
                        backgroundColor: _card,
                        side: BorderSide(color: _border),
                        onDeleted: () =>
                            safeSetState(() => _brands.remove(b)),
                        deleteIconColor: _muted,
                      ))
                  .toList(),
            ),
          ),
        RawAutocomplete<String>(
          textEditingController: _model.brandsTextController,
          focusNode: _model.brandsFocusNode,
          optionsBuilder: (v) async {
            final q = v.text.trim();
            if (q.isEmpty) return const <String>[];
            return _brandSuggestions(q);
          },
          onSelected: _addBrand,
          fieldViewBuilder:
              (context, controller, focusNode, onFieldSubmitted) {
            return AppTextField(
              controller: controller,
              focusNode: focusNode,
              hintText: _t('obq_opt_brands_hint'),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (val) => _addBrand(val),
              suffixIcon: Icon(Icons.add, color: _muted, size: 20),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 220, maxWidth: 360),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (c, i) {
                      final opt = options.elementAt(i);
                      return InkWell(
                        onTap: () => onSelected(opt),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(opt,
                                style: theme.bodyMedium
                                    .override(color: _ink, fontSize: _fsBody, letterSpacing: 0)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
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
    final goalsText =
        _goals.map((k) => _t(_goalKeys.firstWhere((g) => g[0] == k)[1])).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(_t('obq_result_title'),
            style: theme.headlineSmall
                .override(color: _ink, fontSize: _fsTitle, fontWeight: FontWeight.w700, letterSpacing: 0)),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(parts.join(' · '),
                  style: theme.titleMedium.override(color: _ink, fontSize: _fsBody, fontWeight: FontWeight.w700, letterSpacing: 0)),
              if (goalsText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${_t('obq_result_goals_prefix')} $goalsText',
                    style: theme.bodyMedium.override(
                        color: _ink, fontSize: _fsBody, letterSpacing: 0)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(_t('obq_result_bridge'),
            style: theme.bodyMedium
                .override(color: _ink, fontSize: _fsBody, letterSpacing: 0)),
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
          onPressed: () => _go(_Step.type),
        ));
        children.add(const SizedBox(height: 8));
        children.add(TextButton(
          onPressed: _confirmSkip,
          child: Text(_t('obq_welcome_skip'),
              style: theme.bodyMedium
                  .override(color: _ink, fontSize: _fsBody, letterSpacing: 0)),
        ));
        break;
      case _Step.goals:
        children.add(AppButton(
          label: _t('obq_next'),
          onPressed: _goals.isEmpty ? null : () => _go(_Step.optional),
        ));
        children.add(const SizedBox(height: 8));
        children.add(TextButton(
          onPressed: () {
            _goals.clear();
            _go(_Step.optional);
          },
          child: Text(_t('obq_goals_none'),
              style: theme.bodyMedium
                  .override(color: _ink, fontSize: _fsBody, letterSpacing: 0)),
        ));
        break;
      case _Step.optional:
        children.add(AppButton(
          label: _t('obq_done'),
          onPressed: () => _go(_Step.result),
        ));
        children.add(const SizedBox(height: 8));
        children.add(TextButton(
          onPressed: () {
            _ageRange = null;
            _budgetRange = null;
            _brands.clear();
            _model.brandsTextController?.clear();
            _go(_Step.result);
          },
          child: Text(_t('obq_opt_skip_all'),
              style: theme.bodyMedium
                  .override(color: _ink, fontSize: _fsBody, letterSpacing: 0)),
        ));
        break;
      case _Step.result:
        children.add(AppButton(
          label: _t('obq_result_scan'),
          onPressed: () =>
              _finish(save: true, dest: TakeorUploadPageWidget.routeName),
        ));
        children.add(const SizedBox(height: 8));
        children.add(TextButton(
          onPressed: () => _go(_Step.type),
          child: Text(_t('obq_result_edit'),
              style: theme.bodyMedium
                  .override(color: _ink, fontSize: _fsBody, letterSpacing: 0)),
        ));
        break;
      // type / determine / sensitivity / acne advance on tap — no footer button.
      default:
        return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

}
