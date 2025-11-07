import 'dart:math';
import 'dart:ui';
import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/common/custom_range_slider.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:chat2date/components/buttons/ds_svg_swap_button.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/components/common/style_component.dart';
import 'package:chat2date/components/inputs/index.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/theme/app_colors.dart';

class DiscoveryScreen extends StatefulWidget {
  final String username;
  final List<String> tags;
  final List<Map<String, dynamic>> headerTop;
  final List<Map<String, dynamic>> headerBottom;
  final List<String> images;

  const DiscoveryScreen({
    super.key,
    this.username = "กีกี้",
    this.tags = const ['Tag A', 'Tag B', 'Tag CCCCCC', 'Tag D', 'Tag E'],
    this.headerTop = const [
      {
        'title': 'กีฬา',
        'style': ['Tag A', 'Tag B'],
      },
      {'title': 'ระยะห่าง', 'range': 50.0},
    ],
    this.headerBottom = const [
      {
        'title': 'ไลฟ์สไตล์',
        'style': ['Tag 1', 'Tag 2', 'Tag 3', 'Tag 5', 'Tag 4'],
      },
      {
        'title': 'กีฬา',
        'style': ['Tag A', 'Tag B'],
      },
    ],
    this.images = const [
      'https://media.printler.com/media/photo/193484-2.jpg?rmode=crop&width=638&height=900',
      'https://m.media-amazon.com/images/I/71dAIiXhTQL._AC_UF1000,1000_QL80_.jpg',
      'https://www.ubuy.co.th/productimg/?image=aHR0cHM6Ly9tLm1lZGlhLWFtYXpvbi5jb20vaW1hZ2VzL0kvNjFVR1dxQzNTRUwuX1NMMTM2MF8uanBn.jpg',
    ],
  });

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

enum ActivePanel { none, top, bottom }

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  // --- Panel state ---
  final _topCtrl = PanelController(); // slideDirection: DOWN
  final _bottomCtrl = PanelController(); // slideDirection: UP
  double _posTop = 0.0; // 0..1 ของแผงบน
  double _posBottom = 0.0; // 0..1 ของแผงล่าง
  final ValueNotifier<ActivePanel> activePanel = ValueNotifier(
    ActivePanel.none,
  );

  // --- Card animation (like/unlike) ---
  late final AnimationController _cardCtrl;
  // target values จะปรับทุกครั้งกดปุ่ม
  Offset _startPos = Offset.zero;
  Offset _targetPos = Offset.zero;
  double _startRot = 0;
  double _targetRot = 0;
  double _opacity = 1.0;

  int _index = 0;

  // ---------- Utils ----------

  Color _blurredWhite(double t) {
    if (t < 0.1) return Colors.black.withOpacity(0.01);
    final k = ((t - 0.1) / 0.9).clamp(0.0, 0.5);
    return Colors.white.withOpacity(k);
  }

  void _nextImage() {
    setState(() => _index = (_index + 1) % widget.images.length);
  }

  void _prevImage() {
    setState(
      () => _index = (_index - 1 + widget.images.length) % widget.images.length,
    );
  }

  // --- Card animation: safe & simple ---
  void _animateCard({required Offset to, required double rot}) {
    // reset tween endpoints
    _startPos = Offset.zero;
    _startRot = 0;
    _targetPos = to;
    _targetRot = rot;

    _cardCtrl
      ..stop()
      ..reset();
    _cardCtrl.forward();
  }

  void _onUnlike() => _animateCard(to: const Offset(-500, 0), rot: -pi / 10);
  void _onLike() => _animateCard(to: const Offset(0, 400), rot: 0);

