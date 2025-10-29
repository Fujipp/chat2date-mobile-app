import 'package:flutter/material.dart';

// --- 1. Model Class ---
class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}

// --- 2. CustomPainter for the Notched Bar ---
class NotchedBottomBarPainter extends CustomPainter {
  final int currentIndex;
  final double itemWidth;
  final Color color;

  // Bar styling constants
  final double barBorderRadius = 30.0; // รัศมีขอบโค้งของ Bar
  final double notchRadius =
      38.0; // รัศมีของรอยเว้า (ต้องกว้างกว่าปุ่มลอยเล็กน้อย)
  final double notchDepth = 30.0; // ความลึกของรอยเว้า

  NotchedBottomBarPainter({
    required this.currentIndex,
    required this.itemWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // คำนวณจุดกึ่งกลางของรอยเว้า (Notch)
    final notchCenter = (itemWidth * currentIndex) + (itemWidth / 2);

    // 1. Top Left Corner
    path.moveTo(0, barBorderRadius);
    path.quadraticBezierTo(0, 0, barBorderRadius, 0); // โค้งซ้ายบน

    // 2. Line along the top edge to the notch start
    path.lineTo(notchCenter - notchRadius - 15, 0);

    // 3. Left Notch Curve (Down into notch) - โค้งซ้ายลง
    path.quadraticBezierTo(
      notchCenter - notchRadius + 5,
      0,
      notchCenter - 25,
      notchDepth,
    );

    // 4. Smooth Bottom Arc - ส่วนโค้งที่ก้นรอยเว้า
    path.arcToPoint(
      Offset(notchCenter + 25, notchDepth),
      radius: Radius.circular(30),
      clockwise: false,
    );

    // 5. Right Notch Curve (Up out of notch) - โค้งขวาขึ้น
    path.quadraticBezierTo(
      notchCenter + notchRadius - 5,
      0,
      notchCenter + notchRadius + 15,
      0,
    );

    // 6. Line to Top Right Corner Start
    path.lineTo(size.width - barBorderRadius, 0);

    // 7. Top Right Corner
    path.quadraticBezierTo(size.width, 0, size.width, barBorderRadius);

    // 8. Right Side Down
    path.lineTo(size.width, size.height - barBorderRadius);

    // 9. Bottom Right Corner
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - barBorderRadius,
      size.height,
    );

    // 10. Line across the bottom
    path.lineTo(barBorderRadius, size.height);

    // 11. Bottom Left Corner and Close
    path.quadraticBezierTo(0, size.height, 0, size.height - barBorderRadius);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NotchedBottomBarPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex;
  }
}

// --- 3. Custom Bottom Nav Bar Widget ---
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // กำหนดสีตามรูปภาพ
    final barColor = Color(0xFF5DDEDC); // Cyan/Aqua
    final darkColor = Color(0xFF1A1A1A); // Dark Navy/Black

    return Container(
      // กำหนดความสูงรวม (รวมส่วนที่ปุ่มลอยขึ้นมาด้วย)
      height: 90,
      color: Colors.transparent, // ให้ Container หลักโปร่งใส
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final itemCount = items.length;
          final itemWidth = totalWidth / itemCount;

          return Stack(
            clipBehavior: Clip.none, // สำคัญมากเพื่อให้ปุ่มลอยขึ้นมาได้
            children: [
              // Background bar with notch
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomPaint(
                  // Bar สูง 70px
                  size: Size(totalWidth, 70),
                  painter: NotchedBottomBarPainter(
                    currentIndex: currentIndex,
                    itemWidth: itemWidth,
                    color: barColor,
                  ),
                  child: const SizedBox(height: 70),
                ),
              ),

              // Nav items Row
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 90, // Item containers have max height of 90
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(itemCount, (index) {
                    return _buildNavItem(
                      items[index],
                      index,
                      itemWidth,
                      index == currentIndex,
                      darkColor,
                      barColor,
                      onTap,
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    NavItem item,
    int index,
    double width,
    bool isSelected,
    Color darkColor,
    Color barColor,
    Function(int) onTap,
  ) {
    // การจัดวางปุ่ม (Item)
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: width,
        height: 90,
        alignment: Alignment.bottomCenter, // จัดวางเนื้อหาให้อยู่ด้านล่าง
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              // Floating White Circle (Selected Icon)
              Container(
                width: 65,
                height: 65,
                // ยกปุ่มขึ้นจากตำแหน่งปกติ (-25px)
                // ทำให้ส่วนล่างของปุ่มลอยอยู่เหนือขอบ Bar เล็กน้อย
                transform: Matrix4.translationValues(0, -25, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: darkColor.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  color: darkColor,
                  size: 28,
                ), // Dark icon inside white circle
              )
            else
              // Unselected Icon
              Icon(item.icon, color: darkColor, size: 28),

            // Space between icon and text
            if (!isSelected) const SizedBox(height: 2),

            // Label (Text)
            Padding(
              padding: EdgeInsets.only(
                bottom: isSelected
                    ? 18
                    : 15, // Padding ด้านล่างเพื่อให้ Text อยู่บน Bar
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  // Text สีขาวสำหรับปุ่มที่ถูกเลือก (ตามรูปภาพ)
                  color: isSelected ? Colors.white : darkColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. Example Usage (Stateful Widget) ---
class CustomNavBarExample extends StatefulWidget {
  const CustomNavBarExample({super.key});

  @override
  State<CustomNavBarExample> createState() => _CustomNavBarExampleState();
}

class _CustomNavBarExampleState extends State<CustomNavBarExample> {
  int _currentIndex =
      3; // Setting (index 3) is selected by default to match the image

  final List<NavItem> navItems = [
    NavItem(icon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.chat_bubble, label: 'Chat'),
    NavItem(icon: Icons.person, label: 'Profile'),
    NavItem(icon: Icons.settings, label: 'Setting'),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody:
          true, // ทำให้ Body สามารถทับพื้นที่ของ Bottom Bar ได้ (สำคัญสำหรับ Bar ที่มี notch)
      appBar: AppBar(
        title: const Text('Custom Notched Bottom Bar'),
        backgroundColor: Color(0xFF5DDEDC),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Selected Tab: ${navItems[_currentIndex].label}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      // Use the custom bottom navigation bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: navItems,
      ),
    );
  }
}
