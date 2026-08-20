import '/design_system/foundations/image_thumb.dart';
import '/design_system/components/screen_loader.dart';
import '/backend/supabase/database/database.dart';
import '/components/navbar/navbar_widget.dart';
import '/design_system/components/app_button.dart';
import '/domain/care_planning/care_planning_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/notification_service.dart';
import '/pages/bag/bag_widget.dart';
import '/pages/care_review/care_review_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// «Моя рутина» (M4, Architecture v1) — календарное ПРЕДСТАВЛЕНИЕ принятого
/// Режима. Дни недели вычисляются проектором на бэкенде из директив (ADR-2);
/// экран их только показывает. Правка дней = команда УточнитьДирективу.
class RoutineWidget extends StatefulWidget {
  const RoutineWidget({super.key});

  static String routeName = 'Routine';
  static String routePath = '/routine';

  @override
  State<RoutineWidget> createState() => _RoutineWidgetState();
}

class _RoutineWidgetState extends State<RoutineWidget> {
  bool _loading = true;
  bool _noRegimen = false;
  Map<String, dynamic> _days = {};
  Map<String, dynamic> _assignments = {};
  List<dynamic> _prescriptions = [];
  Map<int, ImagesRow> _images = {};
  int _selectedDay = DateTime.now().weekday; // 1=Пн..7=Вс

  /// Средства прошлой загрузки: расписание кэшируется в сервисе, а картинки к
  /// нему — здесь, иначе календарь из кэша рисовался бы без миниатюр.
  static Map<int, ImagesRow> _sessionImages = {};

  // Дайджест-напоминания: два локальных пуша (утро/вечер).
  static const int _amBase = 990001;
  static const int _pmBase = 990002;
  static const int _amHour = 8;
  static const int _pmHour = 21;

