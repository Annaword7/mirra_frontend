import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'markasspam_model.dart';
export 'markasspam_model.dart';

/// Create a popup for item deleting confirmation
class MarkasspamWidget extends StatefulWidget {
  const MarkasspamWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  @override
  State<MarkasspamWidget> createState() => _MarkasspamWidgetState();
}

class _MarkasspamWidgetState extends State<MarkasspamWidget> {
  late MarkasspamModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MarkasspamModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final loc = FFLocalizations.of(context);
    return ConfirmDialog(
      title: loc.getText('tost89il' /* Mark as spam */),
      body: loc.getText('0whnywol' /* This product will be hidden fr... */),
      confirmLabel: loc.getText('899uf23u' /* Hide */),
      cancelLabel: loc.getText('h4qorptg' /* Cancel */),
      onConfirm: () async {
        FFAppState().addToSpamlist(widget.imageid!);
        await UsersTable().update(
          data: {'spam_images': FFAppState().spamlist},
          matchingRows: (rows) => rows.eqOrNull('id', currentUserUid),
        );
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      },
    );
  }
}
