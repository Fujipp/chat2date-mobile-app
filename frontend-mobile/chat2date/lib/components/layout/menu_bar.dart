import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 0;  

  final List<String> _iconPaths = [
    'assets/icons/icon_home.svg',
    'assets/icons/icon_chat.svg',
    'assets/icons/icon_profile.svg',
    'assets/icons/icon_setting.svg',
  ];

  final List<String> _labels = const ['Home', 'Chat', 'Profile', 'Setting'];

  final Color _unselectedColor = const Color(0xFF0F172A);
  final Color _selectedColor = Colors.white;
  final Color _primaryColor = const Color(0xFF5CE1E6);

  // --- ค่าคงที่สำหรับ Layout ---
  final double _circleSize = 68;
  final double _circleRadius = 68 / 2;
  final double _textContainerWidth = 60;
  final double _bottomNavBarHeight = 65;
  final double _bottomNavBarTopPadding = 25;
  final double _circleTopOffset = -15; // วงกลมลอยสูง

  // --- ค่าคงที่สำหรับรอยเว้า (แบบสมูทและเหลี่ยม) ---
  final double _notchWidth = 92;
  final double _notchSlopeWidth = 16;
  final double _notchDepth = 42;
  final double _notchCornerRadius = 6.4;
  final double _cornerRadius = 6.0;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double zoneWidth = screenWidth / 4;

    final List<double> dynamicCircleLeft = [];
    final List<double> dynamicTextLeft = [];

    for (int i = 0; i < 4; i++) {
      final double zoneCenter = (zoneWidth * (i + 0.5));
      dynamicCircleLeft.add(zoneCenter - _circleRadius);
      dynamicTextLeft.add(zoneCenter - (_textContainerWidth / 2));
    }

    final double totalHeight = _bottomNavBarTopPadding + _bottomNavBarHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. พื้นหลัง (ใช้ Clipper ที่อัปเดตแล้ว)
          Positioned(
            left: 0,
            top: _bottomNavBarTopPadding,
            child: ClipPath(
              clipper: TrapezoidNotchedClipper(
                selectedIndex: _selectedIndex,
                circleLeftPositions: dynamicCircleLeft,
                circleRadius: _circleRadius,
                cornerRadius: _cornerRadius,
                notchTopWidth: _notchWidth,
                notchDepth: _notchDepth,
                notchSlopeWidth: _notchSlopeWidth,
                notchCornerRadius: _notchCornerRadius,
              ),
              child: Container(
                width: screenWidth,
                height: _bottomNavBarHeight,
                decoration: BoxDecoration(color: _primaryColor),
              ),
            ),
          ),

          // 2. วงกลมที่เลื่อนได้
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            left: dynamicCircleLeft[_selectedIndex],
            top: _circleTopOffset,
            child: Container(
              width: _circleSize,
              height: _circleSize,
              decoration: ShapeDecoration(
                color: _primaryColor,
                shape: OvalBorder(),
              ),
            ),
          ),

          // 3. สร้างเมนูทั้ง 4 อัน (ไอคอน + ข้อความ)
          // *** เปลี่ยนจาก Positioned เป็น AnimatedPositioned ***
          ...List.generate(_labels.length, (index) {
            bool isSelected = _selectedIndex == index;

            return AnimatedPositioned(
              // <--- แก้ไขตรงนี้
              duration: const Duration(
                milliseconds: 300,
              ), // <--- เพิ่ม duration
              curve: Curves.easeInOutCubic, // <--- เพิ่ม curve

              left: dynamicTextLeft[index],
              top: isSelected ? _circleTopOffset + 5 : _bottomNavBarTopPadding,
              height: isSelected ? _circleSize : _bottomNavBarHeight,
              width: _textContainerWidth,

              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      _iconPaths[index],
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isSelected ? _selectedColor : _unselectedColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: isSelected ? 4 : 2),
                    Text(
                      _labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? _selectedColor : _unselectedColor,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// 2. คลาส CLIPPER (โค้ดส่วนนี้เหมือนเดิม ไม่ต้องแก้ไข)
// -------------------------------------------------------------------
class TrapezoidNotchedClipper extends CustomClipper<Path> {
  final int selectedIndex;
  final List<double> circleLeftPositions;
  final double circleRadius;
  final double cornerRadius;
  final double notchTopWidth;
  final double notchDepth;
  final double notchSlopeWidth;
  final double notchCornerRadius;

  TrapezoidNotchedClipper({
    required this.selectedIndex,
    required this.circleLeftPositions,
    required this.circleRadius,
    required this.cornerRadius,
    required this.notchTopWidth,
    required this.notchDepth,
    required this.notchSlopeWidth,
    required this.notchCornerRadius,
  });

  @override
  Path getClip(Size size) {
    final double centerX = circleLeftPositions[selectedIndex] + circleRadius;

    final double notchTopStartX = centerX - (notchTopWidth / 2);
    final double notchTopEndX = centerX + (notchTopWidth / 2);

    final double notchBottomStartX = notchTopStartX + notchSlopeWidth;
    final double notchBottomEndX = notchTopEndX - notchSlopeWidth;

    final Path path = Path();
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.lineTo(notchTopStartX, 0);

    // --- 4.1: วาดสโลป `\` แบบเส้นตรง ---
    path.lineTo(notchBottomStartX, notchDepth - notchCornerRadius);

    // --- 4.2: วาดมุมโค้งมน `\_` (Bottom-Left) ---
    path.quadraticBezierTo(
      notchBottomStartX,
      notchDepth,
      notchBottomStartX + notchCornerRadius,
      notchDepth,
    );

    // --- 4.3: เส้นฐาน `_` ---
    path.lineTo(notchBottomEndX - notchCornerRadius, notchDepth);

    // --- 4.4: วาดมุมโค้งมน `_/` (Bottom-Right) ---
    path.quadraticBezierTo(
      notchBottomEndX,
      notchDepth,
      notchBottomEndX,
      notchDepth - notchCornerRadius,
    );

    // --- 4.5: วาดสโลป `/` แบบเส้นตรง ---
    path.lineTo(notchTopEndX, 0);

    // 5. วาดส่วนที่เหลือของ Nav Bar
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
