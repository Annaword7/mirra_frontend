import '/backend/cosmetic_bag_service.dart';
import '/backend/routine_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Home "try all features" checklist: 3 steps that light up as the user
/// completes them. Hides for good once all three are done.
class HomePipelineWidget extends StatefulWidget {
  const HomePipelineWidget({super.key});

  @override
  State<HomePipelineWidget> createState() => _HomePipelineWidgetState();
}

class _HomePipelineWidgetState extends State<HomePipelineWidget> {
  bool _loading = true;
  bool _step1 = false;
  bool _step2 = false;
  bool _step3 = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final step1 = FFAppState().onboardingDone;
    var step2 = false;
    var step3 = false;
    try {
      final slots = await CosmeticBagService.instance.getSlots();
      step2 = slots.where((s) => s.imageId != null).length >= 3;
      final events = await RoutineService.instance.getEvents();
      step3 = events.isNotEmpty;
    } catch (_) {}
    if (step1 && step2 && step3) {
      FFAppState().homePipelineDone = true;
    }
    if (!mounted) return;
    setState(() {
      _step1 = step1;
      _step2 = step2;
      _step3 = step3;
      _loading = false;
    });
  }

  Future<void> _go(String routeName) async {
    HapticFeedback.lightImpact();
    await context.pushNamed(routeName);
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (FFAppState().homePipelineDone || _loading) {
      return const SizedBox.shrink();
    }
    final theme = FlutterFlowTheme.of(context);
    final isPro = context.watch<FFAppState>().isprouser;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FFLocalizations.of(context).getText('hp_title'),
              style: theme.titleMedium.override(
                fontFamily: theme.titleMediumFamily,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                useGoogleFonts: !theme.titleMediumIsCustom,
              ),
            ),
            const SizedBox(height: 12),
            _StepRow(
              index: 1,
              done: _step1,
              label: FFLocalizations.of(context).getText('hp_step1'),
              primary: theme.primary,
              onTap: () => _go(OnboardingQuizWidget.routeName),
            ),
            _StepRow(
              index: 2,
              done: _step2,
              label: FFLocalizations.of(context).getText('hp_step2'),
              primary: theme.primary,
              onTap: () => _go(CosmeticBagWidget.routeName),
            ),
            _StepRow(
              index: 3,
              done: _step3,
              label: FFLocalizations.of(context).getText('hp_step3'),
              primary: theme.primary,
              onTap: () => _go(isPro
                  ? RoutineCalendarWidget.routeName
                  : PaywallpageWidget.routeName),
              last: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.done,
    required this.label,
    required this.primary,
    required this.onTap,
    this.last = false,
  });
  final int index;
  final bool done;
  final String label;
  final Color primary;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.only(top: 6, bottom: last ? 0 : 6),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? primary : Colors.white,
                border: Border.all(color: primary, width: 1.5),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : Text(
                      '$index',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: done ? Colors.black54 : Colors.black,
                  fontWeight: FontWeight.w500,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (!done)
              const Icon(Icons.chevron_right_rounded, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