  @override
  void initState() {
    super.initState();
    // Расписание из этой сессии рисуется сразу: экран пересоздаётся на каждом
    // переключении вкладки, а меняет календарь только команда — и она сама
    // сбрасывает кэш.
    final cached = CarePlanningService.instance.cachedTimetable;
    if (cached != null) {
      if (cached['regimen'] == null) {
        _noRegimen = true;
      } else {
        _apply(cached, _sessionImages);
      }
      _loading = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  /// Раскладывает ответ проектора по полям экрана (без setState — вызывается и
  /// до первого кадра, и из загрузки).
  void _apply(Map<String, dynamic> map, Map<int, ImagesRow> images) {
    _days = (map['days'] as Map?)?.cast<String, dynamic>() ?? {};
    _assignments = (map['assignments'] as Map?)?.cast<String, dynamic>() ?? {};
    _prescriptions = (map['prescriptions'] as List?) ?? [];
    _images = images;
    _noRegimen = false;
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  List<String> get _weekdayLabels {
    final locale = FFLocalizations.of(context).languageCode;
    final fmt = DateFormat.E(locale);
    // 2024-01-01 — понедельник.
    return List.generate(
        7, (i) => fmt.format(DateTime(2024, 1, 1 + i)).replaceAll('.', ''));
  }

  /// [refresh] — после команды, изменившей режим: кэш сессии больше не годится.
  Future<void> _load({bool refresh = false}) async {
    if (!CarePlanningService.instance.hasTimetable || refresh) {
      setState(() => _loading = true);
    }
    try {
      final map =
          await CarePlanningService.instance.timetableCached(refresh: refresh);
      if (map['regimen'] == null) {
        if (mounted) {
          setState(() {
            _loading = false;
            _noRegimen = true;
          });
        }
        return;
      }
      final prescriptions = (map['prescriptions'] as List?) ?? [];
      final ids = prescriptions
          .map((p) => p['image_id'])
          .whereType<int>()
          .toSet()
          .toList();
      // Картинки к тому же расписанию уже загружены — второй раз не ходим.
      var images = _sessionImages;
      if (ids.any((id) => !images.containsKey(id))) {
        final rows = await ImagesTable().queryRows(
          queryFn: (q) => q.inFilterOrNull('id', ids),
        );
        images = {for (final r in rows) r.id: r};
        _sessionImages = images;
      }
      if (!mounted) return;
      setState(() {
        _apply(map, images);
        _loading = false;
      });
      await _syncDigests();
    } catch (e) {
      debugPrint('routine load failed: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _noRegimen = true;
        });
      }
    }
  }

  // ── Дайджесты (Вестник): по одному пушу на сессию в дни, где есть шаги ──

  Future<void> _syncDigests() async {
    final app = FFAppState();
    await NotificationService.instance.cancelReminders(_amBase);
    await NotificationService.instance.cancelReminders(_pmBase);
    Future<void> schedule(String part, int baseId, int hour, bool on) async {
      if (!on) return;
      final days = <int>[
        for (var d = 1; d <= 7; d++)
          if (((_days['$d'] as Map?)?[part] as List?)?.isNotEmpty ?? false) d
      ];
      if (days.isEmpty) return;
      await NotificationService.instance.scheduleWeeklyReminders(
        baseId: baseId,
        weekdays: days,
        hour: hour,
        minute: 0,
        title: _t('cb_push_${part}_title'),
        body: _t('cb_push_${part}_body'),
        payload: 'care',
      );
    }

    await schedule('am', _amBase, _amHour, app.carePushAm);
    await schedule('pm', _pmBase, _pmHour, app.carePushPm);
  }

  Future<void> _togglePush(String part, bool value) async {
    HapticFeedback.lightImpact();
    final app = FFAppState();
    setState(() {
      if (part == 'am') {
        app.carePushAm = value;
      } else {
        app.carePushPm = value;
      }
    });
    await _syncDigests();
  }

  // ── Данные секций ────────────────────────────────────────────────────────

  Map<String, dynamic>? _prescriptionByImage(int imageId) {
    for (final p in _prescriptions) {
      if (p['image_id'] == imageId) return (p as Map).cast<String, dynamic>();
    }
    return null;
  }

  List<int> _sectionItems(String part) =>
      (((_days['$_selectedDay'] as Map?)?[part] as List?) ?? [])
          .whereType<int>()
          .toList();

  Future<void> _openSheet(int imageId) async {
    final pres = _prescriptionByImage(imageId);
    if (pres == null) return;
    HapticFeedback.lightImpact();
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PrescriptionSheet(
        prescription: pres,
        image: _images[imageId],
        currentDays: ((_assignments['$imageId'] as List?) ?? [])
            .whereType<int>()
            .toList(),
        weekdayLabels: _weekdayLabels,
      ),
    );
    // Директиву уточнили — раскладка пересчитана на сервере.
    if (changed == true && mounted) _load(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final app = FFAppState();
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: const NavbarWidget(activePage: 4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _t('care_routine_title'),
          style: theme.headlineSmall.override(
            fontFamily: theme.headlineSmallFamily,
            color: Colors.black,
            letterSpacing: 0,
            useGoogleFonts: !theme.headlineSmallIsCustom,
          ),
        ),
        actions: [
          if (!_loading && !_noRegimen)
            IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.black54),
              onPressed: () =>
                  context.pushNamed(CareReviewWidget.routeName),
            ),
        ],
      ),
      body: _loading
          ? const ScreenLoader(hasAppBar: true, hasBottomNavBar: true)
          : _noRegimen
              ? _EmptyState(
                  primary: theme.primary,
                  title: _t('care_routine_empty_title'),
                  body: _t('care_routine_empty_body'),
                  cta: _t('care_routine_empty_cta'),
                  onTap: () async {
                    await context.pushNamed(BagWidget.routeName);
                    if (mounted) _load();
                  },
                )
              : Column(
                  children: [
                    _DaySelector(
                      labels: _weekdayLabels,
                      selected: _selectedDay,
                      onSelect: (d) => setState(() => _selectedDay = d),
                      primary: theme.primary,
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
                        children: [
                          _Section(
                            title: _t('cb_sec_am'),
                            icon: Icons.wb_sunny_rounded,
                            imageIds: _sectionItems('am'),
                            images: _images,
                            prescriptionOf: _prescriptionByImage,
                            primary: theme.primary,
                            pushOn: app.carePushAm,
                            pushLabel: _t('care_push_toggle'),
                            onTogglePush: (v) => _togglePush('am', v),
                            onTapItem: _openSheet,
                            emptyText: _t('cb_routine_day_empty'),
                            freqTemplate: _t('care_freq_week'),
                          ),
                          const SizedBox(height: 20),
                          _Section(
                            title: _t('cb_sec_pm'),
                            icon: Icons.nightlight_round,
                            imageIds: _sectionItems('pm'),
                            images: _images,
                            prescriptionOf: _prescriptionByImage,
                            primary: theme.primary,
                            pushOn: app.carePushPm,
                            pushLabel: _t('care_push_toggle'),
                            onTogglePush: (v) => _togglePush('pm', v),
                            onTapItem: _openSheet,
                            emptyText: _t('cb_routine_day_empty'),
                            freqTemplate: _t('care_freq_week'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.labels,
    required this.selected,
    required this.onSelect,
    required this.primary,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var d = 1; d <= 7; d++)
            GestureDetector(
              onTap: () => onSelect(d),
              child: Container(
                width: 44,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == d ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected == d ? primary : const Color(0xFFE6E6E6),
                  ),
                ),
                child: Text(
                  labels[d - 1],
                  style: TextStyle(
                    color: selected == d ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.imageIds,
    required this.images,
    required this.prescriptionOf,
    required this.primary,
    required this.pushOn,
    required this.pushLabel,
    required this.onTogglePush,
    required this.onTapItem,
    required this.emptyText,
    required this.freqTemplate,
  });
  final String title;
  final IconData icon;
  final List<int> imageIds;
  final Map<int, ImagesRow> images;
  final Map<String, dynamic>? Function(int) prescriptionOf;
  final Color primary;
  final bool pushOn;
  final String pushLabel;
  final ValueChanged<bool> onTogglePush;
  final void Function(int) onTapItem;
  final String emptyText;
  final String freqTemplate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => onTogglePush(!pushOn),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Icon(
                    pushOn
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_outlined,
                    color: pushOn ? primary : const Color(0xFFAEAEAE),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    pushLabel,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (imageIds.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(emptyText,
                style: const TextStyle(color: Colors.black54)),
          )
        else
          ...imageIds.map((id) {
            final img = images[id];
            final pres = prescriptionOf(id);
            final directive =
                (pres?['directive'] as Map?)?.cast<String, dynamic>() ?? {};
            final days = (directive['days_per_week'] as num?)?.toInt() ?? 7;
            final howTo = (img?.saHowToUse ?? '').trim();
            return GestureDetector(
              onTap: () => onTapItem(id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE6E6E6)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: (img != null && img.imageUrl.isNotEmpty)
                          ? Image(
                              image: thumbProvider(img.imageUrl, width: 200),
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover)
                          : Container(
                              width: 44,
                              height: 44,
                              color: const Color(0xFFF2F2F2),
                              child: const Icon(Icons.spa_outlined,
                                  color: Colors.black38, size: 20),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pres?['title'] ?? img?.productName ?? '—',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (howTo.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                howTo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (days < 7)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          freqTemplate.replaceAll('{n}', '$days'),
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.chevron_right_rounded,
                          color: Colors.black26),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

/// Шит назначения: дни (= команда УточнитьДирективу с pinned_days),
/// «как наносить», пауза/возобновление.
class _PrescriptionSheet extends StatefulWidget {
  const _PrescriptionSheet({
    required this.prescription,
    required this.image,
    required this.currentDays,
    required this.weekdayLabels,
  });
  final Map<String, dynamic> prescription;
  final ImagesRow? image;
  final List<int> currentDays;
  final List<String> weekdayLabels;

  @override
  State<_PrescriptionSheet> createState() => _PrescriptionSheetState();
}

class _PrescriptionSheetState extends State<_PrescriptionSheet> {
  late final Set<int> _days = {...widget.currentDays};
  bool _busy = false;

  String _t(String key) => FFLocalizations.of(context).getText(key);

  Future<void> _save() async {
    setState(() => _busy = true);
    final resp = await CarePlanningService.instance.refineDirective(
      widget.prescription['id'].toString(),
      pinnedDays: _days.toList()..sort(),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (resp.succeeded) {
      Navigator.of(context).pop(true);
    } else {
      final msg = resp.statusCode == 409
          ? _t('care_cap_exceeded')
          : _t('care_error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _toggleSuspend() async {
    final suspended = widget.prescription['status'] == 'suspended';
    setState(() => _busy = true);
    final id = widget.prescription['id'].toString();
    final resp = suspended
        ? await CarePlanningService.instance.resume(id)
        : await CarePlanningService.instance.suspend(id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (resp.succeeded) {
      Navigator.of(context).pop(true);
    } else if (resp.statusCode == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('care_resume_blocked'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final rationale =
        (widget.prescription['rationale'] as Map?)?.cast<String, dynamic>() ??
            {};
    final howTo = (widget.image?.saHowToUse ?? '').trim();
    final suspended = widget.prescription['status'] == 'suspended';
    const labelStyle =
        TextStyle(color: Colors.black, fontWeight: FontWeight.w600);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (widget.image != null &&
                          widget.image!.imageUrl.isNotEmpty)
                      ? Image(
                          image:
                              thumbProvider(widget.image!.imageUrl, width: 200),
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover)
                      : Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFF2F2F2),
                          child: const Icon(Icons.spa_outlined,
                              color: Colors.black38, size: 20),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.prescription['title'] ?? '—',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                  ),
                ),
              ],
            ),
            if (howTo.isNotEmpty || (rationale['summary'] ?? '') != '') ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (howTo.isNotEmpty) ...[
                      Text(_t('care_how'),
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(howTo,
                            style:
                                const TextStyle(color: Colors.black87)),
                      ),
                    ],
                    if ((rationale['summary'] ?? '') != '')
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          rationale['summary'].toString(),
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12.5),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(_t('care_days_label'), style: labelStyle),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var d = 1; d <= 7; d++)
                  GestureDetector(
                    onTap: () => setState(() {
                      if (_days.contains(d)) {
                        _days.remove(d);
                      } else {
                        _days.add(d);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 40,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _days.contains(d)
                            ? theme.primary
                            : const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.weekdayLabels[d - 1],
                        style: TextStyle(
                          color: _days.contains(d)
                              ? Colors.white
                              : const Color(0xFFAEAEAE),
                          fontWeight: _days.contains(d)
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AppButton(
              label: _t('care_save'),
              loading: _busy,
              enabled: _days.isNotEmpty && !_busy,
              onPressed: _save,
            ),
            TextButton(
              onPressed: _busy ? null : _toggleSuspend,
              child: Text(
                suspended ? _t('care_resume') : _t('care_suspend'),
                style: TextStyle(
                  color: suspended
                      ? theme.primary
                      : const Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.primary,
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });
  final Color primary;
  final String title;
  final String body;
  final String cta;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.auto_awesome_rounded, color: primary, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              AppButton(label: cta, onPressed: onTap),
            ],
          ),
        ),
      ),
    );
  }
}