  @override
  void initState() {
    super.initState();
    _cardCtrl =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 380),
          )
          ..addListener(() {
            setState(() {
              // linear 0..1
              final t = _cardCtrl.value;
              // ease opacity out
              _opacity = 1 - t;
            });
          })
          ..addStatusListener((st) async {
            if (st == AnimationStatus.completed) {
              // reset card & go next image
              await Future.delayed(const Duration(milliseconds: 150));
              if (!mounted) return;
              setState(() {
                _index = 0;
                _startPos = Offset.zero;
                _targetPos = Offset.zero;
                _startRot = 0;
                _targetRot = 0;
                _opacity = 1.0;
              });
            }
          });
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    super.dispose();
  }

  // -------------Part Settings Panel------------------

  OverlayEntry? _settingsOverlay;
  bool _isSettingsOpen = false;
  RangeValues _selectedRange = const RangeValues(1, 1900);

  void _togglePanel(BuildContext context) {
    if (_isSettingsOpen) {
      _settingsOverlay?.remove();
      _settingsOverlay = null;
      _isSettingsOpen = false;
      return;
    }

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);

    _settingsOverlay = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setStateOverlay) {
          return Positioned(
            top: offset.dy + 80, // ตำแหน่งต่อจาก header
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ตั้งค่าการค้นหา",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DsLabel(
                          label: 'ช่วงระยะห่างที่คุณอยากเจอ',
                          required: true,
                          labelFontSize: 20,
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedRange.start.round()} Km.',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${_selectedRange.end.round()} Km.',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        CustomRangeSlider(
                          values: _selectedRange,
                          min: 1,
                          max: 1900,
                          divisions: 82,
                          onChanged: (RangeValues values) {
                            setStateOverlay(() {
                              _selectedRange = values;
                            });
                          },
                        ),

                        const SizedBox(height: 10),

                        //เผื่อใช้ ถ้าไม่ใช้ลบไปได้
                        Center(
                          child: DsButton(
                            label: 'ยืนยัน',
                            onPressed: () => {
                              setStateOverlay(() {
                                _isSettingsOpen = false;
                              }),
                              _settingsOverlay?.remove(),
                              _settingsOverlay = null,
                            },
                            fontWeight: FontWeight.w700,
                            size: DsButtonSize.md,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    overlay.insert(_settingsOverlay!);
    _isSettingsOpen = true;
  }

  @override
  Widget build(BuildContext context) {
    // card transforms derive from controller value
    final t = Curves.easeOutCubic.transform(_cardCtrl.value);
    final dx = _startPos.dx + (_targetPos.dx - _startPos.dx) * t;
    final dy = _startPos.dy + (_targetPos.dy - _startPos.dy) * t;
    final rot = _startRot + (_targetRot - _startRot) * t;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 25),
          ChatToDateHeaderWhite(
            leftIconPath: 'assets/icons/icon_chat2date_full.svg',
            rightIconPath: 'assets/icons/icon_menu.svg',
            iconColor: const Color(0xFF5ce1e6),
            onBack: () {},
            onSettings: () => _togglePanel(context),
          ),

          // ===== Canvas (ภาพ + Panels + Overlay) =====
          SizedBox(
            width: double.infinity,
            height: 585,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // --- Profile image (with animation) ---
                Opacity(
                  opacity: _opacity,
                  child: Transform.translate(
                    offset: Offset(dx, dy),
                    child: Transform.rotate(
                      angle: rot,
                      child: Image.network(
                        widget.images[_index],
                        width: double.infinity,
                        height: 585,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // --- Bottom Panel (Slide UP) ---
                if (activePanel.value != ActivePanel.top)
                  ValueListenableBuilder(
                    valueListenable: activePanel,
                    builder: (context, value, _) {
                      if (value == ActivePanel.top)
                        return const SizedBox.shrink();
                      return IgnorePointer(
                        ignoring: activePanel.value == ActivePanel.top,
                        child: SlidingUpPanel(
                          controller: _bottomCtrl,
                          maxHeight: 436,
                          minHeight: 40,
                          color: _blurredWhite(_posBottom),
                          backdropEnabled: value == ActivePanel.bottom,
                          isDraggable: value != ActivePanel.top,
                          panelSnapping: true,
                          collapsed: const Center(
                            child: Icon(
                              Icons.keyboard_double_arrow_up,
                              color: Colors.white,
                            ),
                          ),
                          onPanelSlide: (p) {
                            setState(() {
                              _posBottom = p;
                              if (p > 0) activePanel.value = ActivePanel.bottom;
                            });
                          },
                          onPanelClosed: () {
                            setState(() {
                              _posBottom = 0;
                              if (activePanel.value == ActivePanel.bottom) {
                                activePanel.value = ActivePanel.none;
                              }
                            });
                          },
                          panel: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5 * _posBottom,
                                sigmaY: 5 * _posBottom,
                              ),
                              child: Container(
                                color: Colors.white.withOpacity(
                                  0.2 * _posBottom,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 60,
                                ),
                                child: Column(
                                  children: [
                                    HeadersWithStyles(
                                      headers: widget.headerTop,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // --- Top Panel (Slide DOWN) ---
                if (activePanel.value != ActivePanel.bottom)
                  IgnorePointer(
                    ignoring: activePanel.value == ActivePanel.bottom,
                    child: ValueListenableBuilder(
                      valueListenable: activePanel,
                      builder: (context, value, _) {
                        return SlidingUpPanel(
                          controller: _topCtrl,
                          slideDirection: SlideDirection.DOWN,
                          maxHeight: 436,
                          minHeight: 40,
                          color: _blurredWhite(_posTop),
                          backdropEnabled: value == ActivePanel.top,
                          isDraggable: value != ActivePanel.bottom,
                          panelSnapping: true,
                          collapsed: const Center(
                            child: Icon(
                              Icons.keyboard_double_arrow_down,
                              color: Colors.white,
                            ),
                          ),
                          onPanelSlide: (p) {
                            setState(() {
                              _posTop = p;
                              if (p > 0) activePanel.value = ActivePanel.top;
                            });
                          },
                          onPanelClosed: () {
                            setState(() {
                              _posTop = 0;
                              if (activePanel.value == ActivePanel.top) {
                                activePanel.value = ActivePanel.none;
                              }
                            });
                          },
                          panel: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5 * _posTop,
                                sigmaY: 5 * _posTop,
                              ),
                              child: Container(
                                color: Colors.white.withOpacity(0.2 * _posTop),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      child: HeadersWithStyles(
                                        headers: widget.headerBottom,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // --- Action buttons & overlays (เฉพาะตอน panel ปิด) ---
                ValueListenableBuilder<ActivePanel>(
                  valueListenable: activePanel,
                  builder: (context, value, _) {
                    final panelsClosed = value == ActivePanel.none;

                    if (!panelsClosed) return const SizedBox.shrink();

                    return Positioned(
                      left: 75,
                      bottom: -30,
                      child: DsSvgSwapButton(
                        assetA: 'assets/icons/icon_unlike.svg',
                        assetB: 'assets/icons/icon_unlike_hover.svg',
                        iconSize: 60,
                        glowColor: const Color(0x33FF6B6B),
                        glowBlur: 20,
                        onPressed: _onUnlike,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<ActivePanel>(
                  valueListenable: activePanel,
                  builder: (context, value, _) {
                    final panelsClosed = value == ActivePanel.none;

                    if (!panelsClosed) return const SizedBox.shrink();

                    return Positioned(
                      right: 75,
                      bottom: -30,
                      child: DsSvgSwapButton(
                        assetA: 'assets/icons/icon_like.svg',
                        assetB: 'assets/icons/icon_like_hover.svg',
                        iconSize: 60,
                        glowColor: const Color(0x33FF6B6B),
                        glowBlur: 20,
                        onPressed: _onLike,
                      ),
                    );
                  },
                ),

                // arrows + name + tags
                ValueListenableBuilder<ActivePanel>(
                  valueListenable: activePanel,
                  builder: (context, value, _) {
                    final panelsClosed = value == ActivePanel.none;

                    return Stack(
                      children: [
                        // Panels...
                        if (panelsClosed) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 50,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),
                                Row(
                                  children: [
                                    _ArrowButton(
                                      icon: Icons.chevron_left,
                                      onTap: _prevImage,
                                    ),
                                    const Spacer(),
                                    _ArrowButton(
                                      icon: Icons.chevron_right,
                                      onTap: _nextImage,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 118),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: SizedBox(
                                    width: 311,
                                    child: Text(
                                      widget.username,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Wrap(
                                    spacing: 5,
                                    runSpacing: 7,
                                    children: widget.tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        height: 27,
                                        constraints: const BoxConstraints(
                                          minWidth: 60,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.btnPrimary,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/icon_tag.svg',
                                              width: 24,
                                              height: 24,
                                            ),
                                            Text(
                                              tag,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

// ===== Small helpers =====
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 22,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 50),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}

class _ChipBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ChipBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.28),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
