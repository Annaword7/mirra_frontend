import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'makeprivate_model.dart';
export 'makeprivate_model.dart';

class MakeprivateWidget extends StatefulWidget {
  const MakeprivateWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  @override
  State<MakeprivateWidget> createState() => _MakeprivateWidgetState();
}

class _MakeprivateWidgetState extends State<MakeprivateWidget> {
  late MakeprivateModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MakeprivateModel());
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
      title: loc.getText('lfd7kbh4' /* Product hidden */),
      body: loc.getText('wpxs96fj'),
      confirmLabel: loc.getText('k0o8li8u' /* Ok */),
      onConfirm: () => Navigator.pop(context),
    );
  }
}
