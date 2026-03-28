import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'calendar_utils.dart';
import 'calendar_day_cell.dart';

/// CalendarCard พร้อม: ปุ่มปิด (SVG), Header เดือน/ปีแบบ Dropdown + ปุ่มซ้าย/ขวา,
/// ตารางวัน, และ Time Dropdown (ชั่วโมง/นาที/AMPM)
class CalendarCard extends StatefulWidget {
  final DateTime initialMonth;
  final TimeOfDay? initialTime;

  /// ★ ใหม่: วันที่ที่ถูกเลือกไว้แล้ว (edit mode) ถ้าเปิดใหม่ให้เป็น null
  final DateTime? initialSelectedDate;
  final DateTime? initialDraftDate;
  final bool isEditMode;
  final void Function(DateTime date, TimeOfDay time)? onSave;
  final void Function(bool hasUnsavedChanges)? onClose;
  final ValueChanged<bool>? onDirtyChanged;
  final VoidCallback? onTrash;
  final bool isReadOnly;
  final bool confirmEditBeforeSave;
  final bool showAutoDateSummary;
  final Color accentColor; // สีเน้น (เช่น ใช้กับชื่อเดือน)

  /// ชื่อสถานที่ที่ได้จาก spinwheel (แสดงใต้ปุ่มบันทึก)
  final String placeCountText;
  final String placeName;

  const CalendarCard({
    super.key,
    required this.initialMonth,
    this.initialTime,
    this.initialSelectedDate,
    this.initialDraftDate,
    this.isEditMode = false,
    this.onSave,
    this.onClose,
    this.onDirtyChanged,
    this.onTrash,
    this.isReadOnly = false,
    this.confirmEditBeforeSave = true,
    this.showAutoDateSummary = true,
    this.accentColor = AppColors.brandPrimary,
    this.placeCountText = 'คุณมี 1 สถานที่เดต!!',
    this.placeName = 'อควาเรียมบางแสน',
  });

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _cursorMonth;
  DateTime? _selectedDate;
  DateTime? _initialSelectedDate;
  late TimeOfDay _initialTime;

