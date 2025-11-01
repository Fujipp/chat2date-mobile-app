import 'package:flutter/material.dart';

/// สร้างตารางวันของเดือน (ขึ้นต้นที่ Monday)
List<List<DateTime?>> buildMonthMatrix(DateTime anchor) {
  // anchor = วันที่ใด ๆ ในเดือนนั้น
  final first = DateTime(anchor.year, anchor.month, 1);
  // ทำให้เริ่มต้นที่ Monday (จันทร์=1 อาทิตย์=7)
  final int weekdayMonFirst = first.weekday == DateTime.sunday
      ? 7
      : first.weekday;
  final start = first.subtract(Duration(days: weekdayMonFirst - 1));

  final List<List<DateTime?>> weeks = [];
  DateTime cursor = start;
  for (int w = 0; w < 6; w++) {
    final row = <DateTime?>[];
    for (int d = 0; d < 7; d++) {
      row.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    weeks.add(row);
  }
  return weeks;
}

String monthName(int m) {
  // ถ้าใช้ intl จะสวยกว่า (ดูตัวอย่างในท้ายไฟล์หลัก)
  const th = [
    "",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  return th[m];
}

const kTextPrimary = Color(0xFF0F172A);
const kTextMuted = Color(0xFF94A3B8);
