import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:chat2date/components/chat/content_switcher.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpinDateComponent extends StatefulWidget {
  final List<Map<String, dynamic>> prizes;
  final int indexMode;
  final String? firstPersonName;
  final String? secondPersonName;
  final int indexSelected;
  final DateTime? lastRefreshTime;
  final VoidCallback? onCloseModal;
  final VoidCallback? onRefreshSpin;
  final Function(Map<String, dynamic>)? onSpinComplete;
  final Function(
    String? mode,

    String? targetName,

    double radius,

    bool isRefresh,
  )?
  onFilterChanged;

  final int? winningIndex;
  final bool isLeader;
  final VoidCallback? onTriggerSpin;
  final double currentRange;

  const SpinDateComponent({
    super.key,
    required this.prizes,
    this.indexMode = 1,
    this.indexSelected = 1,
    this.firstPersonName = "jack",
    this.secondPersonName = "susie",
    this.onCloseModal,
    this.onRefreshSpin,
    this.onSpinComplete,
    this.onFilterChanged,
    this.lastRefreshTime,
    this.winningIndex,
    this.isLeader = true,
    this.onTriggerSpin,
    this.currentRange = 20.0,
  });

  @override
  State<SpinDateComponent> createState() => _SpinDateComponentState();
}

class _SpinDateComponentState extends State<SpinDateComponent>
    with SingleTickerProviderStateMixin {
  RangeValues selectedRange = const RangeValues(1.0, 20.0);
  late int indexing;
  late int selectedIndex;
  late String? firstName;
  late String? secondName;

  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentRotation = 0.0;

  bool _isReady = false;
  final Map<String, ui.Image> _loadedImages = {};

  @override
  void initState() {
    super.initState();
    indexing = widget.indexMode;
    firstName = widget.firstPersonName;
    secondName = widget.secondPersonName;
    selectedIndex = widget.indexSelected;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _calculateResult();
        Timer(const Duration(seconds: 4), () {
          if (mounted && widget.prizes.isNotEmpty) {
            final winningPlace = widget.prizes[widget.winningIndex!];
            _showWinnerDialog(winningPlace);
          }
        });
      }
    });
    _prepareAssets();
  }

  @override
  void didUpdateWidget(covariant SpinDateComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRange != oldWidget.currentRange) {
      setState(() {
        selectedRange = RangeValues(1.0, widget.currentRange);
      });
    }

    if (widget.prizes != oldWidget.prizes) {
      _prepareAssets();
    }

    if (oldWidget.indexMode != widget.indexMode) {
      setState(() {
        indexing = widget.indexMode;
      });
    }

    if (oldWidget.indexSelected != widget.indexSelected) {
      setState(() {
        selectedIndex = widget.indexSelected;
      });
    }

    if (widget.winningIndex != null &&
        widget.winningIndex != oldWidget.winningIndex) {
      Future.microtask(() => _spinWheel(targetIdx: widget.winningIndex));
    }
  }

  Future<void> _prepareAssets() async {
    if (!mounted) return;
    setState(() => _isReady = false);

    if (widget.prizes.isEmpty) {
      setState(() => _isReady = true);
      return;
    }

    try {
      await Future.wait(
        widget.prizes.map((prize) async {
          final String? url = prize['imageUrl'];
          if (url == null || url.isEmpty || _loadedImages.containsKey(url)) return;

          try {
            final Completer<ui.Image> completer = Completer();
            final stream = NetworkImage(
              url,
            ).resolve(const ImageConfiguration());

            stream.addListener(
              ImageStreamListener(
                (info, _) {
                  if (!completer.isCompleted) completer.complete(info.image);
                },
                onError: (err, _) {
                  if (!completer.isCompleted) completer.completeError(err);
                },
              ),
            );

            final ui.Image img = await completer.future.timeout(
              const Duration(seconds: 10),
            );
            _loadedImages[url] = img;
          } catch (e) {
            debugPrint("Failed to preload: $url");
          }
        }),
      );
    } finally {
      if (mounted) {
        setState(() => _isReady = true);
      }
    }
  }

  void _handleFilterUpdate({bool isRefresh = false}) {
    if (_controller.isAnimating) return;

    if (isRefresh) {
      final now = DateTime.now();

      if (widget.lastRefreshTime != null) {
        final difference = now.difference(widget.lastRefreshTime!);
        if (difference.inSeconds < 60) {
          final remaining = 60 - difference.inSeconds;

          Toast.show(
            context,
            type: ToastType.warning,
            title: 'ใจเย็นๆ ก่อนนะ',
            message: 'กรุณารออีก $remaining วินาที เพื่อกดสุ่มใหม่',
            durationSeconds: 3,
          );
          return;
        }
      }
    }

    String? targetName;
    String? mode;
    if (indexing == 0) {
      if (selectedIndex == 0) {
        targetName = "PARTNER";
      } else {
        targetName = "ME";
      }
      mode = "DISTANCE";
    } else {
      mode = "MIDPOINT";
      targetName = null;
    }

    widget.onFilterChanged?.call(
      mode,
      targetName,
      selectedRange.end,
      isRefresh,
    );

    _resetToInitialState();
  }

  void _spinWheel({int? targetIdx}) {
    if (targetIdx != null) {
      _controller.stop();
      _controller.value = 0.0;
    } else if (_controller.isAnimating || widget.prizes.isEmpty) {
      return;
    }

    double sectorAngle = (2 * pi) / widget.prizes.length;

    int targetIndex = targetIdx ?? Random().nextInt(widget.prizes.length);

    double targetAngle =
        (1.5 * pi) - (targetIndex * sectorAngle) - (sectorAngle / 2);

    double totalRotation = (10 * 2 * pi) + targetAngle;

    setState(() {
      _animation =
          Tween<double>(
            begin: _currentRotation % (2 * pi),
            end: totalRotation,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
          );
    });

    _currentRotation = totalRotation;
    _controller.forward(from: 0.0);
  }

  void _calculateResult() {
    if (widget.prizes.isEmpty) return;

    double finalAngle = _currentRotation % (2 * pi);
    double sectorAngle = (2 * pi) / widget.prizes.length;

    int index = (((1.5 * pi - finalAngle) % (2 * pi)) / sectorAngle).floor();

    if (index < 0) index += widget.prizes.length;

    final Map<String, dynamic> winningPlace = widget.prizes[index];

    _showWinnerDialog(winningPlace);

    widget.onSpinComplete?.call(winningPlace);
  }

  void _showWinnerDialog(Map<String, dynamic> place) {
    final bool hasImage =
        place['imageUrl'] != null && place['imageUrl'].toString().isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'สถานที่เดตของคุณคือ...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 15),
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    place['imageUrl'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // ... loadingBuilder และ errorBuilder เหมือนเดิม
                  ),
                )
              else
                // แสดง Icon Success เมื่อไม่มีรูปภาพ
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.lightBrandSecondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/ui/icon_success_ring.svg",
                    width: 80,
                    height: 80,
                    // colorFilter: ColorFilter.mode(AppColors.brandSecondary700, ui.BlendMode.srcIn), // ถ้าต้องการเปลี่ยนสี icon
                  ),
                ),
              const SizedBox(height: 15),
              Text(
                place['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ตกลง',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetToInitialState() {
    if (_controller.isAnimating) return;

    setState(() {
      _currentRotation = 0.0;
      _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
    });

    _controller.stop();
    _controller.value = 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      width: 333,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: !_isReady
          ? const SizedBox(
              height: 450, // ปรับความสูงช่วงโหลดให้ใกล้เคียงหน้าจริง
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.brandPrimary),
                    SizedBox(height: 16),
                    Text(
                      "กำลังเตรียมสถานที่เดต...",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                if (indexing == 0)
                  NameSwitcher(
                    items: [firstName!, secondName!],
                    selectedIndex: selectedIndex,
                    onChanged: (index) {
                      if (_controller.isAnimating || !widget.isLeader) return;
                      setState(() => selectedIndex = index);
                      _isReady = false;
                      _handleFilterUpdate();
                    },
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 232,
                  height: 232,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(232, 232),
                            painter: _InlineWheelPainter(
                              widget.prizes,
                              _animation.value,
                              _loadedImages, // ✅ ใช้รูปที่โหลดเสร็จแล้ว
                            ),
                          );
                        },
                      ),
                      CustomPaint(
                        size: const Size(232, 232),
                        painter: _StaticNeedlePainter(),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_controller.isAnimating || widget.prizes.isEmpty)
                            return;

                          if (widget.isLeader) {
                            widget.onTriggerSpin?.call();
                          } else {
                            Toast.show(
                              context,
                              type: ToastType.warning,
                              title: 'ใจเย็นๆ',
                              message: 'รอหัวหน้าห้องเป็นคนสุ่มนะ',
                            );
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildBottomUI(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget.isLeader
            ? InkWell(
                onTap: () {
                  if (_controller.isAnimating) return;
                  _isReady = false;
                  _handleFilterUpdate(isRefresh: true);
                  widget.onRefreshSpin?.call();
                },
                child: SvgPicture.asset(
                  "assets/icons/ui/icon_refresh.svg",
                  width: 31,
                ),
              )
            : SvgPicture.asset(
                "assets/icons/ui/icon_seen.svg",
                width: 28,
                colorFilter: const ColorFilter.mode(
                  AppColors.brandAccentStrong,
                  BlendMode.srcIn,
                ),
              ),
        Text(
          'SPIN TO CHOOSE ${widget.isLeader ? "(ผู้คุม)" : "(ผู้ชม)"}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () {
            if (_controller.isAnimating || !widget.isLeader) return;
            widget.onCloseModal?.call();
          },
          child: SvgPicture.asset("assets/icons/ui/icon_close.svg", width: 31),
        ),
      ],
    );
  }

  Widget _buildBottomUI() {
    return Column(
      children: [
        SizedBox(
          width: 308,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('1 กม.', style: TextStyle(fontSize: 12)),
                    Text(
                      '${selectedRange.end.round()} กม.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(
                  context,
                ).copyWith(trackShape: const RectangularSliderTrackShape()),
                child: Slider(
                  value: selectedRange.end,
                  min: 1.0,
                  max: 20.0,
                  activeColor: AppColors.neutral600,
                  inactiveColor: AppColors.neutral300,
                  onChanged: (v) {
                    if (_controller.isAnimating || !widget.isLeader) return;
                    setState(() => selectedRange = RangeValues(1.0, v));
                  },
                  onChangeEnd: (v) {
                    if (!widget.isLeader) return;
                    _isReady = false;
                    _handleFilterUpdate();
                  },
                ),
              ),
            ],
          ),
        ),
        const Text('หมายเหตุ', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 5),
        Text(
          indexing == 0
              ? 'ระบบจะอิงตำแหน่งจุดกึ่งกลางคนหนึ่งที่เลือก \nแล้วใช้ระยะทางที่กำหนดเป็นรัศมีรอบ ๆ จุดกึ่งกลางนั้น \nเพื่อค้นหาสถานที่ที่อยู่ใกล้ ๆ'
              : 'ระบบจะหาตำแหน่งกึ่งกลางระหว่างผู้ใช้งานทั้งสองคน \nแล้วใช้ระยะทางที่กำหนดเป็นรัศมีรอบ ๆ จุดกึ่งกลางนั้น \nเพื่อค้นหาสถานที่ที่อยู่ใกล้ ๆ',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
        if (!widget.isLeader) ...[
          const SizedBox(height: 8),
          const Text(
            '* คุณกำลังอยู่ในโหมดผู้ชม สามารถดูได้อย่างเดียวเท่านั้น',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.error, // ใช้สีแดงแจ้งเตือน
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 15),
        IconSwitcher(
          selectedIndex: indexing,
          onChanged: (index) {
            if (_controller.isAnimating || !widget.isLeader) return;
            setState(() => indexing = index);
            _isReady = false;
            _handleFilterUpdate();
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _InlineWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> prizes;
  final double rotationAngle;
  final Map<String, ui.Image> loadedImages;
  _InlineWheelPainter(this.prizes, this.rotationAngle, this.loadedImages);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = (2 * pi) / prizes.length;

    final List<Color> fallbackColors = [
      AppColors.brandPrimary200,
      AppColors.lightBrandSecondary,
      AppColors.badgeWarning,
      AppColors.info.withOpacity(0.3),
    ];

    // --- 1. วาดส่วนพื้นหลังและรูปภาพ ---
    for (int i = 0; i < prizes.length; i++) {
      final double startAngle = i * sweepAngle + rotationAngle;
      final String? imgUrl = prizes[i]['imageUrl'];
      final ui.Image? img = loadedImages[imgUrl];

      canvas.save();
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();

      canvas.clipPath(path);

      if (img != null) {
        final double currentCenterAngle = startAngle + sweepAngle / 2;
        final double imgX =
            center.dx + (radius * 0.5) * cos(currentCenterAngle);
        final double imgY =
            center.dy + (radius * 0.5) * sin(currentCenterAngle);

        double scale =
            (radius * 1.5) / (img.width < img.height ? img.width : img.height);
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromCenter(
            center: Offset(imgX, imgY),
            width: img.width * scale,
            height: img.height * scale,
          ),
          Paint()..isAntiAlias = true,
        );

        // เพิ่มเงาจางๆ ที่ขอบนอกของแต่ละช่อง
        final shadowPaint = Paint()
          ..shader = ui.Gradient.radial(
            center,
            radius,
            [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.2)],
            [0.7, 1.0],
          );
        canvas.drawPath(path, shadowPaint);
      } else {
        // --- กรณีไม่มีรูป (img == null): ใส่ข้อความเฉียงออกจากจุดศูนย์กลาง ---
        final bgPaint = Paint()
          ..color = fallbackColors[i % fallbackColors.length];
        canvas.drawPath(path, bgPaint); // วาดสีสลับลงไปในช่อง

        // แล้วค่อยวาดข้อความเฉียงออกจากจุดศูนย์กลาง
        final double currentCenterAngle = startAngle + sweepAngle / 2;
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(currentCenterAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: prizes[i]['name'] ?? '',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '...',
        );
        textPainter.layout(maxWidth: radius * 0.75);
        textPainter.paint(
          canvas,
          Offset(radius * 0.25, -textPainter.height / 2),
        );
        canvas.restore();
      }

      // วาดเงาขอบวงล้อ (Vignette) ให้ทุกช่องเพื่อให้ดูมีมิติ
      final shadowPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.1)],
          [0.8, 1.0],
        );
      canvas.drawPath(path, shadowPaint);

      canvas.restore();
    }

    final List<Color> strokeColors = [
      AppColors.btnDisabledSecondary, // สีเขียวเข้ม
      AppColors.info, // สีชมพูเข้ม
    ];

    for (int i = 0; i < prizes.length; i++) {
      final double lineAngle = i * sweepAngle + rotationAngle;

      final dividerPaint = Paint()
        ..color =
            strokeColors[i % strokeColors.length] // สลับสีจาก List ที่เตรียมไว้
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            2 // เพิ่มความหนาเป็น 4.0 เพื่อความชัดเจน
        ..strokeCap =
            StrokeCap.round; // ปลายเส้นมนเพื่อให้จุดบรรจบตรงกลางดูเนียน

      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(lineAngle),
          center.dy + radius * sin(lineAngle),
        ),
        dividerPaint,
      );
    }

    // --- 3. วาดขอบนอก (Outer Rim) และหมุดตรงกลาง (Center Pin) ---
    // ขอบนอก
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.neutral600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // หมุดตรงกลางเพื่อให้เส้นที่มาบรรจบกันดูไม่รก
    canvas.drawCircle(center, 10, Paint()..color = AppColors.background);
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = AppColors.neutral600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _InlineWheelPainter old) =>
      old.rotationAngle != rotationAngle ||
      old.loadedImages.length != loadedImages.length;
}

