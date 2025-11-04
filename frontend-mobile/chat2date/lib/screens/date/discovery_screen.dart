import 'dart:math';
import 'dart:ui';
import 'package:chat2date/components/buttons/ds_svg_swap_button.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:flutter/widgets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/scheduler.dart';
import 'package:chat2date/components/inputs/index.dart';

class DiscoveryScreen extends StatefulWidget {
  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with TickerProviderStateMixin {
  double _panelPosition = 0.0;
  double _panelHeight = 40;
  final double _minHeight = 40;
  final double _maxHeight = 436;
  double _cardX = 0;
  double _cardY = 0;
  double _cardRotation = 0;
  double _cardOpacity = 1;
  bool _isAnimating = false;
  late Ticker _ticker;
  bool _isPressingLeft = false;
  bool _isPressingRight = false;

  late AnimationController _controller;
  late Animation<double> _animX;
  late Animation<double> _animY;
  late Animation<double> _animRotation;

  //ส่วนการแสดงผล หน้า slidingdown + up
  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _panelHeight += details.delta.dy;
      _panelHeight = _panelHeight.clamp(_minHeight, _maxHeight);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final midpoint = (_minHeight + _maxHeight) / 2;
    setState(() {
      _panelHeight = _panelHeight > midpoint ? _maxHeight : _minHeight;
    });
  }

  void _togglePanel() {
    setState(() {
      _panelHeight = _panelHeight == _minHeight ? _maxHeight : _minHeight;
    });
  }

  Color _getPanelColor() {
    if (_panelPosition < 0.1) {
      // ถ้าเปิดน้อยกว่า 10% → ยังโปร่งใส
      return Colors.transparent;
    } else {
      // ถ้าเปิดเกิน 10% → ค่อย ๆ ขาวขึ้น
      double opacity =
          (_panelPosition - 0.1) / 0.9; // ทำให้เริ่มค่อยๆ จางหลัง 10%
      opacity = opacity.clamp(0.0, 0.2); // จำกัดค่าสูงสุด 0.85
      return Colors.white.withOpacity(opacity);
    }
  }

