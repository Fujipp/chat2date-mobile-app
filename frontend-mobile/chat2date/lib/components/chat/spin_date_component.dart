import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class SpinDateFirstPersonComponent extends StatefulWidget {
  final List<Map<String, dynamic>> prizes;

  const SpinDateFirstPersonComponent({super.key, required this.prizes});

  @override
  State<SpinDateFirstPersonComponent> createState() =>
      _SpinDateFirstPersonComponentState();
}

class _SpinDateFirstPersonComponentState
    extends State<SpinDateFirstPersonComponent> {
  final StreamController<int> controller = StreamController<int>();
  RangeValues selectedRange = const RangeValues(1, 1900);


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      height: 539.51,
      width: 333,
      child: Column(
        children: [
          // 🔹 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset("assets/images/refresh.svg", width: 31, height: 31),
              const Text(
                'SPIN TO CHOOSE',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SvgPicture.asset("assets/images/close.svg", width: 21, height: 21),
            ],
          ),

          // 🔹 RangeSlider 1-1900
          Column(
            children: [
              Text(
                'ช่วงที่เลือก: ${selectedRange.start.toInt()} - ${selectedRange.end.toInt()}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RangeSlider(
                min: 1,
                max: 1900,
                divisions: 1900,
                values: selectedRange,
                labels: RangeLabels(
                  selectedRange.start.toInt().toString(),
                  selectedRange.end.toInt().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    selectedRange = values;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
