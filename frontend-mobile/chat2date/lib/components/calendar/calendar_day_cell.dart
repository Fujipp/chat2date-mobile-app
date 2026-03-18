import 'package:flutter/material.dart';

const _cellW = 42.0;
const _cellH = 34.0;

class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final DateTime currentMonth;
  final DateTime? selected;
  final ValueChanged<DateTime>? onSelect;
  final Size? size;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.currentMonth,
    this.selected,
    this.onSelect,
    this.size,
  });

  bool get _isCurrentMonth =>
      date.year == currentMonth.year && date.month == currentMonth.month;

  bool get _isSelected =>
      selected != null &&
      date.year == selected!.year &&
      date.month == selected!.month &&
      date.day == selected!.day;

  @override
  Widget build(BuildContext context) {
    final w = size?.width ?? _cellW;
    final h = size?.height ?? _cellH;
    final dayStr = date.day.toString();

    // เช็คว่า วันในช่องนี้ เป็นวันนี้หรืออดีตหรือไม่
    // (เลือกได้เฉพาะพรุ่งนี้เป็นต้นไป)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cellDate = DateTime(date.year, date.month, date.day);
    final isPast = !cellDate.isAfter(today); // วันนี้ + อดีต = กดไม่ได้

    // ฟอนต์หลัก Inter ทั้งหมด
    const textBase = TextStyle(
      fontFamily: 'Inter',
      fontSize: 13.95,
      fontWeight: FontWeight.w500,
      height: 1, // คุม baseline ให้แน่น
    );

    final textNormal = textBase.copyWith(color: const Color(0xFF1F1F1F));
    final textMuted = textBase.copyWith(
      color: const Color(0x26001753),
    ); // โปร่ง
    final textDisabled = textBase.copyWith(
      color: Colors.grey.shade400,
    ); // สีเทาสำหรับวันในอดีต

    // ============ เลือกแล้ว ============
    if (_isSelected) {
      return InkWell(
        borderRadius: BorderRadius.circular(4.65),
        onTap: (_isCurrentMonth && !isPast) ? () => onSelect?.call(date) : null,
        child: Container(
          width: w,
          height: h,
          decoration: ShapeDecoration(
            color: const Color(0xFF5CE1E6), // btn-bg-Primary
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.65),
            ),
          ),
          alignment: Alignment.bottomCenter, // ชิดล่าง
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            dayStr,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 13.95,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      );
    }

    // ============ วันในเดือนปัจจุบัน ============
    if (_isCurrentMonth) {
      if (isPast) {
        // วันในอดีต (กดไม่ได้ + สีเทาอ่อน)
        return Container(
          width: w,
          height: h,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.65),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C000E33),
                blurRadius: 0.78,
                offset: Offset(0, 0.78),
              ),
            ],
          ),
          alignment: Alignment.bottomCenter, // ชิดล่าง
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(dayStr, style: textDisabled, textAlign: TextAlign.center),
        );
      } else {
        // วันปกติ (กดได้ + พื้นหลังขาวเงา)
        return InkWell(
          borderRadius: BorderRadius.circular(4.65),
          onTap: () => onSelect?.call(date),
          child: Container(
            width: w,
            height: h,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.65),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000E33),
                  blurRadius: 0.78,
                  offset: Offset(0, 0.78),
                ),
              ],
            ),
            alignment: Alignment.bottomCenter, // ชิดล่าง
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(dayStr, style: textNormal, textAlign: TextAlign.center),
          ),
        );
      }
    }

    // ============ วันนอกเดือน (กดไม่ได้ + ไม่มีพื้นหลัง) ============
    return Container(
      width: w,
      height: h,
      alignment: Alignment.bottomCenter, // ชิดล่าง
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(dayStr, style: textMuted, textAlign: TextAlign.center),
    );
  }
}
