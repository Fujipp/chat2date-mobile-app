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
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: Color(0xFFF81919),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // แถวที่ 1
              Row(
                children: [
                  Expanded(child: _buildRadioOption('เหมือนกัน', 'same')),
                  Expanded(child: _buildRadioOption('คล้ายกัน', 'similar')),
                ],
              ),
              const SizedBox(height: 6),
              // แถวที่ 2
              Row(
                children: [
                  Expanded(
                    child: _buildRadioOption('ไม่จำเป็น', 'not_necessary'),
                  ),
                  Expanded(
                    child: _buildRadioOption('ไม่เกี่ยวข้องกัน', 'not_related'),
                  ),
                ],
              ),
            ],
          ),
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

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
