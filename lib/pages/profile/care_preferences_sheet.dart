import '/design_system/components/app_button.dart';
import '/domain/client_card/client_card_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// «Предпочтения ухода» (Карта клиента, M1/M3): рамки приемлемости рутины.
/// Предпочтения соблюдаются составителем режима всегда (инвариант 11) —
/// продукты вне рамок уходят в очередь введения, а не в рутину.
class CarePreferencesSheet extends StatefulWidget {
  const CarePreferencesSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const CarePreferencesSheet(),
      );

  @override
  State<CarePreferencesSheet> createState() => _CarePreferencesSheetState();
}

class _CarePreferencesSheetState extends State<CarePreferencesSheet> {
  bool _loading = true;
  bool _fragranceFree = false;
  int? _maxSteps; // null = без лимита

  static const _stepOptions = [3, 4, 5, null];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  Future<void> _load() async {
    final card = await ClientCardService.instance.getCard();
    final prefs = (card?.carePreferences as Map?)?.cast<String, dynamic>() ?? {};
    if (!mounted) return;
    setState(() {
      _fragranceFree = prefs['fragrance_free'] == true;
      final ms = prefs['max_steps'];
      _maxSteps = ms is int && _stepOptions.contains(ms) ? ms : null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await ClientCardService.instance.setPreferences({
      'fragrance_free': _fragranceFree ? true : null,
      'max_steps': _maxSteps,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_t('prefs_saved'))));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    const labelStyle =
        TextStyle(color: Colors.black, fontWeight: FontWeight.w600);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _loading
            ? const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _t('prefs_title'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _t('prefs_subtitle'),
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: theme.primary,
                    title: Text(_t('prefs_fragrance_free'), style: labelStyle),
                    subtitle: Text(
                      _t('prefs_fragrance_free_sub'),
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 12.5),
                    ),
                    value: _fragranceFree,
                    onChanged: (v) => setState(() => _fragranceFree = v),
                  ),
                  const SizedBox(height: 12),
                  Text(_t('prefs_max_steps'), style: labelStyle),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final opt in _stepOptions) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _maxSteps = opt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _maxSteps == opt
                                    ? theme.primary
                                    : const Color(0xFFF4F4F4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                opt == null ? _t('prefs_no_limit') : '$opt',
                                style: TextStyle(
                                  color: _maxSteps == opt
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (opt != _stepOptions.last) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(label: _t('care_save'), onPressed: _save),
                ],
              ),
      ),
    );
  }
}
