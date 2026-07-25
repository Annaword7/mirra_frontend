import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/feature_row.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'premium_features_list_model.dart';
export 'premium_features_list_model.dart';

class PremiumFeaturesListWidget extends StatefulWidget {
  const PremiumFeaturesListWidget({super.key});

  @override
  State<PremiumFeaturesListWidget> createState() =>
      _PremiumFeaturesListWidgetState();
}

class _PremiumFeaturesListWidgetState extends State<PremiumFeaturesListWidget> {
  late PremiumFeaturesListModel _model;

  // The 8 pro features: (icon, localization key, isFontAwesome, iconSize).
  static const List<({IconData icon, String key, bool fa, double size})>
      _features = [
    (icon: Icons.all_inclusive_rounded, key: 'ic2_pro_unlimited', fa: false, size: 20.0),
    (icon: Icons.biotech_outlined, key: '8xm0tarf', fa: false, size: 20.0),
    (icon: Icons.list_alt_rounded, key: 'inci_full_list', fa: false, size: 20.0),
    (icon: FontAwesomeIcons.eyeSlash, key: 'pm4r9x2w', fa: true, size: 18.0),
    (icon: Icons.lightbulb_outline_rounded, key: 'ic2_pro_howto', fa: false, size: 20.0),
    (icon: Icons.face_retouching_natural, key: 'ic2_pro_skin', fa: false, size: 20.0),
    (icon: Icons.verified_rounded, key: 'ic2_pro_actives', fa: false, size: 20.0),
    (icon: Icons.notes_rounded, key: 'ic2_pro_notes', fa: false, size: 20.0),
  ];

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PremiumFeaturesListModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: _features
            .map((f) => FeatureRow(
                  icon: f.icon,
                  label: FFLocalizations.of(context).getText(f.key),
                  faIcon: f.fa,
                  iconSize: f.size,
                ))
            .toList()
            .divide(const SizedBox(height: 8.0))
            .addToStart(const SizedBox(height: 16.0))
            .addToEnd(const SizedBox(height: 16.0)),
      ),
    );
  }
}
