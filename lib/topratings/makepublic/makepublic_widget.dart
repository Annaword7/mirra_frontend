import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'makepublic_model.dart';
export 'makepublic_model.dart';

class MakepublicWidget extends StatefulWidget {
  const MakepublicWidget({super.key});

  @override
  State<MakepublicWidget> createState() => _MakepublicWidgetState();
}

class _MakepublicWidgetState extends State<MakepublicWidget> {
  late MakepublicModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MakepublicModel());
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
      title: loc.getText('553khwzz'),
      body: loc.getText('g7bez9em'),
      confirmLabel: loc.getText('dv0imp11'),
      onConfirm: () => Navigator.pop(context),
    );
  }
}
