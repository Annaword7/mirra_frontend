import '/backend/cosmetic_bag_service.dart';
import '/backend/routine_service.dart';
import '/backend/supabase/database/database.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/cosmetic_bag/cosmetic_bag_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routine_calendar_model.dart';

export 'routine_calendar_model.dart';

/// Pro routine: a weekday slider (defaults to today) showing what to apply in
/// the morning and in the evening, backed by device-local scheduled reminders.
class RoutineCalendarWidget extends StatefulWidget {
  const RoutineCalendarWidget({super.key});

  static String routeName = 'RoutineCalendar';
  static String routePath = '/routineCalendar';

  @override
  State<RoutineCalendarWidget> createState() => _RoutineCalendarWidgetState();
}

class _RoutineCalendarWidgetState extends State<RoutineCalendarWidget> {
  late RoutineCalendarModel _model;

  List<RoutineEventsRow> _events = [];
  Map<int, ImagesRow> _images = {};
  bool _loading = true;
  int _selectedDay = DateTime.now().weekday; // 1=Mon..7=Sun

  List<String> get _weekdayLabels =>
      FFLocalizations.of(context).languageCode.startsWith('ru')
          ? const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
          : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RoutineCalendarModel());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _syncDigests() async {
    final t = FFLocalizations.of(context);
    await RoutineService.instance.syncDigests(
      amTitle: t.getText('cb_push_am_title'),
      amBody: t.getText('cb_push_am_body'),
      pmTitle: t.getText('cb_push_pm_title'),
      pmBody: t.getText('cb_push_pm_body'),
    );
  }

  Future<void> _load() async {
    await _syncDigests();
    final events = await RoutineService.instance.getEvents();
    final ids = events.map((e) => e.imageId).whereType<int>().toSet().toList();
    var images = <int, ImagesRow>{};
    if (ids.isNotEmpty) {
      final rows = await ImagesTable().queryRows(
        queryFn: (q) => q.inFilterOrNull('id', ids),
      );
      images = {for (final r in rows) r.id: r};
    }
    if (!mounted) return;
    setState(() {
      _events = events;
      _images = images;
      _loading = false;
    });
  }

  /// The single time for a part of day (from the earliest product), or null.
  String? _partTime(String part) {
    final list = _forDay(part);
    if (list.isEmpty) return null;
    final earliest =
        list.reduce((a, b) => _minutesOf(a) <= _minutesOf(b) ? a : b);
    final t = (earliest.timeOfDay ?? '').split(':');
    return t.length >= 2 ? '${t[0]}:${t[1]}' : null;
  }

  Future<void> _editPartTime(String part) async {
    HapticFeedback.lightImpact();
    final current = _partTime(part);
    final parts = (current ?? (part == 'am' ? '08:00' : '21:00')).split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? (part == 'am' ? 8 : 21),
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await _pickTimeCupertino(context, initial);
    if (picked == null) return;
    await RoutineService.instance.setPartTime(part, picked.hour, picked.minute);
    if (mounted) _load();
  }

  int _minutesOf(RoutineEventsRow e) {
    final parts = (e.timeOfDay ?? '00:00').split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return h * 60 + m;
  }

  List<RoutineEventsRow> _forDay(String part) {
    final list = _events
        .where((e) =>
            e.weekdays.contains(_selectedDay) && (e.partOfDay ?? 'am') == part)
        .toList();
    // LLM step order first (manual events without one go last), then time,
    // then creation order.
    list.sort((a, b) {
      final ao = a.sortOrder;
      final bo = b.sortOrder;
      if (ao != bo) {
        if (ao == null) return 1;
        if (bo == null) return -1;
        return ao.compareTo(bo);
      }
      final t = _minutesOf(a).compareTo(_minutesOf(b));
      if (t != 0) return t;
      return (a.createdAt ?? DateTime(2000))
          .compareTo(b.createdAt ?? DateTime(2000));
    });
    return list;
  }

  Future<void> _editEvent(RoutineEventsRow e) async {
    HapticFeedback.lightImpact();
    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditReminderSheet(
        event: e,
        image: e.imageId != null ? _images[e.imageId] : null,
        weekdayLabels: _weekdayLabels,
      ),
    );
    if (result == null) return;
    if (result.delete) {
      await RoutineService.instance.deleteEvent(e);
    } else {
      await RoutineService.instance.updateEventDays(e, result.weekdays);
    }
    if (mounted) _load();
  }

  /// The digest push toggle is part-wide: on if any event of the part is
  /// enabled.
  bool _partEnabled(String part) =>
      _events.any((e) => (e.partOfDay ?? 'am') == part && (e.enabled ?? false));

  /// The shared time of a part of day across all events (they share one time),
  /// or the AM/PM default when the part is empty.
  TimeOfDay _partTimeOrDefault(String part) {
    final ev =
        _events.where((e) => (e.partOfDay ?? 'am') == part).toList();
    if (ev.isEmpty) {
      return part == 'am'
          ? const TimeOfDay(hour: 8, minute: 0)
          : const TimeOfDay(hour: 21, minute: 0);
    }
    final earliest =
        ev.reduce((a, b) => _minutesOf(a) <= _minutesOf(b) ? a : b);
    final parts = (earliest.timeOfDay ?? '').split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '') ??
          (part == 'am' ? 8 : 21),
      minute: int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0,
    );
  }

  /// Pick a product from the cosmetic bag and add it to the AM and/or PM
  /// routine for the chosen weekdays.
  Future<void> _addFromBagFlow() async {
    HapticFeedback.lightImpact();
    final slots = await CosmeticBagService.instance.getSlots();
    final ids =
        slots.map((s) => s.imageId).whereType<int>().toSet().toList();
    if (!mounted) return;
    if (ids.isEmpty) {
      // Nothing in the bag yet — send the user there.
      context.pushNamed(CosmeticBagWidget.routeName);
      return;
    }
    final rows = await ImagesTable().queryRows(
      queryFn: (q) => q.inFilterOrNull('id', ids),
    );
    if (!mounted) return;
    final result = await showModalBottomSheet<_BagDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddFromBagSheet(
        products: rows,
        weekdayLabels: _weekdayLabels,
      ),
    );
    if (result == null) return;
    final have = _events.map((e) => '${e.imageId}_${e.partOfDay}').toSet();
    for (final part in [
      if (result.am) 'am',
      if (result.pm) 'pm',
    ]) {
      // Skip parts where this product is already scheduled.
      if (have.contains('${result.imageId}_$part')) continue;
      final time = _partTimeOrDefault(part);
      await RoutineService.instance.addEvent(
        imageId: result.imageId,
        title: result.title,
        weekdays: result.weekdays,
        hour: time.hour,
        minute: time.minute,
        partOfDay: part,
      );
    }
    if (mounted) _load();
  }

  Future<void> _togglePartPush(String part, bool value) async {
    HapticFeedback.lightImpact();
    await RoutineService.instance.setPartEnabled(part, value);
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final showEmpty = !_loading && _events.isEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          FFLocalizations.of(context).getText('cb_routine_title'),
          style: theme.headlineSmall.override(
            fontFamily: theme.headlineSmallFamily,
            color: Colors.black,
            letterSpacing: 0,
            useGoogleFonts: !theme.headlineSmallIsCustom,
          ),
        ),
      ),
      floatingActionButton: showEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _addFromBagFlow,
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(FFLocalizations.of(context)
                  .getText('cb_routine_add_from_bag')),
            ),
      bottomNavigationBar: wrapWithModel(
        model: _model.navbarModel,
        updateCallback: () => safeSetState(() {}),
        child: const NavbarWidget(activePage: 4),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : showEmpty
              ? _EmptyRoutineState(
                  primary: theme.primary,
                  onGoToBag: () =>
                      context.pushNamed(CosmeticBagWidget.routeName),
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
                          _DaySection(
                            title: FFLocalizations.of(context)
                                .getText('cb_sec_am'),
                            icon: Icons.wb_sunny_rounded,
                            events: _forDay('am'),
                            images: _images,
                            sectionTime: _partTime('am'),
                            onEditTime: () => _editPartTime('am'),
                            onEdit: _editEvent,
                            pushEnabled: _partEnabled('am'),
                            onTogglePush: (v) => _togglePartPush('am', v),
                            primary: theme.primary,
                          ),
                          const SizedBox(height: 20),
                          _DaySection(
                            title: FFLocalizations.of(context)
                                .getText('cb_sec_pm'),
                            icon: Icons.nightlight_round,
                            events: _forDay('pm'),
                            images: _images,
                            sectionTime: _partTime('pm'),
                            onEditTime: () => _editPartTime('pm'),
                            onEdit: _editEvent,
                            pushEnabled: _partEnabled('pm'),
                            onTogglePush: (v) => _togglePartPush('pm', v),
                            primary: theme.primary,
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
                width: 40,
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
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Multi-select weekday chip: high-contrast when selected, muted when not.
class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 38,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primary : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFFAEAEAE),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.title,
    required this.icon,
    required this.events,
    required this.images,
    required this.sectionTime,
    required this.onEditTime,
    required this.onEdit,
    required this.pushEnabled,
    required this.onTogglePush,
    required this.primary,
  });
  final String title;
  final IconData icon;
  final List<RoutineEventsRow> events;
  final Map<int, ImagesRow> images;
  final String? sectionTime;
  final VoidCallback onEditTime;
  final Future<void> Function(RoutineEventsRow) onEdit;
  final bool pushEnabled;
  final ValueChanged<bool> onTogglePush;
  final Color primary;

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
            // One time for the whole part of day — tap opens the Apple picker.
            if (sectionTime != null)
              GestureDetector(
                onTap: onEditTime,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, color: primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        sectionTime!,
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        // Push digest on/off for this part of day — one shared reminder, not
        // per product.
        if (sectionTime != null)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => onTogglePush(!pushEnabled),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      pushEnabled
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: pushEnabled ? primary : const Color(0xFFAEAEAE),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      FFLocalizations.of(context)
                          .getText('cb_routine_push_toggle'),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              FFLocalizations.of(context).getText('cb_routine_day_empty'),
              style: const TextStyle(color: Colors.black54),
            ),
          )
        else
          ...events.map((e) {
            final img = e.imageId != null ? images[e.imageId] : null;
            // How-to-apply text comes from the product's own analysis
            // (gpt-4.1), not from the routine LLM.
            final howTo = (img?.saHowToUse ?? '').trim();
            return GestureDetector(
              onTap: () => onEdit(e),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE6E6E6)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // LLM step order badge — manual events have none.
                    if (e.sortOrder != null) ...[
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${e.sortOrder}',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: (img != null && img.imageUrl.isNotEmpty)
                          ? Image.network(img.imageUrl,
                              width: 44, height: 44, fit: BoxFit.cover)
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
                            e.title ?? '—',
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

/// Native-style Apple (Cupertino) time picker in a bottom sheet.
Future<TimeOfDay?> _pickTimeCupertino(
    BuildContext context, TimeOfDay initial) {
  var selected = initial;
  final t = FFLocalizations.of(context);
  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (ctx) => Container(
      height: 300,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(t.getText('cb_cancel')),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx, selected),
                  child: Text(t.getText('cb_done')),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime:
                    DateTime(2020, 1, 1, initial.hour, initial.minute),
                onDateTimeChanged: (dt) =>
                    selected = TimeOfDay(hour: dt.hour, minute: dt.minute),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EditResult {
  _EditResult(this.weekdays, {this.delete = false});
  final List<int> weekdays;
  final bool delete;
}

/// Edit an existing routine event: application weekdays + delete. Shows the
/// LLM how-to-apply text (action/note) when present.
class _EditReminderSheet extends StatefulWidget {
  const _EditReminderSheet({
    required this.event,
    required this.image,
    required this.weekdayLabels,
  });
  final RoutineEventsRow event;
  final ImagesRow? image;
  final List<String> weekdayLabels;

  @override
  State<_EditReminderSheet> createState() => _EditReminderSheetState();
}

class _EditReminderSheetState extends State<_EditReminderSheet> {
  late final Set<int> _days = {...widget.event.weekdays};

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final t = FFLocalizations.of(context);
    final e = widget.event;
    final img = widget.image;
    // How-to-apply text comes from the product's own analysis (gpt-4.1).
    final howTo = (img?.saHowToUse ?? '').trim();
    final canSave = _days.isNotEmpty;
    final isRu = t.languageCode.startsWith('ru');
    const labelStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    );
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
                  child: (img != null && img.imageUrl.isNotEmpty)
                      ? Image.network(img.imageUrl,
                          width: 44, height: 44, fit: BoxFit.cover)
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
                        e.title ?? '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                      if (e.sortOrder != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${t.getText('cb_routine_step')} ${e.sortOrder}',
                              style: TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (howTo.isNotEmpty) ...[
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
                    Text(
                      t.getText('cb_routine_how'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        howTo,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Text(t.getText('cb_routine_days'), style: labelStyle),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20,
                  tooltip: isRu ? 'Все дни' : 'All days',
                  icon: Icon(Icons.select_all_rounded,
                      color: theme.primary, size: 22),
                  onPressed: () => setState(() => _days
                    ..clear()
                    ..addAll(const [1, 2, 3, 4, 5, 6, 7])),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20,
                  tooltip: isRu ? 'Снять все' : 'Clear all',
                  icon: const Icon(Icons.deselect_rounded,
                      color: Color(0xFF9E9E9E), size: 22),
                  onPressed: () => setState(() => _days.clear()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var d = 1; d <= 7; d++)
                  _DayChip(
                    label: widget.weekdayLabels[d - 1],
                    selected: _days.contains(d),
                    primary: theme.primary,
                    onTap: () => setState(() {
                      if (_days.contains(d)) {
                        _days.remove(d);
                      } else {
                        _days.add(d);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: canSave
                    ? () => Navigator.of(context)
                        .pop(_EditResult(_days.toList()))
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  // Disabled: soft tinted fill + muted text (no white-on-grey).
                  disabledBackgroundColor: theme.primary.withValues(alpha: 0.12),
                  disabledForegroundColor: const Color(0xFFB0A6C9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  t.getText('cb_routine_save'),
                  style: TextStyle(
                    color: canSave ? Colors.white : const Color(0xFF9A8FBF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pop(_EditResult(_days.toList(), delete: true)),
              child: Text(
                t.getText('cb_routine_delete'),
                style: const TextStyle(
                  color: Color(0xFFE53935),
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

/// Full-screen empty state: explains the scan → bag → compatibility → routine
/// flow with a CTA to the cosmetic bag.
class _EmptyRoutineState extends StatelessWidget {
  const _EmptyRoutineState({
    required this.primary,
    required this.onGoToBag,
  });
  final Color primary;
  final VoidCallback onGoToBag;

  @override
  Widget build(BuildContext context) {
    final t = FFLocalizations.of(context);
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
                child: Icon(Icons.spa_outlined, color: primary, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                t.getText('cb_routine_empty_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t.getText('cb_routine_empty_body'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onGoToBag,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    t.getText('cb_routine_empty_cta'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BagDraft {
  _BagDraft(this.imageId, this.title, this.am, this.pm, this.weekdays);
  final int imageId;
  final String title;
  final bool am;
  final bool pm;
  final List<int> weekdays;
}

/// Add a cosmetic-bag product to the routine: pick a product, tick Morning
/// and/or Evening, choose the application weekdays.
class _AddFromBagSheet extends StatefulWidget {
  const _AddFromBagSheet({
    required this.products,
    required this.weekdayLabels,
  });
  final List<ImagesRow> products;
  final List<String> weekdayLabels;

  @override
  State<_AddFromBagSheet> createState() => _AddFromBagSheetState();
}

class _AddFromBagSheetState extends State<_AddFromBagSheet> {
  int? _imageId;
  String _title = '';
  bool _am = true;
  bool _pm = true;
  final Set<int> _days = {1, 2, 3, 4, 5, 6, 7}; // all days selected by default

  Widget _partCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color primary,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: value ? primary : const Color(0xFFAEAEAE),
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final t = FFLocalizations.of(context);
    final canSave = _imageId != null && (_am || _pm) && _days.isNotEmpty;
    final isRu = t.languageCode.startsWith('ru');
    const labelStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    );
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
            Text(t.getText('cb_routine_product'), style: labelStyle),
            const SizedBox(height: 8),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final img = widget.products[i];
                  final selected = _imageId == img.id;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _imageId = img.id;
                      _title = img.productName ?? img.brand ?? '';
                    }),
                    child: Container(
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? theme.primary
                              : const Color(0xFFE6E6E6),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      // Clip the image with the inner radius (outer − border)
                      // so square corners never sit over the rounded border.
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(selected ? 10 : 11),
                        child: img.imageUrl.isNotEmpty
                            ? Image.network(img.imageUrl,
                                fit: BoxFit.cover, height: double.infinity)
                            : Container(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _partCheckbox(
                  label: t.getText('cb_sec_am'),
                  value: _am,
                  onChanged: (v) => setState(() => _am = v),
                  primary: theme.primary,
                ),
                const SizedBox(width: 24),
                _partCheckbox(
                  label: t.getText('cb_sec_pm'),
                  value: _pm,
                  onChanged: (v) => setState(() => _pm = v),
                  primary: theme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(t.getText('cb_routine_days'), style: labelStyle),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20,
                  tooltip: isRu ? 'Все дни' : 'All days',
                  icon: Icon(Icons.select_all_rounded,
                      color: theme.primary, size: 22),
                  onPressed: () => setState(() => _days
                    ..clear()
                    ..addAll(const [1, 2, 3, 4, 5, 6, 7])),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20,
                  tooltip: isRu ? 'Снять все' : 'Clear all',
                  icon: const Icon(Icons.deselect_rounded,
                      color: Color(0xFF9E9E9E), size: 22),
                  onPressed: () => setState(() => _days.clear()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var d = 1; d <= 7; d++)
                  _DayChip(
                    label: widget.weekdayLabels[d - 1],
                    selected: _days.contains(d),
                    primary: theme.primary,
                    onTap: () => setState(() {
                      if (_days.contains(d)) {
                        _days.remove(d);
                      } else {
                        _days.add(d);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: canSave
                    ? () => Navigator.of(context).pop(_BagDraft(
                        _imageId!, _title, _am, _pm, _days.toList()))
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  // Disabled: soft tinted fill + muted text (no white-on-grey).
                  disabledBackgroundColor: theme.primary.withValues(alpha: 0.12),
                  disabledForegroundColor: const Color(0xFFB0A6C9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  t.getText('cb_routine_save'),
                  style: TextStyle(
                    color: canSave ? Colors.white : const Color(0xFF9A8FBF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
