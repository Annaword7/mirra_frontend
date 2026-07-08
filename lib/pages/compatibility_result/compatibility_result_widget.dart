import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/cosmetic_bag_service.dart';
import '/backend/routine_service.dart';
import '/backend/supabase/database/database.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'compatibility_result_model.dart';

export 'compatibility_result_model.dart';

/// Cosmetologist-style routine analysis over the user's cosmetics bag: an
/// AM/PM routine, conflicts and gaps, personalised to their skin profile.
/// Score + summary + first conflict are free; the routine is a Pro upsell.
class CompatibilityResultWidget extends StatefulWidget {
  const CompatibilityResultWidget({super.key});

  static String routeName = 'CompatibilityResult';
  static String routePath = '/compatibilityResult';

  @override
  State<CompatibilityResultWidget> createState() =>
      _CompatibilityResultWidgetState();
}

class _CompatibilityResultWidgetState extends State<CompatibilityResultWidget> {
  late CompatibilityResultModel _model;

  bool _loading = true;
  bool _error = false;
  String? _errorMsg;
  bool _capped = false; // free user has >3 products → analysed only 3
  Map<String, dynamic> _data = {};

  double? get _score => (_data['score'] as num?)?.toDouble();
  String get _summary => (_data['summary'] ?? '').toString();
  List _conflicts() => (_data['conflicts'] as List?) ?? const [];
  List _am() => (_data['am_routine'] as List?) ?? const [];
  List _pm() => (_data['pm_routine'] as List?) ?? const [];
  List _gaps() => (_data['gaps'] as List?) ?? const [];
  List _tips() => (_data['tips'] as List?) ?? const [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompatibilityResultModel());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCachedOrAnalyze();
    });
  }

  /// Show the cached routine instantly if it still matches the current bag;
  /// otherwise (nothing cached, or the bag changed) recompute.
  Future<void> _loadCachedOrAnalyze() async {
    try {
      final bag = await CosmeticBagTable().querySingleRow(
        queryFn: (q) => q.eqOrNull('user_id', currentUserUid),
      );
      final cached = bag.isNotEmpty ? bag.first.lastResult : null;
      if (cached is Map && cached['score'] != null) {
        final slots = await CosmeticBagService.instance.getSlots();
        final filled =
            slots.map((s) => s.imageId).whereType<int>().toList();
        final expected =
            (FFAppState().isprouser ? filled : filled.take(3).toList()).toSet();
        final analyzed = (cached['analyzed_image_ids'] as List?)
                ?.whereType<num>()
                .map((n) => n.toInt())
                .toSet() ??
            const <int>{};
        final fresh = analyzed.length == expected.length &&
            analyzed.containsAll(expected);
        if (fresh) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _data = cached.cast<String, dynamic>();
          });
          return;
        }
      }
    } catch (_) {}
    await _analyze();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Map<String, dynamic> _skinProfile() {
    final a = FFAppState();
    return <String, dynamic>{
      'skin_type': a.obSkinType,
      'goals': a.obGoals,
      'sensitive': a.obSensitive,
      'acne_prone': a.obAcneProne,
      'age_range': a.obAgeRange,
    }..removeWhere((k, v) => v == null || (v is List && v.isEmpty));
  }

  Future<void> _analyze() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMsg = null;
    });
    final lang = FFLocalizations.of(context).languageCode;
    // Compatibility is free but capped at 3 products; Pro analyses any number.
    final isPro = FFAppState().isprouser;
    try {
      final slots = await CosmeticBagService.instance.getSlots();
      final allIds = slots.map((s) => s.imageId).whereType<int>().toList();
      final ids = isPro ? allIds : allIds.take(3).toList();
      if (ids.length < 2) {
        _fail(FFLocalizations.of(context).getText('cb_compat_need_more'));
        return;
      }
      final resp = await AnalyzeCompatibilityCall.call(
        token: currentJwtToken,
        imageIds: ids,
        languageCode: lang,
        userId: currentUserUid,
        skinProfile: _skinProfile(),
      );
      if (!resp.succeeded) {
        throw Exception('analyze-compatibility failed: ${resp.statusCode}');
      }
      final body = resp.jsonBody;
      final map = body is String
          ? jsonDecode(body) as Map<String, dynamic>
          : (body as Map).cast<String, dynamic>();
      if (map['score'] == null) {
        _fail(FFLocalizations.of(context).getText('cb_compat_no_inci'));
        return;
      }
      // Remember exactly which products were analysed so the bag can flag when
      // its contents drift from the last result.
      map['analyzed_image_ids'] = ids;
      await _cache(map);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _capped = !isPro && allIds.length > 3;
        _data = map;
      });
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, fatal: false, reason: 'routine analyze failed');
      _fail(FFLocalizations.of(context).getText('cb_compat_error'));
    }
  }

  void _fail(String msg) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = true;
      _errorMsg = msg;
    });
  }

  Future<void> _cache(Map<String, dynamic> map) async {
    final userId = currentUserUid;
    if (userId.isEmpty) return;
    await SupaFlow.client.from('cosmetic_bag').upsert({
      'user_id': userId,
      'last_compatibility_score': (map['score'] as num?)?.toDouble(),
      'last_result': map,
      'last_analyzed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  void _openPaywall() {
    HapticFeedback.lightImpact();
    context.pushNamed(PaywallpageWidget.routeName);
  }

  Future<void> _addToCalendar() async {
    HapticFeedback.lightImpact();
    final created = await RoutineService.instance.generateFromRoutine(
      am: _am(),
      pm: _pm(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(FFLocalizations.of(context).getText(
        created > 0 ? 'cb_calendar_added' : 'cb_calendar_none',
      )),
    ));
    if (created > 0) context.pushNamed(RoutineCalendarWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final conflicts = _conflicts();
    final freeConflict = conflicts.isNotEmpty ? conflicts.first : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          FFLocalizations.of(context).getText('cb_compat_title'),
          style: theme.titleMedium.override(
            fontFamily: theme.titleMediumFamily,
            color: Colors.black,
            letterSpacing: 0,
            useGoogleFonts: !theme.titleMediumIsCustom,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.black),
            onPressed: _loading ? null : _analyze,
          ),
        ],
      ),
      body: _loading
          ? _LoadingView()
          : _error
              ? _ErrorView(message: _errorMsg, onRetry: _analyze)
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 12),
                    _ScoreRing(score: _score ?? 0),
                    const SizedBox(height: 20),
                    if (_summary.isNotEmpty)
                      Text(
                        _summary,
                        textAlign: TextAlign.center,
                        style: theme.bodyLarge.override(
                          fontFamily: theme.bodyLargeFamily,
                          color: Colors.black,
                          letterSpacing: 0,
                          useGoogleFonts: !theme.bodyLargeIsCustom,
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (_capped) ...[
                      _CappedHint(theme: theme, onUpgrade: _openPaywall),
                      const SizedBox(height: 16),
                    ],
                    if (freeConflict != null) _ConflictTile(item: freeConflict),
                    const SizedBox(height: 16),
                    ..._proSections(theme),
                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  List<Widget> _proSections(FlutterFlowTheme theme) {
    final conflicts = _conflicts();
    final restConflicts = conflicts.length > 1 ? conflicts.sublist(1) : const [];
    return [
      if (_am().isNotEmpty || _pm().isNotEmpty) ...[
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _addToCalendar,
            icon: const Icon(Icons.calendar_month_rounded, size: 20),
            label: Text(
              FFLocalizations.of(context).getText('cb_add_to_calendar'),
              style: theme.titleSmall.override(
                fontFamily: theme.titleSmallFamily,
                color: Colors.white,
                letterSpacing: 0,
                useGoogleFonts: !theme.titleSmallIsCustom,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
      if (_am().isNotEmpty) ...[
        _SectionTitle(
            FFLocalizations.of(context).getText('cb_sec_am'), Icons.wb_sunny_rounded),
        ..._am().map((s) => _RoutineStep(step: s)),
        const SizedBox(height: 12),
      ],
      if (_pm().isNotEmpty) ...[
        _SectionTitle(FFLocalizations.of(context).getText('cb_sec_pm'),
            Icons.nightlight_round),
        ..._pm().map((s) => _RoutineStep(step: s)),
        const SizedBox(height: 12),
      ],
      if (restConflicts.isNotEmpty) ...[
        _SectionTitle(FFLocalizations.of(context).getText('cb_compat_conflicts'),
            Icons.warning_amber_rounded),
        ...restConflicts.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ConflictTile(item: c),
            )),
      ],
      if (_gaps().isNotEmpty) ...[
        _SectionTitle(FFLocalizations.of(context).getText('cb_sec_gaps'),
            Icons.add_shopping_cart_rounded),
        ..._gaps().map((g) => _GapTile(item: g)),
        const SizedBox(height: 12),
      ],
      if (_tips().isNotEmpty) ...[
        _SectionTitle(
            FFLocalizations.of(context).getText('cb_sec_tips'), Icons.tips_and_updates_rounded),
        ..._tips().map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: Colors.black)),
                  Expanded(
                    child: Text(
                      t.toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            )),
      ],
    ];
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            FFLocalizations.of(context).getText('cb_compat_loading'),
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: Colors.black54,
              letterSpacing: 0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.black54, size: 40),
            const SizedBox(height: 16),
            Text(
              message ?? FFLocalizations.of(context).getText('cb_compat_error'),
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: Colors.black54,
                letterSpacing: 0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(FFLocalizations.of(context).getText('cb_retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.icon);
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: theme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.titleMedium.override(
              fontFamily: theme.titleMediumFamily,
              color: Colors.black,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              useGoogleFonts: !theme.titleMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineStep extends StatelessWidget {
  const _RoutineStep({required this.step});
  final dynamic step;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final m = step is Map ? step as Map : const {};
    final num = m['step']?.toString() ?? '•';
    final action = (m['action'] ?? '').toString();
    final product = (m['product'] ?? '').toString();
    final note = (m['note'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: theme.bodyLarge.override(
                    fontFamily: theme.bodyLargeFamily,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    useGoogleFonts: !theme.bodyLargeIsCustom,
                  ),
                ),
                if (product.isNotEmpty)
                  Text(
                    product,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: theme.primary,
                      letterSpacing: 0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                if (note.isNotEmpty)
                  Text(
                    note,
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: Colors.black54,
                      letterSpacing: 0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
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

class _ConflictTile extends StatelessWidget {
  const _ConflictTile({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final m = item is Map ? item as Map : const {};
    final title = (m['title'] ?? '').toString();
    final detail = (m['detail'] ?? m['warning_message'] ?? '').toString();
    final severity = (m['severity'] ?? 'moderate').toString();
    final color = severity == 'high'
        ? const Color(0xFFD9534F)
        : severity == 'low'
            ? Colors.black54
            : const Color(0xFFE07A5F);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: theme.bodyLarge.override(
                      fontFamily: theme.bodyLargeFamily,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      useGoogleFonts: !theme.bodyLargeIsCustom,
                    ),
                  ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: Colors.black,
                      letterSpacing: 0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
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

class _GapTile extends StatelessWidget {
  const _GapTile({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final m = item is Map ? item as Map : const {};
    final title = (m['title'] ?? '').toString();
    final detail = (m['detail'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.add_circle_outline, color: theme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: theme.bodyLarge.override(
                      fontFamily: theme.bodyLargeFamily,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      useGoogleFonts: !theme.bodyLargeIsCustom,
                    ),
                  ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: Colors.black54,
                      letterSpacing: 0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
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

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final pct = (score / 10).clamp(0.0, 1.0);
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: pct,
                strokeWidth: 10,
                backgroundColor: const Color(0xFFE6E6E6),
                valueColor: AlwaysStoppedAnimation(theme.primary),
              ),
            ),
            Text(
              score.toStringAsFixed(1),
              style: theme.displaySmall.override(
                fontFamily: theme.displaySmallFamily,
                color: Colors.black,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 0,
                useGoogleFonts: !theme.displaySmallIsCustom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Free users get compatibility for the first 3 products; this nudges them to
/// Pro to include all of their products.
class _CappedHint extends StatelessWidget {
  const _CappedHint({required this.theme, required this.onUpgrade});
  final FlutterFlowTheme theme;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onUpgrade,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.primary.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                color: theme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                FFLocalizations.of(context).getText('cb_compat_capped'),
                style: const TextStyle(color: Colors.black, fontSize: 13),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.primary),
          ],
        ),
      ),
    );
  }
}
