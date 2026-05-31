import 'package:flutter/material.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/countryselector/countryselector_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Bottom sheet shown right after anonymous sign-in to collect country and
/// language preferences before the user's first scan.
///
/// Country selection is delegated to [CountryselectorWidget] which manages its
/// own controller and writes to the DB on change. Language is saved on confirm.
class GuestPrefsSheet extends StatefulWidget {
  const GuestPrefsSheet({super.key});

  @override
  State<GuestPrefsSheet> createState() => _GuestPrefsSheetState();
}

class _GuestPrefsSheetState extends State<GuestPrefsSheet> {
  String _lang = 'en';
  bool _saving = false;

  static const _langs = [
    ('en', '🇺🇸', 'English'),
    ('ru', '🇷🇺', 'Русский'),
    ('es', '🇪🇸', 'Español'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appLang = FFLocalizations.of(context).languageCode;
      if (['en', 'ru', 'es'].contains(appLang) && mounted) {
        setState(() => _lang = appLang);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      setAppLanguage(context, _lang);
      await UsersTable().update(
        data: {'language_code': _lang},
        matchingRows: (rows) => rows.eqOrNull('id', currentUserUid),
      );
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  String _t(String en, String ru, String es) {
    if (_lang == 'ru') return ru;
    if (_lang == 'es') return es;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _t('Quick setup', 'Быстрая настройка', 'Configuración rápida'),
            style: theme.headlineMedium.override(
              fontFamily: theme.headlineMediumFamily,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              useGoogleFonts: !theme.headlineMediumIsCustom,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _t(
              'Help us personalize your results',
              'Поможем персонализировать результаты',
              'Personalicemos tus resultados',
            ),
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              letterSpacing: 0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _t('Interface language', 'Язык интерфейса', 'Idioma de interfaz'),
            style: theme.labelLarge.override(
              fontFamily: theme.labelLargeFamily,
              letterSpacing: 0,
              useGoogleFonts: !theme.labelLargeIsCustom,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _langs.asMap().entries.map((entry) {
              final i = entry.key;
              final (code, flag, label) = entry.value;
              final selected = _lang == code;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _lang = code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? theme.primary : theme.alternate,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                selected ? Colors.white : theme.secondaryText,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            _t('Your region', 'Ваш регион', 'Tu región'),
            style: theme.labelLarge.override(
              fontFamily: theme.labelLargeFamily,
              letterSpacing: 0,
              useGoogleFonts: !theme.labelLargeIsCustom,
            ),
          ),
          const SizedBox(height: 10),
          // Passes _lang so labels update immediately when the user switches
          // language chips, before the app locale is officially changed.
          CountryselectorWidget(languageCode: _lang),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                disabledBackgroundColor:
                    theme.primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _t('Continue', 'Продолжить', 'Continuar'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
