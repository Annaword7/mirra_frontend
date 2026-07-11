import '/auth/supabase_auth/auth_util.dart';
import '/backend/routine_service.dart';
import '/backend/supabase/database/database.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
    final t = (list.first.timeOfDay ?? '').split(':');
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
    list.sort((a, b) => _minutesOf(a).compareTo(_minutesOf(b)));
    return list;
  }

  Future<void> _delete(RoutineEventsRow e) async {
    await RoutineService.instance.deleteEvent(e);
    if (mounted) _load();
  }

  Future<void> _addFlow() async {
    HapticFeedback.lightImpact();
    final scans = await ImagesTable().queryRows(
      queryFn: (q) =>
          q.eqOrNull('user', currentUserUid).order('id', ascending: false),
      limit: 50,
    );
    if (!mounted) return;
    final result = await showModalBottomSheet<_RoutineDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddReminderSheet(
        scans: scans,
        weekdayLabels: _weekdayLabels,
      ),
    );
    if (result == null) return;
    await RoutineService.instance.addEvent(
      imageId: result.imageId,
      title: result.title,
      weekdays: result.weekdays,
      hour: result.time.hour,
      minute: result.time.minute,
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFlow,
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(FFLocalizations.of(context).getText('cb_routine_add')),
      ),
      bottomNavigationBar: wrapWithModel(
        model: _model.navbarModel,
        updateCallback: () => safeSetState(() {}),
        child: const NavbarWidget(activePage: 4),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
                        title: FFLocalizations.of(context).getText('cb_sec_am'),
                        icon: Icons.wb_sunny_rounded,
                        events: _forDay('am'),
                        images: _images,
                        sectionTime: _partTime('am'),
                        onEditTime: () => _editPartTime('am'),
                        onDelete: _delete,
                        primary: theme.primary,
                      ),
                      const SizedBox(height: 20),
                      _DaySection(
                        title: FFLocalizations.of(context).getText('cb_sec_pm'),
                        icon: Icons.nightlight_round,
                        events: _forDay('pm'),
                        images: _images,
                        sectionTime: _partTime('pm'),
                        onEditTime: () => _editPartTime('pm'),
                        onDelete: _delete,
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
    required this.onDelete,
    required this.primary,
  });
  final String title;
  final IconData icon;
  final List<RoutineEventsRow> events;
  final Map<int, ImagesRow> images;
  final String? sectionTime;
  final VoidCallback onEditTime;
  final Future<void> Function(RoutineEventsRow) onDelete;
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
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6E6E6)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
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
                    child: Text(
                      e.title ?? '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, color: Colors.black54),
                    onPressed: () => onDelete(e),
                  ),
                ],
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

class _RoutineDraft {
  _RoutineDraft(this.imageId, this.title, this.weekdays, this.time);
  final int? imageId;
  final String title;
  final List<int> weekdays;
  final TimeOfDay time;
}

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet({
    required this.scans,
    required this.weekdayLabels,
  });
  final List<ImagesRow> scans;
  final List<String> weekdayLabels;

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  int? _imageId;
  String _title = '';
  final Set<int> _days = {1, 2, 3, 4, 5, 6, 7}; // all days selected by default
  TimeOfDay _time = const TimeOfDay(hour: 21, minute: 0);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final canSave = _title.trim().isNotEmpty && _days.isNotEmpty;
    final isRu = FFLocalizations.of(context).languageCode.startsWith('ru');
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
            Text(FFLocalizations.of(context).getText('cb_routine_product'),
                style: labelStyle),
            const SizedBox(height: 8),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.scans.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final img = widget.scans[i];
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
                Text(FFLocalizations.of(context).getText('cb_routine_days'),
                    style: labelStyle),
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
            Row(
              children: [
                Text(FFLocalizations.of(context).getText('cb_routine_time'),
                    style: labelStyle),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final picked = await _pickTimeCupertino(context, _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Text(
                    _time.format(context),
                    style: TextStyle(
                      color: theme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: canSave
                    ? () => Navigator.of(context).pop(_RoutineDraft(
                        _imageId, _title.trim(), _days.toList(), _time))
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
                  FFLocalizations.of(context).getText('cb_routine_save'),
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
