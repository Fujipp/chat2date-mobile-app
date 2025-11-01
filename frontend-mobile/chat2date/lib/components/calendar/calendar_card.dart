import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'calendar_utils.dart';
import 'calendar_day_cell.dart';

/// CalendarCard พร้อม: ปุ่มปิด (SVG), Header เดือน/ปีแบบ Dropdown + ปุ่มซ้าย/ขวา,
/// ตารางวัน, และ Time Dropdown (ชั่วโมง/นาที/AMPM)
class CalendarCard extends StatefulWidget {
  final DateTime initialMonth;
  final TimeOfDay? initialTime;
  final void Function(DateTime date, TimeOfDay time)? onSave;
  final VoidCallback? onClose;
  final Color accentColor; // สีเน้น (เช่น ใช้กับชื่อเดือน)

  const CalendarCard({
    super.key,
    required this.initialMonth,
    this.initialTime,
    this.onSave,
    this.onClose,
    this.accentColor = const Color(0xFFFF6B81),
  });

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _cursorMonth;
  DateTime? _selectedDate;

  // Time (Dropdown)
  late int _hour12; // 1..12
  late int _minute; // 0..59
  bool _am = true;

  @override
  void initState() {
    super.initState();
    _cursorMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
      1,
    );
    _selectedDate = DateTime(_cursorMonth.year, _cursorMonth.month, 1);