  // Time (Dropdown)
  late int _hour24Value; // 0..23
  late int _minute; // 0..59
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _cursorMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
      1,
    );
    // ★ แก้: ถ้าเปิดใหม่ (ไม่มี initialSelectedDate) → ไม่ไฮไลต์วันใด
    // ถ้าเป็น edit mode → ไฮไลต์วันที่เลือกไว้แล้ว
    _initialSelectedDate = widget.initialSelectedDate == null
        ? null
        : DateUtils.dateOnly(widget.initialSelectedDate!);
    _selectedDate = widget.initialDraftDate == null
        ? _initialSelectedDate
        : DateUtils.dateOnly(widget.initialDraftDate!);

    _initialTime = widget.initialTime ?? const TimeOfDay(hour: 12, minute: 0);
    final draftTime = widget.initialDraftDate == null
        ? _initialTime
        : TimeOfDay.fromDateTime(widget.initialDraftDate!);
    final t = draftTime;
    _hour24Value = t.hour;
    _minute = t.minute;

    // ปุ่มบันทึกจะถูก disabled จนกว่า user จะเลือกวัน/เวลาจริงๆ
    // ถ้ามี initialSelectedDate (edit mode) → ถือว่าเลือกแล้ว
    _hasUserPicked =
        widget.initialDraftDate != null || widget.initialSelectedDate != null;
    _hasUnsavedChanges = _isDirty;
  }

  DateTime? get _currentSelectedDateOnly =>
      _selectedDate == null ? null : DateUtils.dateOnly(_selectedDate!);

  bool get _isExistingSelectedDateLocked {
    if (!widget.isEditMode ||
        widget.initialSelectedDate == null ||
        _currentSelectedDateOnly == null) {
      return false;
    }
    return DateUtils.isSameDay(_currentSelectedDateOnly, _initialSelectedDate) &&
        !_hasUnsavedChanges;
  }

  TimeOfDay get _currentTime => TimeOfDay(hour: _hour24Value, minute: _minute);

  bool get _isDirty {
    final initialDate = _initialSelectedDate;
    final currentDate = _currentSelectedDateOnly;
    final dateChanged = initialDate == null
        ? currentDate != null
        : currentDate == null ||
            initialDate.year != currentDate.year ||
            initialDate.month != currentDate.month ||
            initialDate.day != currentDate.day;
    final timeChanged = _currentTime.hour != _initialTime.hour ||
        _currentTime.minute != _initialTime.minute;
    return dateChanged || timeChanged;
  }

  void _commitState(VoidCallback update) {
    setState(() {
      update();
      _hasUnsavedChanges = _isDirty;
    });
    widget.onDirtyChanged?.call(_hasUnsavedChanges);
  }

  // ==== Month / Year helpers ====
  bool _hasUserPicked =
      false; // ปุ่มบันทึกจะ disabled จนกว่าจะเลือก/แก้ไขวันหรือเวลา
  List<String> get _months => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  String get _monthName => _months[_cursorMonth.month - 1];

  List<int> get _years {
    final nowY = DateTime.now().year;
    return [nowY, nowY + 1];
  }

  void _setMonthByName(String name) {
    final idx = _months.indexOf(name);
    if (idx >= 0) {
      final now = DateTime.now();
      // ถ้าเลือกปีปัจจุบัน ห้ามเลือกเดือนในอดีต
      var newMonth = idx + 1;
      if (_cursorMonth.year == now.year && newMonth < now.month) {
        newMonth = now.month; // บังคับเป็นเดือนปัจจุบัน
      }

      _commitState(() {
        _cursorMonth = DateTime(_cursorMonth.year, newMonth, 1);
      });
    }
  }

  void _setYear(int year) {
    _commitState(() {
      final now = DateTime.now();
      final safeMonth = year == now.year && _cursorMonth.month < now.month
          ? now.month
          : _cursorMonth.month;
      _cursorMonth = DateTime(year, safeMonth, 1);
    });
  }

  void _prevMonth() {
    final now = DateTime.now();
    // ถ้า _cursorMonth เป็นเดือนปัจจุบันหรือย้อนหลังไปแล้ว ห้ามกดย้อนกลับ
    if (_cursorMonth.year < now.year ||
        (_cursorMonth.year == now.year && _cursorMonth.month <= now.month)) {
      return;
    }

    _commitState(() {
      _cursorMonth = DateTime(_cursorMonth.year, _cursorMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    _commitState(() {
      _cursorMonth = DateTime(_cursorMonth.year, _cursorMonth.month + 1, 1);
    });
  }

  // ==== Time helpers (Dropdown) ====
  List<int> get _hours24 => [for (int h = 0; h < 24; h++) h];
  List<int> get _minutes => [for (int m = 0; m < 60; m++) m];

  bool get _isPastTimeSelected {
    if (_selectedDate == null) return false;
    final now = DateTime.now();
    final m = _minute.clamp(0, 59);
    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _hour24Value,
      m,
    );
    return selectedDateTime.isBefore(now);
  }

  String get _selectedDateTimeSummary {
    if (_selectedDate == null) {
      return 'ยังไม่ได้เลือกวันที่และเวลา';
    }

    const thaiMonths = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];

    final hour = _hour24Value.toString().padLeft(2, '0');
    final minute = _minute.toString().padLeft(2, '0');

    return '${_selectedDate!.day} ${thaiMonths[_selectedDate!.month - 1]} ${_selectedDate!.year} เวลา $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final weeks = buildMonthMatrix(_cursorMonth);
    final now = DateTime.now();
    final isReadOnly = widget.isReadOnly;
    final canSave =
        !isReadOnly &&
        _hasUserPicked &&
        _selectedDate != null &&
        !_isPastTimeSelected &&
        (!widget.isEditMode || _hasUnsavedChanges);

    // สร้างลิสต์เดือนใหม่ตามปีที่เลือก
    // ถ้าเป็นปีปัจจุบัน ให้เริ่มตั้งแต่เดือนปัจจุบัน ไม่งั้นเริ่มมกราคม
    List<String> currentValidMonths = [..._months];
    if (_cursorMonth.year == now.year) {
      currentValidMonths = _months.sublist(now.month - 1);
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ShapeDecoration(
            color: AppColors.background,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(20, 20),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                width: double.infinity,
                child: Stack(
                  children: [
                    if (widget.onTrash != null && !isReadOnly)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: widget.onTrash, // << แก้จุดนี้
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 7,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/ui/ic-trash-20x26.svg',
                              width: 20,
                              height: 26,
                            ),
                          ),
                        ),
                      ),

                    // กลาง: ชื่อ CALENDAR (Inter)
                    const Center(
                      child: Text(
                        'CALENDAR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),

                    // ขวา: Close X 21x21 (ลอยมุม)
                    if (widget.onClose != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: () => widget.onClose?.call(_hasUnsavedChanges),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset(
                              'assets/icons/ui/ic-close-21.svg',
                              width: 21,
                              height: 21,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // —— Month/Year dropdown + arrows ——
              SizedBox(
                height: 34.11,
                width: double.infinity,
                child: Row(
                  children: [
                    // ปุ่มย้อนกลับเดือน (Disable ถ้าเป็นเดือนปัจจุบัน)
                    _circleIconButton(
                      Icons.chevron_left,
                      onTap:
                          isReadOnly ||
                              (_cursorMonth.year == now.year &&
                                  _cursorMonth.month <= now.month)
                          ? null
                          : _prevMonth,
                      color:
                          isReadOnly ||
                              (_cursorMonth.year == now.year &&
                                  _cursorMonth.month <= now.month)
                          ? AppColors.textDisabled
                          : AppColors.surface,
                    ),

                    // กลาง: เดือน/ปี อยู่ในกรอบจำกัดความกว้าง กันล้น
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _pillDropdown<String>(
                                displayText: _monthName,
                                textColor: AppColors.textPrimary,
                                items: currentValidMonths,
                                toLabel: (m) => m,
                                onSelected:
                                    isReadOnly ? null : (m) => _setMonthByName(m),
                                fixedWidth: 122,
                                trailingSvg:
                                    'assets/icons/ui/ic-chevron-down-6x19.svg',
                                trailingSvgSize: const Size(3.6, 10.8),
                                iconColor: AppColors.brandPrimary,
                                trailingSvgDy: 3.0, // << ลงล่างแกน Y
                              ),

                              _pillDropdown<int>(
                                displayText: '${_cursorMonth.year}',
                                textColor: AppColors.textPrimary,
                                items: _years,
                                toLabel: (y) => y.toString(),
                                onSelected:
                                    isReadOnly ? null : (y) => _setYear(y),
                                fixedWidth: 82,
                                trailingSvg:
                                    'assets/icons/ui/ic-chevron-down-6x19.svg',
                                trailingSvgSize: const Size(3.6, 10.8),
                                iconColor: AppColors.brandPrimary,
                                trailingSvgDy: 3.0, // << ลงล่างแกน Y
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    _circleIconButton(
                      Icons.chevron_right,
                      onTap: isReadOnly ? null : _nextMonth,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // —— สัปดาห์ Mo..Su ——
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(child: _WeekName('Mo')),
                  Expanded(child: _WeekName('Tu')),
                  Expanded(child: _WeekName('We')),
                  Expanded(child: _WeekName('Th')),
                  Expanded(child: _WeekName('Fr')),
                  Expanded(child: _WeekName('Sa')),
                  Expanded(child: _WeekName('Su')),
                ],
              ),
              const SizedBox(height: 6),

              // —— ตารางวัน ——
              LayoutBuilder(
                builder: (context, constraints) {
                  const double gap = 4; // เดิม 6 → ลดลงเล็กน้อยเพื่อลดโอกาสล้น
                  final double raw = (constraints.maxWidth - (gap * 6)) / 7;
                  final double cellW = raw
                      .clamp(40, 56)
                      .floorToDouble(); // ปัดให้เป็นจำนวนเต็ม

                  return Column(
                    children: weeks.map((row) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: row.map((d) {
                            if (d == null) {
                              return SizedBox(
                                width: cellW,
                                height: 34,
                              ); // ช่องว่าง
                            }
                            return SizedBox(
                              width: cellW,
                              child: CalendarDayCell(
                                date: d,
                                currentMonth: _cursorMonth,
                                selected: _selectedDate,
                                selectedColor: AppColors.brandPrimary,
                                selectedTextColor: AppColors.textOnDark,
                                selectedDisabled: _isExistingSelectedDateLocked,
                                onSelect: isReadOnly
                                    ? null
                                    : (day) => _commitState(() {
                                          _selectedDate = day;
                                          _hasUserPicked = true; // เลือกวันแล้ว enable ปุ่มบันทึก
                                        }),
                                size: Size(cellW, 34), // สูง 34 ตามดีไซน์
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),

              // —— Time (Dropdown) ——
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // กึ่งกลางทั้งก้อน
                  children: [
                    const Text(
                      'Time',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // กลุ่มตัวเลือก เวลา (ยืดได้เล็กน้อย กัน overflow)
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _timeDropdownBox(
                            child: _numberDropdown<int>(
                              width: 36,
                              value: _hour24Value,
                              values: _hours24,
                              formatter: (h) => h.toString().padLeft(2, '0'),
                              onChanged: isReadOnly
                                  ? null
                                  : (v) => _commitState(() {
                                        _hour24Value = v!;
                                        _hasUserPicked = true;
                                      }),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          _timeDropdownBox(
                            child: _numberDropdown<int>(
                              width: 40,
                              value: _minute,
                              values: _minutes,
                              formatter: (m) => m.toString().padLeft(2, '0'),
                              onChanged: isReadOnly
                                  ? null
                                  : (v) => _commitState(() {
                                        _minute = v!;
                                        _hasUserPicked = true;
                                      }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              SizedBox(
                width: 310,
                child: Text(
                  widget.placeCountText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.67,
                  ),
                ),
              ),
              SizedBox(
                width: 310,
                child: Text(
                  widget.placeName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textSupport,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.67,
                  ),
                ),
              ),
              if (widget.showAutoDateSummary)
                SizedBox(
                  width: 310,
                  child: Text(
                    _selectedDateTimeSummary,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textSupport,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.67,
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // —— ปุ่มบันทึก (ใช้ DsButton เพื่อให้ active/disabled เหมือนทั้ง project) ———
              DsButton(
                label: 'บันทึก',
                variant: DsButtonVariant.primary,
                size: DsButtonSize.md,
                onPressed: canSave ? _handleSavePressed : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSavePressed() {
    final m = _minute.clamp(0, 59);
    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _hour24Value,
      m,
    );
    final selectedTime = TimeOfDay(hour: _hour24Value, minute: m);
    final shouldConfirmEdit =
        widget.confirmEditBeforeSave &&
        widget.isEditMode &&
        widget.initialSelectedDate != null;

    if (shouldConfirmEdit) {
      _showSaveConfirmDialog(selectedDateTime, selectedTime);
      return;
    }

    widget.onSave?.call(selectedDateTime, selectedTime);
  }

  void _showSaveConfirmDialog(DateTime date, TimeOfDay time) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ModalComponent(
          svgPath: 'assets/icons/ui/icon_warning.svg',
          heightSvg: 68,
          widthSvg: 77,
          topic: 'ยืนยันการเปลี่ยนวันเดต',
          description: 'ต้องการบันทึกการเปลี่ยนแปลงวันเดตนี้ใช่หรือไม่',
          choice: true,
          firstChoiceText: 'ยกเลิก',
          secondChoiceText: 'ยืนยัน',
          onFirstChoice: () => Navigator.pop(ctx),
          onSecondChoice: () {
            Navigator.pop(ctx);
            widget.onSave?.call(date, time);
          },
        ),
      ),
    );
  }

  // ===================== UI helpers =====================

  // ปุ่มวงกลมซ้าย/ขวา
  Widget _circleIconButton(
    IconData icon, {
    VoidCallback? onTap,
    Color color = AppColors.surface,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34.11,
        height: 34.11,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(62.01),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000E33),
              blurRadius: 0.78,
              offset: Offset(0, 0.78),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _pillDropdown<T>({
    required String displayText,
    required Color textColor,
    required List<T> items,
    required String Function(T) toLabel,
    required ValueChanged<T>? onSelected,
    double fixedWidth = 128,
    String? trailingSvg,
    Size trailingSvgSize = const Size(3.6, 10.8),
    Color iconColor = AppColors.brandPrimary,

    // เพิ่มตัวเลื่อนแกน Y ของไอคอน (ค่าบวก = ลงล่าง)
    double trailingSvgDy = 2.0, // << ปรับได้ตามใจ
  }) {
    const double padX = 9.3;
    const double padY = 7.75;
    const double gap = 4.0;

    final double iconW = trailingSvg != null ? trailingSvgSize.width : 0;
    final double rightReserve = trailingSvg != null
        ? (iconW + gap + padX)
        : padX;

    final pillSurface = Container(
      padding: const EdgeInsets.symmetric(horizontal: padX, vertical: padY),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.65),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000E33),
            blurRadius: 0.78,
            offset: Offset(0, 0.78),
          ),
        ],
      ),
      child: SizedBox(
        width: fixedWidth - (padX * 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ข้อความกึ่งกลาง + กันพื้นที่ด้านขวาไว้สำหรับไอคอน
            Padding(
              padding: EdgeInsets.only(right: rightReserve),
              child: Text(
                displayText,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: textColor,
                  fontSize: 18.6,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: -0.19,
                ),
              ),
            ),

            if (trailingSvg != null)
              // ชิดขวา และ "ลงล่างแกน Y"
              Positioned(
                right: 0,
                bottom: -trailingSvgDy, // << เลื่อนลง (เพิ่มเลขเพื่อให้ต่ำลง)
                child: SizedBox(
                  width: trailingSvgSize.width,
                  height: trailingSvgSize.height,
                  child: SvgPicture.asset(
                    trailingSvg,
                    width: trailingSvgSize.width,
                    height: trailingSvgSize.height,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: fixedWidth),
      child: PopupMenuButton<T>(
        padding: EdgeInsets.zero,
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        enabled: onSelected != null,
        onSelected: onSelected,
        menuPadding: EdgeInsets.zero,
        itemBuilder: (context) => items
            .map(
              (v) => PopupMenuItem<T>(
                value: v,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  toLabel(v),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: displayText == toLabel(v)
                        ? FontWeight.w600
                        : FontWeight.w400,
                    height: 1.43,
                    color: displayText == toLabel(v)
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            )
            .toList(),
        child: pillSurface,
      ),
    );
  }

  // กล่องเทาอ่อนสำหรับ Time dropdown
  Widget _timeDropdownBox({required Widget child}) {
    return Container(
      height: 30, // เดิม 32
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.inputDisabledBg,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  // Number dropdown generic (ใช้กับชั่วโมง/นาที)
  Widget _numberDropdown<T>({
    required double width,
    required T value,
    required List<T> values,
    String Function(T)? formatter,
    ValueChanged<T?>? onChanged,
  }) {
    String labelOf(T v) => formatter != null ? formatter(v) : v.toString();

    return SizedBox(
      width: width,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          dropdownColor: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 240,
          value: value,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
          icon: const SizedBox.shrink(), // ไม่มีไอคอนในช่องเวลา (ดูสะอาด)
          onChanged: onChanged,
          items: values.map((v) {
            return DropdownMenuItem<T>(
              value: v,
              alignment: Alignment.center,
              child: Text(
                labelOf(v),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: value == v ? FontWeight.w600 : FontWeight.w400,
                  height: 1.43,
                  color: value == v
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

}

class _WeekName extends StatelessWidget {
  final String text;
  const _WeekName(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.brandPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ),
    );
  }
}