class _StaticNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final needleLength = radius * 0.38;

    // --- เงา needle ---
    final needlePath = Path()
      ..moveTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx - 9, center.dy + 4)
      ..lineTo(center.dx + 9, center.dy + 4)
      ..close();

    canvas.drawPath(
      needlePath,
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // --- needle body (gradient) ---
    final needlePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx - 9, center.dy),
        Offset(center.dx + 9, center.dy),
        [const Color(0xFFFFFFFF), const Color(0xFFDDDDDD)],
      )
      ..isAntiAlias = true;

    canvas.drawPath(needlePath, needlePaint);

    // ขอบ needle
    canvas.drawPath(
      needlePath,
      Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..isAntiAlias = true,
    );

    // --- เงาปุ่มกลาง ---
    // --- ปุ่มกลาง gradient ---
    final btnPaint = Paint()
      ..shader = ui.Gradient.radial(center.translate(-4, -4), 28, [
        AppColors.brandPrimary,
        AppColors.brandPrimary600,
      ])
      ..isAntiAlias = true;

    canvas.drawCircle(center, 22, btnPaint);

    // --- เงานอก (drop shadow) ---
    canvas.drawCircle(
      center.translate(0, 3),
      23,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // --- ปุ่มหลัก ---
    canvas.drawCircle(
      center,
      22,
      Paint()
        ..shader = ui.Gradient.radial(
          center.translate(0, -6), // highlight ด้านบน
          36,
          [Colors.white, AppColors.brandPrimary, AppColors.brandPrimary600],
          [0.0, 0.45, 1.0],
        )
        ..isAntiAlias = true,
    );

    // --- ขอบวงกลม ---
    canvas.drawCircle(
      center,
      22,
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = true,
    );

    // --- inner shadow (ขอบล่างมืดเล็กน้อย ให้ดูนูน) ---
    canvas.drawCircle(
      center,
      22,
      Paint()
        ..shader = ui.Gradient.radial(
          center.translate(0, 8),
          22,
          [Colors.black.withOpacity(0.15), Colors.transparent],
          [0.4, 1.0],
        ),
    );

    // --- ข้อความ SPIN ---
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SPIN',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.brandOnPrimary,
          letterSpacing: 1.5,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      center.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