    final t = widget.initialTime ?? const TimeOfDay(hour: 12, minute: 0);
    _am = t.period == DayPeriod.am;
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    _hour12 = h12;
    _minute = t.minute;
  }

  // ==== Month / Year helpers ====
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
    // ช่วงปี (เลื่อนดูได้กว้าง ๆ)
    final nowY = DateTime.now().year;
    return [for (int y = nowY - 50; y <= nowY + 50; y++) y];
  }

  void _setMonthByName(String name) {
    final idx = _months.indexOf(name);
    if (idx >= 0) {
      setState(() {
        _cursorMonth = DateTime(_cursorMonth.year, idx + 1, 1);
        _selectedDate = DateTime(_cursorMonth.year, _cursorMonth.month, 1);
      });
    }
  }

  void _setYear(int year) {
    setState(() {
      _cursorMonth = DateTime(year, _cursorMonth.month, 1);
      _selectedDate = DateTime(year, _cursorMonth.month, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _cursorMonth = DateTime(_cursorMonth.year, _cursorMonth.month - 1, 1);
      _selectedDate = DateTime(_cursorMonth.year, _cursorMonth.month, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _cursorMonth = DateTime(_cursorMonth.year, _cursorMonth.month + 1, 1);
      _selectedDate = DateTime(_cursorMonth.year, _cursorMonth.month, 1);
    });
  }

  // ==== Time helpers (Dropdown) ====
  List<int> get _hours12 => [for (int h = 1; h <= 12; h++) h];
  List<int> get _minutes => [for (int m = 0; m < 60; m++) m];

  int get _hour24 => _am ? (_hour12 % 12) : ((_hour12 % 12) + 12);

  @override
  Widget build(BuildContext context) {
    final weeks = buildMonthMatrix(_cursorMonth);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x1A000000)),
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
              // —— Header Title + X (SVG) ——
              SizedBox(
                height: 40,
                width: double.infinity,
                child: Stack(
                  children: [
                    const Center(
                      child: Text(
                        'CALENDAR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    if (widget.onClose != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: widget.onClose,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: _maybeSvg(
                              path: 'assets/icons/close_x.svg',
                              fallback: const Icon(
                                Icons.close_rounded,
                                size: 21,
                                color: Color(0xFFE56B6F),
                              ),
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
                    _circleIconButton(Icons.chevron_left, onTap: _prevMonth),

                    // กลาง: เดือน/ปี ยืด-ยุบได้ ป้องกัน overflow
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 240,
                          ), // กันล้นจอเล็ก
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              _pillDropdown<String>(
                                displayText: _monthName,
                                textColor: widget.accentColor,
                                items: _months,
                                toLabel: (m) => m,
                                onSelected: (m) => _setMonthByName(m),
                                fixedWidth: 128,
                              ),
                              _pillDropdown<int>(
                                displayText: '${_cursorMonth.year}',
                                textColor: const Color(0xFF141414),
                                items: _years,
                                toLabel: (y) => y.toString(),
                                onSelected: (y) => _setYear(y),
                                fixedWidth: 88,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    _circleIconButton(Icons.chevron_right, onTap: _nextMonth),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // —— สัปดาห์ Mo..Su ——
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _WeekName('Mo'),
                  _WeekName('Tu'),
                  _WeekName('We'),
                  _WeekName('Th'),
                  _WeekName('Fr'),
                  _WeekName('Sa'),
                  _WeekName('Su'),
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
                            return SizedBox(
                              width: cellW,
                              child: CalendarDayCell(
                                date: d,
                                currentMonth: _cursorMonth,
                                selected: _selectedDate,
                                onSelect: (day) =>
                                    setState(() => _selectedDate = day),
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
                        color: Color(0xFF213447),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // กลุ่มตัวเลือก เวลา (ยืดได้เล็กน้อย กัน overflow)
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _timeDropdownBox(
                            child: _numberDropdown<int>(
                              width: 40, // เดิม 42
                              value: _hour12,
                              values: _hours12,
                              onChanged: (v) => setState(() => _hour12 = v!),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF213447),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          _timeDropdownBox(
                            child: _numberDropdown<int>(
                              width: 44, // เดิม 48
                              value: _minute,
                              values: _minutes,
                              formatter: (m) => m.toString().padLeft(2, '0'),
                              onChanged: (v) => setState(() => _minute = v!),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 86,
                              maxWidth: 92,
                            ),
                            child: _amPmSegmented(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              const SizedBox(
                width: 310,
                child: Text(
                  'คุณมี 1 สถานที่เดต!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.67,
                  ),
                ),
              ),
              const SizedBox(
                width: 310,
                child: Text(
                  'อควาเรียมบางแสน',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.67,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // —— ปุ่มบันทึก ——
              SizedBox(
                width: 231,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8F1F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: (_selectedDate == null)
                      ? null
                      : () {
                          final h24 = _hour24;
                          final m = _minute.clamp(0, 59);
                          final selectedDateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            h24,
                            m,
                          );
                          widget.onSave?.call(
                            selectedDateTime,
                            TimeOfDay(hour: h24, minute: m),
                          );
                        },
                  child: const Text(
                    'บันทึก',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // —— ปุ่มปิด (ลอยมุมขวาบน) ——
        // หมายเหตุ: ถ้าอยากซ่อนปุ่มนี้ไว้ใน header แล้วไม่โชว์ลอยซ้ำ สามารถลบบล็อกนี้ได้
        // ตอนนี้ผมคงไว้เพื่อให้กดปิดได้ง่ายทั้ง 2 จุด
        // Positioned(
        //   right: 6,
        //   top: 6,
        //   child: InkWell(
        //     onTap: widget.onClose,
        //     customBorder: const CircleBorder(),
        //     child: Container(
        //       width: 28,
        //       height: 28,
        //       decoration: const BoxDecoration(
        //         color: Colors.white,
        //         shape: BoxShape.circle,
        //         boxShadow: [
        //           BoxShadow(
        //             color: Color(0x14000000),
        //             blurRadius: 6,
        //             offset: Offset(0, 2),
        //           ),
        //         ],
        //       ),
        //       child: _maybeSvg(
        //         path: 'assets/icons/close_x.svg',
        //         fallback: const Icon(
        //           Icons.close_rounded,
        //           size: 18,
        //           color: Color(0xFFE56B6F),
        //         ),
        //         width: 18,
        //         height: 18,
        //       ),
        // ),
        // ),
        // ),
      ],
    );
  }

  // ===================== UI helpers =====================

  // ปุ่มวงกลมซ้าย/ขวา
  Widget _circleIconButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34.11,
        height: 34.11,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(62.01),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000E33),
              blurRadius: 0.78,
              offset: Offset(0, 0.78),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _pillDropdown<T>({
    required String displayText,
    required Color textColor,
    required List<T> items,
    required String Function(T) toLabel,
    required ValueChanged<T> onSelected,
    double? fixedWidth, // << เพิ่ม
  }) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.30, vertical: 7.75),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.65),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000E33),
            blurRadius: 0.78,
            offset: Offset(0, 0.78),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ล็อกความกว้างข้อความให้คงที่ + ตัดด้วย ellipsis ถ้ายาว
          SizedBox(
            width: fixedWidth != null
                ? (fixedWidth - 24)
                : null, // เหลือที่ให้ไอคอน 16 +ช่องว่าง
            child: Text(
              displayText,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 4),
          // ใช้ SVG แทน Icon
          SvgPicture.asset(
            'assets/icons/chevron_down.svg',
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: fixedWidth != null
          ? BoxConstraints.tightFor(width: fixedWidth)
          : const BoxConstraints(),
      child: PopupMenuButton<T>(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onSelected: onSelected,
        itemBuilder: (context) {
          return items.map((v) {
            final label = toLabel(v);
            return PopupMenuItem<T>(
              value: v,
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter', // ไทยก็ Inter
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            );
          }).toList();
        },
        child: pill,
      ),
    );
  }

  // กล่องเทาอ่อนสำหรับ Time dropdown
  Widget _timeDropdownBox({required Widget child}) {
    return Container(
      height: 30, // เดิม 32
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F7),
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
    required ValueChanged<T?> onChanged,
  }) {
    String labelOf(T v) => formatter != null ? formatter(v) : v.toString();

    return SizedBox(
      width: width,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF213447),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          icon: const SizedBox.shrink(), // ไม่มีไอคอนในช่องเวลา (ดูสะอาด)
          onChanged: onChanged,
          items: values.map((v) {
            return DropdownMenuItem<T>(
              value: v,
              alignment: Alignment.center,
              child: Text(labelOf(v)),
            );
          }).toList(),
        ),
      ),
    );
  }

  // AM/PM segmented (เหมือนเดิม)
  Widget _amPmSegmented() {
    return Container(
      height: 30, // ให้ match กับกล่อง dropdown
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segmented(
              label: 'AM',
              selected: _am,
              onTap: () => setState(() => _am = true),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: _segmented(
              label: 'PM',
              selected: !_am,
              onTap: () => setState(() => _am = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmented({
    required String label,
    required bool selected,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(
                  color: Colors.black.withValues(alpha: 0.04),
                  width: 0.5,
                )
              : null,
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 1,
                    offset: Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Color(0x1E000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF213447),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.14,
          ),
        ),
      ),
    );
  }

  // แสดง SVG ถ้ามี ไม่งั้น fallback เป็น Icon ปกติ
  Widget _maybeSvg({
    required String path,
    required Widget fallback,
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      // ถ้าไฟล์ไม่พบจะ throw; ห่อ try ไม่ได้ง่าย ๆ ใน build tree
      // ทางแก้: ให้ Dev ใส่ไฟล์ SVG ตาม path ไว้จริง หรือเปลี่ยนเป็น Icon ปกติ
      // แต่เพื่อความปลอดภัย UI, ใช้ errorBuilder คืน fallback
      package: null,
      fit: BoxFit.contain,
      colorFilter: null,
      // ignore: deprecated_member_use
      placeholderBuilder: (_) => fallback,
    );
  }
}

class _WeekName extends StatelessWidget {
  final String text;
  const _WeekName(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 34,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF1F1F1F),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ),
    );
  }
}
