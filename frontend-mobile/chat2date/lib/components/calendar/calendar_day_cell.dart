import 'package:flutter/material.dart';

const _cellW = 42.0;
const _cellH = 34.0;

class CalendarDayCell extends StatelessWidget {
  final DateTime? date; // << เปลี่ยนเป็น nullable
  final DateTime currentMonth;
  final DateTime? selected;
  final ValueChanged<DateTime>? onSelect;
  final Size? size;

  const CalendarDayCell({
    super.key,
    required this.date, // ตอนเรียกใช้: date: d (จะรับ null ได้)
    required this.currentMonth,
    this.selected,
    this.onSelect,
    this.size,
  });

  bool get _hasDate => date != null;

  bool get _isCurrentMonth =>
      _hasDate &&
      date!.year == currentMonth.year &&
      date!.month == currentMonth.month;

  bool get _isSelected =>
      _hasDate &&
      selected != null &&
      date!.year == selected!.year &&
      date!.month == selected!.month &&
      date!.day == selected!.day;

  @override
  Widget build(BuildContext context) {
    final s = size ?? const Size(_cellW, _cellH);

    // ถ้า cell นี้เป็นช่องว่าง (padding ของตาราง) ให้แสดง empty/กดไม่ได้
    if (!_hasDate) {
      return SizedBox(
        width: s.width,
        height: s.height,
        // ใส่ Container เปล่าเพื่อให้ grid คง layout เท่ากัน
        child: const SizedBox.shrink(),
      );
    }

    final dayStr = '${date!.day}';

    const base = TextStyle(
      fontFamily: 'Inter',
      fontSize: 13.95,
      fontWeight: FontWeight.w500,
      height: 1,
    );

    final Color textColor = _isSelected
        ? Colors.white
        : (_isCurrentMonth ? const Color(0xFF1F1F1F) : const Color(0x26001753));

    return SizedBox(
      width: s.width,
      height: s.height,
      child: InkWell(
        borderRadius: BorderRadius.circular(4.65),
        onTap: _hasDate ? () => onSelect?.call(date!) : null,
        child: Container(
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: _isSelected ? const Color(0xFF5CE1E6) : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.65),
            ),
          ),
          child: Text(
            dayStr, // แสดงเลขวันเสมอ (รวมกรณี 2 หลัก)
            textAlign: TextAlign.center,
            style: base.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
