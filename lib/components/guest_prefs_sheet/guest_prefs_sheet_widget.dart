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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appLang = FFLocalizations.of(context).languageCode;
      if (kAppLanguages.any((l) => l.code == appLang) && mounted) {
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
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  String _t(String en, String ru, String es, [String? de]) {
    if (_lang == 'ru') return ru;
    if (_lang == 'es') return es;
    if (_lang == 'de') return de ?? en;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _t('Quick setup', 'Быстрая настройка', 'Configuración rápida',
                'Schnelle Einrichtung'),
            style: theme.headlineMedium.override(
              fontFamily: theme.headlineMediumFamily,
              color: Colors.black,
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
              'Hilf uns, deine Ergebnisse zu personalisieren',
            ),
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: Colors.black,
              fontSize: 13,
              letterSpacing: 0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _t('Interface language', 'Язык интерфейса', 'Idioma de interfaz',
                'Sprache der Benutzeroberfläche'),
            style: theme.labelLarge.override(
              fontFamily: theme.labelLargeFamily,
              color: Colors.black,
              letterSpacing: 0,
              useGoogleFonts: !theme.labelLargeIsCustom,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _lang,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF555555)),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                items: kAppLanguages
                    .map((l) => DropdownMenuItem(
                          value: l.code,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l.flag,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Text(
                                l.nativeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _lang = v ?? _lang),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _t('Your region', 'Ваш регион', 'Tu región', 'Deine Region'),
            style: theme.labelLarge.override(
              fontFamily: theme.labelLargeFamily,
              color: Colors.black,
              letterSpacing: 0,
              useGoogleFonts: !theme.labelLargeIsCustom,
            ),
          ),
          const SizedBox(height: 10),
          // Passes _lang so labels update immediately when the user switches
          // the language dropdown, before the app locale is officially changed.
          CountryselectorWidget(
            languageCode: _lang,
            fillColor: Colors.white,
            textColor: Colors.black,
            iconColor: const Color(0xFF555555),
            textSize: 16,
            borderRadius: 12,
            borderColor: const Color(0xFFE0E0E0),
            borderWidth: 1.5,
            elevation: 0,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                disabledBackgroundColor: theme.primary.withValues(alpha: 0.6),
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
                      _t('Continue', 'Продолжить', 'Continuar', 'Weiter'),
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
