import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/confirm_dialog.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'hidenavailability_model.dart';
export 'hidenavailability_model.dart';

class HidenavailabilityWidget extends StatefulWidget {
  const HidenavailabilityWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  @override
  State<HidenavailabilityWidget> createState() =>
      _HidenavailabilityWidgetState();
}

class _HidenavailabilityWidgetState extends State<HidenavailabilityWidget> {
  late HidenavailabilityModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HidenavailabilityModel());
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
      title: loc.getText('bgtz3rm2' /* This feature is available only... */),
      body: loc.getText('0bcivvmz' /* Upgrade to the PRO plan to hid... */),
      confirmLabel: loc.getText('02k9xvmr' /* Go PRO */),
      onBackgroundTap: () => Navigator.pop(context),
      onConfirm: () {
        Navigator.pop(context);
        context.pushNamed(PaywallpageWidget.routeName);
      },
    );
  }
}
