import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/confirm_dialog.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'deleteitem_model.dart';
export 'deleteitem_model.dart';

/// Create a popup for item deleting confirmation
class DeleteitemWidget extends StatefulWidget {
  const DeleteitemWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  @override
  State<DeleteitemWidget> createState() => _DeleteitemWidgetState();
}

class _DeleteitemWidgetState extends State<DeleteitemWidget> {
  late DeleteitemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeleteitemModel());
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
      title: loc.getText('ww2bynjy'),
      body: loc.getText('ejy0zcsp'),
      confirmLabel: loc.getText('y814btsy'),
      cancelLabel: loc.getText('ood20cri'),
      onConfirm: () async {
        await ImagesTable().delete(
          matchingRows: (rows) => rows.eqOrNull('id', widget.imageid),
        );
        if (context.mounted) {
          context.go(HomeWidget.routePath);
        }
      },
    );
  }
}
