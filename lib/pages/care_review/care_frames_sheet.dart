import 'dart:async';

import '/backend/supabase/database/database.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/mirra_bottom_sheet.dart';
import '/domain/client_card/client_card_service.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';

/// «Рамки рутины»: предпочтения состава — без отдушек и максимум шагов.
/// Спрашиваем здесь, а не в онбординге: эти ответы читает только составитель
/// режима, и здесь же видно их последствие — средство вне рамок уходит в
/// очередь, а не в рутину. Беременность переехала в анкету: от неё зависит не
/// порядок шагов, а сам допуск средства.
///
/// Возвращает `true`, если что-то изменили: разбор после этого пересобирают.
class CareFramesSheet extends StatefulWidget {
  const CareFramesSheet({super.key, required this.card});

  /// Текущая карта клиента (строка `users`), или null для анонима без строки.
  final UsersRow? card;

  /// Показывает лист и возвращает `true`, если рамки изменили.
  static Future<bool> show(BuildContext context, UsersRow? card) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CareFramesSheet(card: card),
    );
    return saved == true;
  }

  @override
  State<CareFramesSheet> createState() => _CareFramesSheetState();
}

class _CareFramesSheetState extends State<CareFramesSheet> {
  bool _fragranceFree = false;
  int? _maxSteps;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final prefs =
        (widget.card?.carePreferences as Map?)?.cast<String, dynamic>() ?? {};
    _fragranceFree = prefs['fragrance_free'] == true;
    _maxSteps = prefs['max_steps'] is int ? prefs['max_steps'] as int : null;
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  Future<void> _save() async {
    setState(() => _saving = true);
    unawaited(AnalyticsService.instance.trackCareFramesContinue(
      fragranceFree: _fragranceFree,
      maxSteps: _maxSteps,
    ));
    try {
      await ClientCardService.instance.setPreferences({
        'fragrance_free': _fragranceFree ? true : null,
        'max_steps': _maxSteps,
      });
    } catch (e) {
      debugPrint('care frames save failed: $e');
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return MirraBottomSheet(
      surfaceColor: theme.alternate,
      // Скролл остаётся и после переезда вопроса о беременности: на маленьком
      // экране с увеличенным шрифтом содержимое обязано скроллиться, а не
      // ломаться.
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_t('care_frames_title'),
                  style: theme.headlineSmall.override(
                      color: theme.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0)),
              const SizedBox(height: 8),
              Text(_t('obq_prefs_why'),
                  style: theme.bodySmall.override(
                      color: theme.secondaryText,
                      fontSize: 13,
                      letterSpacing: 0)),
              const SizedBox(height: 24),

              // ── Без отдушек ──
              _toggle(theme),
              const SizedBox(height: 24),

              // ── Максимум шагов ──
              _label(theme, _t('prefs_max_steps')),
              const SizedBox(height: 10),
              Row(children: [
                _stepChip(theme, 3, '3'),
                const SizedBox(width: 8),
                _stepChip(theme, 4, '4'),
                const SizedBox(width: 8),
                _stepChip(theme, 5, '5'),
                const SizedBox(width: 8),
                _stepChip(theme, null, _t('prefs_no_limit'), wide: true),
              ]),
              const SizedBox(height: 28),
              AppButton(
                label: _t('care_save'),
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(FlutterFlowTheme theme, String text) => Text(text,
      style: theme.titleMedium.override(
          color: theme.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0));

  Widget _stepChip(FlutterFlowTheme theme, int? value, String label,
      {bool wide = false}) {
    final selected = _maxSteps == value;
    return Expanded(
      flex: wide ? 2 : 1,
      child: _pill(
        theme,
        label: label,
        selected: selected,
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _maxSteps = value);
        },
      ),
    );
  }

  Widget _pill(
    FlutterFlowTheme theme, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(theme.radii.r12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? theme.primary : theme.surfaceMuted,
            borderRadius: BorderRadius.circular(theme.radii.r12),
            border: Border.all(
              color: selected ? theme.primary : theme.border,
              width:
                  selected ? theme.size.borderThick : theme.size.borderHairline,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                maxLines: 1,
                style: theme.titleSmall.override(
                    color: selected ? theme.onPrimary : theme.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0)),
          ),
        ),
      ),
    );
  }

  Widget _toggle(FlutterFlowTheme theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(theme.radii.r12),
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _fragranceFree = !_fragranceFree);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surfaceMuted,
            borderRadius: BorderRadius.circular(theme.radii.r12),
            border: Border.all(
              color: _fragranceFree ? theme.primary : Colors.transparent,
              width: _fragranceFree
                  ? theme.size.borderThick
                  : theme.size.borderHairline,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: _label(theme, _t('prefs_fragrance_free'))),
              const SizedBox(width: 12),
              Icon(
                _fragranceFree
                    ? LucideIcons.circleCheck
                    : LucideIcons.circle,
                color: _fragranceFree ? theme.primary : theme.border,
                size: theme.size.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
