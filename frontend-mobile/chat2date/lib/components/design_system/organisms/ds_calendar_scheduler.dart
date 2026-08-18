import 'package:chat2date/components/design_system/organisms/calendar/calendar_card.dart';
import 'package:chat2date/components/design_system/feedback/index.dart';
import 'package:flutter/material.dart';

enum DsCalendarSchedulerPreviewState {
  defaultState,
  choose,
  preEdit,
  edit,
}

class DsCalendarScheduler extends StatefulWidget {
  const DsCalendarScheduler({
    super.key,
    required this.placeName,
    this.previewState = DsCalendarSchedulerPreviewState.defaultState,
    this.onCloseRequested,
    this.onSaved,
    this.onDeleted,
  });

  final String placeName;
  final DsCalendarSchedulerPreviewState previewState;
  final VoidCallback? onCloseRequested;
  final ValueChanged<DateTime>? onSaved;
  final VoidCallback? onDeleted;

  @override
  State<DsCalendarScheduler> createState() => _DsCalendarSchedulerState();
}

class _DsCalendarSchedulerState extends State<DsCalendarScheduler> {
  static final DateTime _chooseSeed = DateTime(2026, 1, 15, 12, 0);
  static final DateTime _preEditSeed = DateTime(2026, 1, 17, 10, 0);

  DateTime? _savedDateTime;
  DateTime? _draftDateTime;
  int _calendarVersion = 0;

  @override
  void initState() {
    super.initState();
    switch (widget.previewState) {
      case DsCalendarSchedulerPreviewState.defaultState:
        _savedDateTime = null;
        _draftDateTime = null;
      case DsCalendarSchedulerPreviewState.choose:
        _savedDateTime = null;
        _draftDateTime = _chooseSeed;
      case DsCalendarSchedulerPreviewState.preEdit:
        _savedDateTime = _preEditSeed;
        _draftDateTime = null;
      case DsCalendarSchedulerPreviewState.edit:
        _savedDateTime = _chooseSeed;
        _draftDateTime = _preEditSeed;
    }
  }

  bool get _hasExistingSchedule => _savedDateTime != null;

  DateTime get _displayDateTime =>
      _draftDateTime ?? _savedDateTime ?? DateTime.now();

  DateTime get _initialMonth => DateTime(
        _displayDateTime.year,
        _displayDateTime.month,
        1,
      );

  TimeOfDay get _initialTime => TimeOfDay.fromDateTime(
        _savedDateTime ?? _draftDateTime ?? _chooseSeed,
      );

  String get _primaryLine => _hasExistingSchedule
      ? 'สถานที่เดต : ${widget.placeName}'
      : 'คุณมี 1 สถานที่เดต!!';

  String get _secondaryLine =>
      _hasExistingSchedule ? _formatThaiDateTime(_displayDateTime) : widget.placeName;

  void _resetToCommittedState() {
    setState(() {
      _draftDateTime = null;
      _calendarVersion += 1;
    });
  }

  void _handleClose(bool hasUnsavedChanges) {
    if (!hasUnsavedChanges) {
      widget.onCloseRequested?.call();
      return;
    }

    DsActionModal.show(
      context,
      child: DsChoiceModal(
        title: 'ละทิ้งการแก้ไขหรือไม่',
        description: 'การเปลี่ยนแปลงที่คุณแก้ไขไว้จะไม่ถูกบันทึก',
        negativeLabel: 'ยกเลิก',
        positiveLabel: 'ยืนยัน',
        onNegativePressed: () => Navigator.of(context, rootNavigator: true).pop(),
        onPositivePressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          _resetToCommittedState();
          widget.onCloseRequested?.call();
        },
      ),
    );
  }

  void _handleDelete() {
    DsActionModal.show(
      context,
      child: DsChoiceModal(
        title: 'ยืนยันที่จะลบวันเดตหรือไม่',
        description:
            'การลบวันเดต สถานที่เดตวันนั้นจะหายไปด้วย\nคุณจะต้อง สุ่มเดตใหม่ หากต้องการเดตอีกครั้ง',
        negativeLabel: 'ยกเลิก',
        positiveLabel: 'ยืนยัน',
        onNegativePressed: () => Navigator.of(context, rootNavigator: true).pop(),
        onPositivePressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            _savedDateTime = null;
            _draftDateTime = null;
            _calendarVersion += 1;
          });
          widget.onDeleted?.call();
          widget.onCloseRequested?.call();
        },
      ),
    );
  }

  void _handleSave(DateTime date, TimeOfDay time) {
    final savedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!_hasExistingSchedule) {
      _applySave(savedDateTime);
      return;
    }

    DsActionModal.show(
      context,
      child: DsChoiceModal(
        title: 'ยืนยันที่จะแก้ไขวันเดตหรือไม่',
        description: 'หากแก้ไข วันเดตเดิมจะถูกยกเลิกทันที',
        negativeLabel: 'ยกเลิก',
        positiveLabel: 'ยืนยัน',
        onNegativePressed: () => Navigator.of(context, rootNavigator: true).pop(),
        onPositivePressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          _applySave(savedDateTime);
        },
      ),
    );
  }

  void _applySave(DateTime dateTime) {
    setState(() {
      _savedDateTime = dateTime;
      _draftDateTime = null;
      _calendarVersion += 1;
    });
    widget.onSaved?.call(dateTime);
    DsStatusModal.show(
      context,
      type: DsStatusModalType.success,
      title: 'บันทึกเสร็จสิ้น',
      message:
          'วันและเวลาออกเดตของคุณคือ ${_formatThaiDate(dateTime)}\nเวลา ${_formatThaiTime(dateTime)} ที่${widget.placeName}',
      trailingMessage: 'เราจะแจ้งเตือนคุณอีกครั้งล่วงหน้าก่อนวันเดต 1 วัน',
    );
    widget.onCloseRequested?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CalendarCard(
      key: ValueKey(_calendarVersion),
      initialMonth: _initialMonth,
      initialTime: _initialTime,
      initialSelectedDate: _savedDateTime,
      initialDraftDate: _draftDateTime,
      isEditMode: _hasExistingSchedule,
      confirmEditBeforeSave: false,
      showAutoDateSummary: false,
      placeCountText: _primaryLine,
      placeName: _secondaryLine,
      onSave: _handleSave,
      onClose: _handleClose,
      onTrash: _hasExistingSchedule ? _handleDelete : null,
    );
  }

  String _formatThaiDate(DateTime dateTime) {
    const months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatThaiTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour.$minute น.';
  }

  String _formatThaiDateTime(DateTime dateTime) {
    return '${_formatThaiDate(dateTime)} เวลา ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
