import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomRangeSlider extends StatefulWidget {
  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final double min;
  final double max;
  final double step; // กำหนดขนาดการกระโดดของค่า (เช่น 1)
  final bool snapToStep; // บังคับปัดค่าให้ตรง step
  // ถ้าตั้งค่า จะใช้ SharedPreferences เก็บค่า แยกต่อผู้ใช้ด้วยการต่อท้าย userId
  final String? persistKey; // ตัวอย่าง: 'distanceRange:' + userId

  const CustomRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.step = 1.0,
    this.snapToStep = true,
    this.persistKey,
  }) : assert(step > 0, 'step must be > 0');

  @override
  State<CustomRangeSlider> createState() => _CustomRangeSliderState();
}

class _CustomRangeSliderState extends State<CustomRangeSlider> {
  late RangeValues _values;
  bool _loadedPersisted = false;

  @override
  void initState() {
    super.initState();
    _values = widget.values;
    _maybeLoadPersisted();
  }

  @override
  void didUpdateWidget(covariant CustomRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ถ้าค่าภายนอกเปลี่ยน ให้ sync มาที่ในตัว
    if (oldWidget.values != widget.values) {
      _values = widget.values;
    }
  }

  Future<void> _maybeLoadPersisted() async {
    if (widget.persistKey == null || _loadedPersisted) return;
    final prefs = await SharedPreferences.getInstance();
    final start = prefs.getDouble('${widget.persistKey}:start');
    final end = prefs.getDouble('${widget.persistKey}:end');
    if (start != null && end != null) {
      final loaded = RangeValues(start, end);
      // ป้องกันเลยขอบ
      final clamped = RangeValues(
        loaded.start.clamp(widget.min, widget.max),
        loaded.end.clamp(widget.min, widget.max),
      );
      setState(() {
        _values = clamped;
        _loadedPersisted = true;
      });
      // แจ้งภายนอกให้รู้ค่าที่โหลดมา
      widget.onChanged(clamped);
    } else {
      _loadedPersisted = true;
    }
  }

  Future<void> _persist(RangeValues r) async {
    if (widget.persistKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${widget.persistKey}:start', r.start);
    await prefs.setDouble('${widget.persistKey}:end', r.end);
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 8,
        activeTrackColor: const Color(0xFF6B7280),
        inactiveTrackColor: const Color(0xFFE0E0E0),
        thumbColor: const Color(0xFF6B7280),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayColor: const Color(0xFF6B7280).withValues(alpha: 0.2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: RangeSlider(
        values: _values,
        min: widget.min,
        max: widget.max,
        // กำหนด divisions เพื่อให้ RangeSlider แสดง tick ตาม step
        divisions: ((widget.max - widget.min) / widget.step).round(),
        onChanged: (r) {
          if (!widget.snapToStep) {
            setState(() => _values = r);
            widget.onChanged(r);
            return;
          }
          double snap(double v) {
            final snapped = (v / widget.step).round() * widget.step;
            // ป้องกันเลยขอบ
            if (snapped < widget.min) return widget.min;
            if (snapped > widget.max) return widget.max;
            return snapped;
          }

          final newStart = snap(r.start);
          final newEnd = snap(r.end);
          final snappedRange = RangeValues(newStart, newEnd);
          setState(() => _values = snappedRange);
          widget.onChanged(snappedRange);
        },
        onChangeEnd: (r) async {
          // บันทึกค่าเมื่อปล่อยมือ และแจ้งภายนอก
          await _persist(_values);
          if (widget.onChangeEnd != null) widget.onChangeEnd!(_values);
        },
      ),
    );
  }
}
