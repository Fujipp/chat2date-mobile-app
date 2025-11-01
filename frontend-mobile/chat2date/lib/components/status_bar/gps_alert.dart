import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class _AlertActionButton extends StatelessWidget {
  final Widget icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _AlertActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: icon,
      ),
    );
  }
}

class GpsMapAlert extends StatefulWidget {
  const GpsMapAlert({super.key});

  @override
  State<GpsMapAlert> createState() => _GpsMapAlertState();
}

class _GpsMapAlertState extends State<GpsMapAlert> {
  bool _isExpanded = false;
  int _selectedButtonIndex = 0;
  int _emergencyStep = 0;

  final List<String> _emergencyTexts = const [
    'กดอีก 2 ครั้งเพื่อส่งสัญญาณฉุกเฉิน และโทรหาเบอร์ลำดับที่ 1 และแจ้งแอดมิน',
    'กดอีก 1 ครั้งเพื่อส่งสัญญาณฉุกเฉิน และโทรหาเบอร์ลำดับที่ 1 และแจ้งแอดมิน',
    'กดอีก 1 ครั้งเพื่อส่งสัญญาณฉุกเฉิน และโทรหาเบอร์ลำดับที่ 2 และแจ้งแอดมิน',
  ];

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onButtonTapped(int index) {
    setState(() {
      _selectedButtonIndex = index;

      if (index == 2) {
        _emergencyStep = (_emergencyStep < 3) ? _emergencyStep + 1 : 3;
      } else {
        _emergencyStep = 0; // รีเซ็ตถ้ากดปุ่มอื่น
      }

      // ขยายการ์ดอัตโนมัติ *เฉพาะเมื่อ* กดปุ่มฉุกเฉิน
      if (!_isExpanded && index == 2) {
        _isExpanded = true;
      }
    });
  }

  String _getCurrentInstructionText() {
    if (_selectedButtonIndex == 2 &&
        _emergencyStep > 0 &&
        _emergencyStep <= 3) {
      return _emergencyTexts[_emergencyStep - 1];
    }
    return '';
  }

  Widget _buildActionButtons() {
    List<Widget> buttons = [
      _AlertActionButton(
        icon: SvgPicture.asset(
          'assets/icons/icon_locate.svg',
          width: 25,
          height: 25,
        ),
        backgroundColor: AppColors.surfaceMuted,
        onTap: () => _onButtonTapped(0),
      ),
      _AlertActionButton(
        icon: SvgPicture.asset(
          'assets/icons/icon_share.svg',
          width: 25,
          height: 25,
        ),
        backgroundColor: AppColors.surfaceMuted,
        onTap: () => _onButtonTapped(1),
      ),
      _AlertActionButton(
        icon: SvgPicture.asset(
          'assets/icons/icon_emergency.svg',
          width: 25,
          height: 25,
        ),
        backgroundColor: AppColors.surfaceMuted,
        onTap: () => _onButtonTapped(2),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          padding: _isExpanded
              ? const EdgeInsets.all(0)
              : const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER (Always Visible) ---
              GestureDetector(
                onTap: _toggleExpansion,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  margin: _isExpanded
                      ? const EdgeInsets.symmetric(horizontal: 16.0)
                      : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: const Text(
                          'LOCATION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          _isExpanded
                              ? Icons.keyboard_double_arrow_up
                              : Icons.keyboard_double_arrow_down,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!_isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _buildActionButtons(),
                ),

                if (_emergencyStep > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      _getCurrentInstructionText(),
                      style: TextStyle(
                        color: (_selectedButtonIndex == 2 && _emergencyStep > 0)
                            ? AppColors.error
                            : Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],

              // --- EXPANDED STATE CONTENT (Map + Buttons + Text) ---
              if (_isExpanded)
                SizedBox(
                  height: 340.0,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://i.imgur.com/vzclCwF.jpeg',
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: _buildActionButtons(),
                      ),

                      if (_emergencyStep > 0)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12.0,
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: Text(
                            _getCurrentInstructionText(),
                            style: TextStyle(
                              color:
                                  (_selectedButtonIndex == 2 &&
                                      _emergencyStep > 0)
                                  ? AppColors.error
                                  : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
