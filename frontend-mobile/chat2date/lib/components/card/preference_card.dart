import 'package:flutter/material.dart';

class PreferenceCard extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final String? selectedValue;
  final ValueChanged<String>? onChanged;

  const PreferenceCard({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.selectedValue,
    this.onChanged,
  });

  @override
  State<PreferenceCard> createState() => _PreferenceCardState();
}

class _PreferenceCardState extends State<PreferenceCard> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(covariant PreferenceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      setState(() {
        _selectedValue = widget.selectedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: ShapeDecoration(
        color: widget.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: widget.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 💡💡💡 --- START: แก้ไขตรงนี้ --- 💡💡💡
          Column(
            children: [
              Row(
                children: [
                  // 💡 แก้ไข: คอลัมน์ซ้าย (flex: 1)
                  Expanded(
                    flex: 1,
                    child: _buildRadioOption('เหมือนกัน', 'SAME'),
                  ),

                  Expanded(
                    flex: 1,
                    child: _buildRadioOption('คล้ายกัน', 'NEARLY'),
                  ),
                ],
              ),
              const SizedBox(height: 6.0), // ระยะห่างระหว่างแถว
              Row(
                children: [
                  // 💡 แก้ไข: คอลัมน์ซ้าย (flex: 1)
                  Expanded(
                    flex: 1,
                    child: _buildRadioOption('ไม่จำเป็น', 'UNNECESSARY'),
                  ),

                  // 💡 เพิ่ม: ช่องว่างตรงกลาง

                  // 💡 แก้ไข: คอลัมน์ขวา (flex: 1)
                  Expanded(
                    flex: 1,
                    child: _buildRadioOption('ไม่เกี่ยวข้องกัน', 'UNRELATED'),
                  ),
                ],
              ),
            ],
          ),
          // 💡💡💡 --- END: แก้ไขตรงนี้ --- 💡💡💡
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    final bool isSelected = _selectedValue == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedValue = value;
        });
        widget.onChanged?.call(value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          // ใช้ .center เพราะตอนนี้พื้นที่พอแล้ว
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: ShapeDecoration(
                color: isSelected
                    ? const Color(0xFF78CEFF)
                    : const Color(0xFFF7FAFE),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF78CEFF)
                        : const Color(0xFFD1D5DB),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(500),
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 7.5,
                        height: 7.5,
                        decoration: const ShapeDecoration(
                          color: Colors.white,
                          shape: OvalBorder(),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                // ป้องกันการตัดคำ (เผื่อไว้)
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
