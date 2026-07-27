import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/confirm_dialog.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'copyitem_model.dart';
export 'copyitem_model.dart';

class CopyitemWidget extends StatefulWidget {
  const CopyitemWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  @override
  State<CopyitemWidget> createState() => _CopyitemWidgetState();
}

class _CopyitemWidgetState extends State<CopyitemWidget> {
  late CopyitemModel _model;
  bool _isLoading = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CopyitemModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _copy() async {
    safeSetState(() => _isLoading = true);
    try {
      _model.copiedimage = await CopyproductNEWBCNDCall.call(
        host: FFDevEnvironmentValues().backendhost,
        sourceImageId: widget.imageid,
        targetUserId: currentUserUid,
        token: currentJwtToken,
      );

      final newId = CopyproductNEWBCNDCall.newimageid(
        _model.copiedimage?.jsonBody ?? '',
      );

      debugPrint('[CopyProduct] response: ${_model.copiedimage?.jsonBody}');
      debugPrint('[CopyProduct] new_image_id: $newId');

      if (!context.mounted) return;
      Navigator.pop(context);

      if (newId != null) {
        context.pushNamed(
          Itemcard2Widget.routeName,
          queryParameters: {
            'imageid': serializeParam(newId, ParamType.int),
          },
        );
      } else {
        debugPrint(
            '[CopyProduct] ERROR: new_image_id is null, cannot navigate');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(FFLocalizations.of(context).getText('copy_failed')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) safeSetState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = FFLocalizations.of(context);
    return ConfirmDialog(
      title: loc.getText('yj35oi8u' /* Copy Item */),
      body: loc.getText('p2cdk61c' /* Are you sure you want to copy ... */),
      confirmLabel: loc.getText('noj51h6l' /* Copy */),
      cancelLabel: loc.getText('5gas3j6n' /* Cancel */),
      confirmLoading: _isLoading,
      onConfirm: _copy,
    );
  }
}