  void _throwLeft() {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);
    _animateCard(targetX: -500, targetY: 0, rotation: -pi / 10);
  }

  void _saveRight() {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);
    _animateCard(targetX: 0, targetY: 400, rotation: 0);
  }

  void _animateCard({
    required double targetX,
    required double targetY,
    required double rotation,
  }) {
    const duration = Duration(milliseconds: 400);
    final startX = _cardX;
    final startY = _cardY;
    final startRot = _cardRotation;

    _ticker = createTicker((elapsed) {
      final t = (elapsed.inMilliseconds / duration.inMilliseconds).clamp(
        0.0,
        1.0,
      );
      setState(() {
        _cardX = startX + (targetX - startX) * t;
        _cardY = startY + (targetY - startY) * t;
        _cardRotation = startRot + (rotation - startRot) * t;
        _cardOpacity = 1 - t;
      });

      if (t >= 1) {
        _ticker.stop();
        Future.delayed(const Duration(milliseconds: 200), _resetCard);
      }
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _resetCard() {
    setState(() {
      _cardX = 0;
      _cardY = 0;
      _cardRotation = 0;
      _cardOpacity = 1;
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
          children: [
            SizedBox(height: 25),
            ChatToDateHeaderWhite(
              leftIconPath: 'assets/icons/icon_chat2date_full.svg',
              rightIconPath: 'assets/icons/icon_menu.svg',
              iconColor: Color(0xFF5ce1e6),
              onBack: () {},
              onSettings: () {},
            ),
            SizedBox(
              width: double.infinity,
              height: 585,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedOpacity(
                    opacity: _cardOpacity,
                    duration: const Duration(milliseconds: 100),
                    child: Transform.translate(
                      offset: Offset(_cardX, _cardY),
                      child: Transform.rotate(
                        angle: _cardRotation,
                        child: ClipRRect(
                          child: Image.asset(
                            'assets/images/image_majiko.jpg', 
                            width: double.infinity,
                            height: 585,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if(_panelHeight == 40)
                  SlidingUpPanel(
                    maxHeight: 436,
                    minHeight: 40,
                    color: _getPanelColor(),
                    collapsed: const Center(
                      child: Icon(
                        Icons.keyboard_double_arrow_up,
                        color: Colors.white,
                      ),
                    ),
                    onPanelSlide: (pos) {
                      setState(() => _panelPosition = pos);
                    },
                    panel: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 5,
                          sigmaY: 5,
                        ), // ทำให้พื้นหลังเบลอเล็กน้อย
                        child: Container(
                          color: Colors.white.withOpacity(
                            0.2 * _panelPosition,
                          ), // สีขาวจางๆ
                          child: const Center(
                            child: Text(
                              'แท็บล่าง (SlidingUpPanel)',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if(_panelPosition < 0.1)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: _panelHeight,
                    child: GestureDetector(
                      onVerticalDragUpdate: _onDragUpdate,
                      onVerticalDragEnd: _onDragEnd,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX:
                                10 *
                                ((_panelHeight - _minHeight) /
                                    (_maxHeight - _minHeight)),
                            sigmaY:
                                10 *
                                ((_panelHeight - _minHeight) /
                                    (_maxHeight - _minHeight)),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            color: (_panelHeight == _minHeight)
                                ? Colors.transparent
                                : Colors.white.withOpacity(
                                    0.15 +
                                        0.35 *
                                            ((_panelHeight - _minHeight) /
                                                (_maxHeight - _minHeight)),
                                  ),
                            child: Column(
                              children: [
                                // แถบจับเลื่อน
                                GestureDetector(
                                  onTap: _togglePanel,
                                  child: Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.keyboard_double_arrow_down,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                // เนื้อหาภายใน panel
                                Expanded(
                                  child: Opacity(
                                    opacity:
                                        (_panelHeight - _minHeight) /
                                        (_maxHeight - _minHeight),
                                    child: SingleChildScrollView(
                                      physics:
                                          (_panelHeight - _minHeight) /
                                                  (_maxHeight - _minHeight) >
                                              0.9
                                          ? const BouncingScrollPhysics()
                                          : const NeverScrollableScrollPhysics(),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "รายละเอียด",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "นี่คือตัวอย่างเนื้อหาที่จะปรากฏเมื่อ panel ขยายเต็ม",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            for (int i = 0; i < 5; i++)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                    ),
                                                child: Text(
                                                  "รายการ ${i + 1}",
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.95),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if(_panelPosition < 0.1 && _panelHeight == 40)
                  Positioned(
                    left: 75,
                    bottom: -30,
                    child: DsSvgSwapButton(
                      assetA: 'assets/icons/icon_unlike.svg',
                      assetB: 'assets/icons/icon_unlike_hover.svg',
                      iconSize: 60,
                      glowColor: const Color(0x33FF6B6B),
                      glowBlur: 20,
                      onPressed: () {
                        _throwLeft();
                      },
                      previewHoverLook: true,
                    ),
                  ),
                  if(_panelPosition < 0.1 && _panelHeight == 40)
                  Positioned(
                    right: 75,
                    bottom: -30,
                    child: DsSvgSwapButton(
                      assetA: 'assets/icons/icon_like.svg',
                      assetB: 'assets/icons/icon_like_hover.svg',
                      iconSize: 60,
                      glowColor: const Color(0x33FF6B6B),
                      glowBlur: 20,
                      onPressed: () {
                        _saveRight();
                      },
                      previewHoverLook: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 50,
                      horizontal: 16,
                    ), // กำหนด padding ที่ต้องการ
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        Row(
                          children: [
                            SizedBox(
                              width: 30,
                              height: 36,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 30,
                              height: 36,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 117.38),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: 311,
                            child: Text(
                              'เมจิโกะ',
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Wrap(
                            spacing: 5, // ระยะห่างแนวนอนระหว่าง tags
                            runSpacing: 7,
                            children: List.generate(5, (index) {
                              return SizedBox(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.btnPrimary,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 60, // กำหนด width ขั้นต่ำ
                                      ),
                                      height: 27,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/icon_tag.svg',
                                            width: 24,
                                            height: 24,
                                          ),
                                          Text(
                                            'Tag ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
//Padding(
                //padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                //child: