import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({super.key, this.selectedIndex = 0, this.onTap});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late int _selectedIndex;

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
  final double _circleTopOffset = -15;

  // --- ค่าสำหรับรอยเว้าแบบ Figma (teardrop style) ---
  final double _notchWidth = 100; // ความกว้างรวมของรอยเว้า
  final double _notchDepth = 24; // ความลึกของรอยเว้า (ครึ่งหนึ่งของ notchWidth)
  final double _cornerRadius = 6.0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _handleTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
  }

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
          // 1. พื้นหลัง
          Positioned(
            left: 0,
            top: _bottomNavBarTopPadding,
            child: ClipPath(
              clipper: FigmaTeardropNotchedClipper(
                selectedIndex: _selectedIndex,
                circleLeftPositions: dynamicCircleLeft,
                circleRadius: _circleRadius,
                cornerRadius: _cornerRadius,
                notchWidth: _notchWidth,
                notchDepth: _notchDepth,
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
          ...List.generate(_labels.length, (index) {
            bool isSelected = _selectedIndex == index;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: dynamicTextLeft[index],
              top: isSelected ? _circleTopOffset + 2 : _bottomNavBarTopPadding,
              height: isSelected ? _circleSize : _bottomNavBarHeight,
              width: _textContainerWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _handleTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      _iconPaths[index],
                      width: 30,
                      height: 30,
                      colorFilter: ColorFilter.mode(
                        isSelected ? _selectedColor : _unselectedColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? _selectedColor : _unselectedColor,
                        fontSize: 8,
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
// Custom Clipper แบบ Figma (Teardrop/Petal Style)
// -------------------------------------------------------------------
class FigmaTeardropNotchedClipper extends CustomClipper<Path> {
  final int selectedIndex;
  final List<double> circleLeftPositions;
  final double circleRadius;
  final double cornerRadius;
  final double notchWidth;
  final double notchDepth;

  FigmaTeardropNotchedClipper({
    required this.selectedIndex,
    required this.circleLeftPositions,
    required this.circleRadius,
    required this.cornerRadius,
    required this.notchWidth,
    required this.notchDepth,
  });

  @override
  Path getClip(Size size) {
    final double centerX = circleLeftPositions[selectedIndex] + circleRadius;
    final double radius = notchWidth / 2;

    final double notchStartX = centerX - radius;
    final double notchEndX = centerX + radius;

    // ⭐ ตรวจสอบว่าวงกลมอยู่ใกล้ขอบหรือไม่
    final bool isLeftEdge = notchStartX < cornerRadius + 10;
    final bool isRightEdge = notchEndX > size.width - cornerRadius - 10;

    // 1. เริ่มจากมุมซ้ายบนของ Nav Bar
    final Path path = Path();

    // 2. วาดเส้นไปถึงจุดเริ่มต้นของรอยเว้า
    // 1. มุมซ้ายบน - ถ้าวงกลมอยู่ซ้ายสุด ข้ามมุมโค้ง
    if (isLeftEdge) {
      path.moveTo(0, 0);
      path.lineTo(notchStartX, 0);
    } else {
      path.moveTo(0, cornerRadius);
      path.quadraticBezierTo(0, 0, cornerRadius, 0);
      path.lineTo(notchStartX, 0);
    }

    // 3. วาดรอยเว้าแบบ Figma (teardrop/petal shape)
    path.cubicTo(
      notchStartX + (radius * 0.47),
      notchDepth * 2,
      notchStartX + (radius * 0.35),
      notchDepth * 2,
      centerX,
      notchDepth * 2,
    );

    // ด้านขวา: โค้งขึ้นมา
    path.cubicTo(
      notchEndX - (radius * 0.35),
      notchDepth * 2,
      notchEndX - (radius * 0.47),
      notchDepth * 2,
      notchEndX,
      0,
    );

    // 4. วาดเส้นไปถึงมุมขวาบน
    if (isRightEdge) {
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height - cornerRadius);
    } else {
      path.lineTo(size.width - cornerRadius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
      path.lineTo(size.width, size.height - cornerRadius);
    }

    // 5. วาดด้านขวา
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // 6. วาดด้านล่าง
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
