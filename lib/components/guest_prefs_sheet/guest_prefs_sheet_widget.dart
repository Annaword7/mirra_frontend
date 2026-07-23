import 'dart:async';
import 'package:flutter/material.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/countryselector/countryselector_widget.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/design_system/components/app_button.dart';
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
  int? _countryId;
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
      // Ensure a signed-in user (re-uses the existing anonymous session if the
      // scan flow already created one — see supabase_auth_manager).
      AppStateNotifier.instance.updateNotifyOnAuthChange(false);
      final user = await authManager.signInAnonymously(context);
      if (user == null) return; // sign-in failed — stay on sheet, show error
      unawaited(AnalyticsService.instance.trackAnonSessionStarted());

      setAppLanguage(context, _lang);
      await UsersTable().update(
        data: {
          'language_code': _lang,
          if (_countryId != null) 'country_id': _countryId,
        },
        matchingRows: (rows) => rows.eqOrNull('id', currentUserUid),
      );
    } finally {
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  String _t(Map<String, String> m) => m[_lang] ?? m['en'] ?? '';

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
            _t(const {
              'en': 'Quick setup', 'ru': 'Быстрая настройка',
              'es': 'Configuración rápida', 'de': 'Schnelle Einrichtung',
              'fr': 'Configuration rapide', 'it': 'Configurazione rapida',
              'pt': 'Configuração rápida', 'tr': 'Hızlı kurulum',
              'ja': 'かんたん設定', 'ko': '빠른 설정', 'zh': '快速设置',
            }),
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
            _t(const {
              'en': 'Help us personalize your results',
              'ru': 'Поможем персонализировать результаты',
              'es': 'Personalicemos tus resultados',
              'de': 'Hilf uns, deine Ergebnisse zu personalisieren',
              'fr': 'Aidez-nous à personnaliser vos résultats',
              'it': 'Aiutaci a personalizzare i tuoi risultati',
              'pt': 'Ajude-nos a personalizar os seus resultados',
              'tr': 'Sonuçlarını kişiselleştirmemize yardımcı ol',
              'ja': '結果をパーソナライズしましょう',
              'ko': '결과를 맞춤화할 수 있게 도와주세요',
              'zh': '帮助我们个性化你的结果',
            }),
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
            _t(const {
              'en': 'Interface language', 'ru': 'Язык интерфейса',
              'es': 'Idioma de interfaz', 'de': 'Sprache der Benutzeroberfläche',
              'fr': 'Langue de l’interface', 'it': 'Lingua dell’interfaccia',
              'pt': 'Idioma da interface', 'tr': 'Arayüz dili',
              'ja': '表示言語', 'ko': '인터페이스 언어', 'zh': '界面语言',
            }),
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
            _t(const {
              'en': 'Your region', 'ru': 'Ваш регион', 'es': 'Tu región',
              'de': 'Deine Region', 'fr': 'Ta région', 'it': 'La tua regione',
              'pt': 'A sua região', 'tr': 'Bölgen', 'ja': '地域',
              'ko': '지역', 'zh': '你的地区',
            }),
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
            onCountrySelected: (id) => _countryId = id,
          ),
          const SizedBox(height: 28),
          AppButton(
            label: _t(const {
              'en': 'Continue', 'ru': 'Продолжить',
              'es': 'Continuar', 'de': 'Weiter', 'fr': 'Continuer',
              'it': 'Continua', 'pt': 'Continuar', 'tr': 'Devam et',
              'ja': '続ける', 'ko': '계속', 'zh': '继续',
            }),
            loading: _saving,
            onPressed: () {
              _save();
            },
          ),
        ],
      ),
    );
  }
}
