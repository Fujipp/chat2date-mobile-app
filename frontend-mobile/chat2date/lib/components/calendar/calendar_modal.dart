import 'dart:ui';
import 'package:chat2date/components/calendar/calendar_card.dart';
import 'package:flutter/material.dart';

/// CalendarModal — แสดง CalendarCard เป็น Stack overlay
/// เหมือนรูปแบบ SpinWheel ใน inside_chat_screen.dart
///
/// ใช้งาน: ใส่ใน Stack เดียวกับส่วนที่เหลือของหน้า
/// แล้ว control visibility ด้วย bool flag
class CalendarModal extends StatelessWidget {
  final bool isVisible;
  final bool hasUnsavedChanges;
  final bool isReadOnly;

  /// ข้อมูลสถานที่ (จาก spinwheel หรือ existing appointment)
  final String placeName;
  final String placeCountText;

  /// วัน+เวลาเริ่มต้น
  final DateTime initialMonth;
  final TimeOfDay? initialTime;
  /// ★ ใหม่: วันที่ที่เลือกไว้แล้ว (edit mode เท่านั้น) ถ้าเปิดใหม่ให้เป็น null
  final DateTime? initialSelectedDate;

  /// Edit mode: แสดงปุ่มลบ
  final bool isEditMode;

  /// Callbacks
  final void Function(DateTime date, TimeOfDay time)? onSave;
  final void Function(bool hasUnsavedChanges)? onClose;
  final VoidCallback? onTrash;
  final ValueChanged<bool>? onDirtyChanged;

  const CalendarModal({
    super.key,
    required this.isVisible,
    this.hasUnsavedChanges = false,
    this.isReadOnly = false,
    this.placeName = '',
    this.placeCountText = 'คุณมี 1 สถานที่เดต!!',
    required this.initialMonth,
    this.initialTime,
    this.initialSelectedDate,
    this.isEditMode = false,
    this.onSave,
    this.onClose,
    this.onTrash,
    this.onDirtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        // 1. Backdrop สีเข้มจาง (กดเพื่อปิด)
        Positioned.fill(
          child: GestureDetector(
            onTap: () => onClose?.call(hasUnsavedChanges),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: Colors.black.withOpacity(0.45)),
            ),
          ),
        ),

        // 2. CalendarCard ตรงกลาง (เหมือน SpinWheel)
        Positioned.fill(
          top: 85, // เริ่มต้นต่ำกว่า Header (85px)
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CalendarCard(
                      initialMonth: initialMonth,
                      initialTime: initialTime,
                      initialSelectedDate: initialSelectedDate,
                      isEditMode: isEditMode,
                      isReadOnly: isReadOnly,
                      placeName: placeName.isNotEmpty
                          ? placeName
                          : 'ยังไม่ได้เลือกสถานที่',
                      placeCountText: placeCountText,
                      onSave: onSave,
                      onClose: onClose,
                      onDirtyChanged: onDirtyChanged,
                      onTrash: isEditMode && !isReadOnly ? onTrash : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
