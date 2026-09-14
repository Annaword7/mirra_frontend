import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/design_system/components/confirm_dialog.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'delete_confirmation_model.dart';
export 'delete_confirmation_model.dart';

class DeleteConfirmationWidget extends StatefulWidget {
  const DeleteConfirmationWidget({super.key});

  @override
  State<DeleteConfirmationWidget> createState() =>
      _DeleteConfirmationWidgetState();
}

class _DeleteConfirmationWidgetState extends State<DeleteConfirmationWidget> {
  late DeleteConfirmationModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeleteConfirmationModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = FFLocalizations.of(context);
    return ConfirmDialog(
      icon: Icons.delete_outline_rounded,
      iconColor: const Color(0xFFD32F2F),
      destructive: true,
      surfaceColor: FlutterFlowTheme.of(context).alternate,
      title: loc.getText(
        '4latue44' /* Are you sure you want to delet... */,
      ),
      body: loc.getText(
        '9fm4u5g5' /* Any products you’ve added will... */,
      ),
      // The short shared label — 'Delete account' overflows a half-width button.
      confirmLabel: loc.getText(
        'y814btsy' /* Yes, delete */,
      ),
      cancelLabel: loc.getText(
        '9lehmzbk' /* Cancel */,
      ),
      onCancel: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      onConfirm: () async {
        HapticFeedback.lightImpact();
        // Роутер берём до await'ов: после signOut и закрытия листа этот
        // context уже не годится для навигации.
        final router = GoRouter.of(context);
        _model.deleteuseranswer = await DeleteUserNEWBCNDCall.call(
          host: FFDevEnvironmentValues().backendhost,
          userId: currentUserUid,
          token: currentJwtToken,
          analyticsId: AnalyticsService.instance.analyticsUserId,
        );

        if ((_model.deleteuseranswer?.succeeded ?? true)) {
          // Бэкенд уже получил analytics_id и запустил удаление профиля в
          // Amplitude; здесь — вторая половина: новая идентичность, чтобы
          // следующий аноним не пришился к истории удалённого.
          await AnalyticsService.instance.forgetUser();
          FFAppState().isprouser = false;
          FFAppState().analysesused = 0;
          // Удаление аккаунта — тот же «первый запуск», что и выход: тем же
          // набором флагов возвращаем онбординг, разовое предложение и счётчик
          // сканов для просьбы об отзыве (см. ветку «Выйти» в Профиле).
          FFAppState().onboardingDone = false;
          // Незалитый буфер анкеты иначе достался бы следующему гостю.
          FFAppState().clearOnboardingBuffer();
          FFAppState().softPaywallShown = false;
          FFAppState().successfulScans = 0;
          FFAppState().saveProPromptShown = false;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('hint_upload_seen');
          await prefs.remove('pro_preview_used');
          await revenue_cat.login(null);
          router.prepareAuthEvent();
          await authManager.signOut();
          router.clearRedirectLocation();

          // Как и «Выйти»: закрываем лист и уходим на '/', где свежего гостя
          // встречает онбординг. Раньше здесь был экран Newblank — онбординг
          // после удаления аккаунта не показывался вовсе.
          if (context.mounted) Navigator.pop(context);
          router.go('/');
        } else {
          await showDialog(
            context: context,
            builder: (alertDialogContext) {
              return AlertDialog(
                title: Text('ups!'),
                content: Text('something went wrong!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext),
                    child: Text('Ok'),
                  ),
                ],
              );
            },
          );
        }

        safeSetState(() {});
      },
    );
  }
}
