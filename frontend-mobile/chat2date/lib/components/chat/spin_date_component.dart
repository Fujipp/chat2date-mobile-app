import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat2date/components/chat/content_switcher.dart';

class SpinDateComponent extends StatefulWidget {
  final List<Map<String, dynamic>> prizes;
  final int indexMode;
  final String? firstPersonName;
  final String? secondPersonName;
  final int indexSelected;
  final VoidCallback? onCloseModal;
  final VoidCallback? onRefreshSpin;
  final Function(Map<String, dynamic>)? onSpinComplete;

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
      }
    });
    _prepareAssets();
  }

  @override
  void didUpdateWidget(covariant SpinDateComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prizes != oldWidget.prizes) {
      _prepareAssets();
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
      // โหลดทุกรูปพร้อมกัน และรอจนเสร็จหรือ Timeout 5 วินาที
      await Future.wait(
        widget.prizes.map((prize) async {
          final String? url = prize['imageUrl'];
          if (url == null || _loadedImages.containsKey(url)) return;

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
              const Duration(seconds: 5),
            );
            _loadedImages[url] = img;
          } catch (e) {
            debugPrint("Failed to preload: $url");
          }
        }),
      );
    } finally {
      if (mounted) {
        setState(
          () => _isReady = true,
        ); // โหลดเสร็จแล้ว (หรือพยายามที่สุดแล้ว) ให้โชว์วงล้อ
      }
    }
  }

  void _spinWheel() {
    if (_controller.isAnimating || widget.prizes.isEmpty) return;

    double sectorAngle = (2 * pi) / widget.prizes.length;

    int targetIndex = Random().nextInt(widget.prizes.length);

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
                'สถานที่เดทของคุณคือ...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  place['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
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

      selectedRange = const RangeValues(1.0, 20.0);
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
                      "กำลังเตรียมสถานที่เดท...",
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
                      if (_controller.isAnimating) return;
                      setState(() => selectedIndex = index);
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
                        onTap: _spinWheel,
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
        InkWell(
          onTap: () {
            if (_controller.isAnimating) return;

            _resetToInitialState();

            if (widget.onRefreshSpin != null) {
              widget.onRefreshSpin!();
            }
          },
          child: SvgPicture.asset("assets/icons/icon_refresh.svg", width: 31),
        ),
        const Text(
          'SPIN TO CHOOSE',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () {
            if (_controller.isAnimating) return;
            widget.onCloseModal?.call();
          },
          child: SvgPicture.asset("assets/icons/icon_close.svg", width: 31),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedRange.start.round()} กม.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${selectedRange.end.round()} กม.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              RangeSlider(
                values: selectedRange,
                min: 1.0,
                max: 20.0,
                activeColor: AppColors.neutral600,
                inactiveColor: AppColors.neutral300,
                onChanged: (v) {
                  if (_controller.isAnimating) return;
                  setState(() => selectedRange = v);
                },
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
        const SizedBox(height: 15),
        IconSwitcher(
          selectedIndex: indexing,
          onChanged: (index) {
            if (_controller.isAnimating) return;
            setState(() => indexing = index);
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
    final colors = [
      AppColors.brandPrimary,
      AppColors.brandSecondary,
      AppColors.brandAccentStrong,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
      AppColors.brandPrimary700,
      AppColors.brandSecondary700,
      AppColors.success,
      AppColors.neutral400,
    ];

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);
    for (int i = 0; i < prizes.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle,
        sweepAngle + 0.01,
        true,
        Paint()..color = colors[i % colors.length],
      );
    }
    canvas.restore();

    for (int i = 0; i < prizes.length; i++) {
      final double currentAngle =
          (i * sweepAngle + sweepAngle / 2) + rotationAngle;
      final String? imgUrl = prizes[i]['imageUrl'];
      final ui.Image? img = loadedImages[imgUrl];

      if (img != null) {
        canvas.save();
        final double dist = radius * 0.65;
        final double x = center.dx + dist * cos(currentAngle);
        final double y = center.dy + dist * sin(currentAngle);

        canvas.translate(x, y);
        canvas.rotate(currentAngle + (pi / 2));

        const double imgSize = 35.0;

        final path = Path()
          ..addOval(
            Rect.fromLTWH(-imgSize / 2, -imgSize / 2, imgSize, imgSize),
          );
        canvas.clipPath(path);

        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromLTWH(-imgSize / 2, -imgSize / 2, imgSize, imgSize),
          Paint()..isAntiAlias = true,
        );
        canvas.restore();
      }
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.neutral600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
  }

  @override
  bool shouldRepaint(covariant _InlineWheelPainter old) =>
      old.rotationAngle != rotationAngle ||
      old.loadedImages.length != loadedImages.length;
}

// class _InlineWheelPainter extends CustomPainter {
//   final List<Map<String, dynamic>> prizes;
//   final double rotationAngle;
//   final Map<String, ui.Image> loadedImages;
//   _InlineWheelPainter(this.prizes, this.rotationAngle, this.loadedImages);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
//     final sweepAngle = (2 * pi) / prizes.length;

//     for (int i = 0; i < prizes.length; i++) {
//       final double startAngle = i * sweepAngle + rotationAngle;
//       final String? imgUrl = prizes[i]['imageUrl'];
//       final ui.Image? img = loadedImages[imgUrl];

//       canvas.save();

//       // 1. สร้าง Path รูปพัด (Sector)
//       final path = Path()
//         ..moveTo(center.dx, center.dy)
//         ..arcTo(
//           Rect.fromCircle(center: center, radius: radius),
//           startAngle,
//           sweepAngle,
//           false,
//         )
//         ..close();

//       // 2. ตัดขอบ (Clip) เพื่อวาดรูปในช่อง
//       canvas.clipPath(path);

//       if (img != null) {
//         // คำนวณตำแหน่งและขนาดรูปให้ตั้งตรง
//         final double currentCenterAngle = startAngle + sweepAngle / 2;
//         final double imgX =
//             center.dx + (radius * 0.5) * cos(currentCenterAngle);
//         final double imgY =
//             center.dy + (radius * 0.5) * sin(currentCenterAngle);

//         double scale =
//             (radius * 1.5) / (img.width < img.height ? img.width : img.height);
//         double drawW = img.width * scale;
//         double drawH = img.height * scale;

//         canvas.drawImageRect(
//           img,
//           Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
//           Rect.fromCenter(
//             center: Offset(imgX, imgY),
//             width: drawW,
//             height: drawH,
//           ),
//           Paint()..isAntiAlias = true,
//         );

//         final shadowPaint = Paint()
//           ..shader = ui.Gradient.radial(
//             center,
//             radius,
//             [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.3)],
//             [0.6, 1.0],
//           );
//         canvas.drawPath(path, shadowPaint);
//       } else {
//         canvas.drawPath(path, Paint()..color = Colors.grey.shade200);
//       }

//       canvas.restore();
//     }

//     final dividerPaint = Paint()
//       ..color = Colors.white.withOpacity(0.5)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     for (int i = 0; i < prizes.length; i++) {
//       final double lineAngle = i * sweepAngle + rotationAngle;
//       canvas.drawLine(
//         center,
//         Offset(
//           center.dx + radius * cos(lineAngle),
//           center.dy + radius * sin(lineAngle),
//         ),
//         dividerPaint,
//       );
//     }

//     final outerRimPaint = Paint()
//       ..color = AppColors.neutral600
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 8;

//     canvas.drawCircle(center, radius, outerRimPaint);
//   }

//   @override
//   bool shouldRepaint(covariant _InlineWheelPainter old) =>
//       old.rotationAngle != rotationAngle ||
//       old.loadedImages.length != loadedImages.length;
// }

class _StaticNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final needleLength = radius * 0.35;

    final needlePath = Path()
      ..moveTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx - 9, center.dy)
      ..lineTo(center.dx + 9, center.dy)
      ..close();

    canvas.drawPath(
      needlePath,
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawPath(
      needlePath,
      Paint()
        ..color = Colors.white
        ..isAntiAlias = true,
    );

    canvas.drawCircle(
      center,
      15,
      Paint()
        ..color = AppColors.neutral600
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
