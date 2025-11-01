import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'stacked_progress_bar.dart';

enum ScoreLeading { svgHeart, number, none }

class ScoreRow extends StatelessWidget {
  const ScoreRow({
    super.key,
    required this.segments,
    this.leading = ScoreLeading.svgHeart,
    this.numberText,
    this.height = 24,
    this.barWidth = 255,
    this.showInfo = true,
    this.heartAsset = 'assets/icons/icon_heart_status.svg',
    this.leadingSize = 22,
    this.numberStyle = const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
      height: 1.0,
    ),
  });

  final List<ProgressSegment> segments;
  final ScoreLeading leading;
  final String? numberText;
  final double height;
  final double barWidth;
  final bool showInfo;
  final String heartAsset;
  final double leadingSize;
  final TextStyle numberStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // leading icon/number/none
          SizedBox(
            width: 25,
            height: leadingSize,
            child: switch (leading) {
              ScoreLeading.svgHeart => Center(
                child: SvgPicture.asset(
                  heartAsset,
                  width: leadingSize,
                  height: leadingSize,
                ),
              ),
              ScoreLeading.number => Center(
                child: Text(
                  numberText ?? '',
                  textAlign: TextAlign.center,
                  style: numberStyle,
                ),
              ),
              ScoreLeading.none => const SizedBox.shrink(),
            },
          ),
          // progress bar
          SizedBox(
            width: barWidth,
            height: height,
            child: StackedProgressBar(segments: segments),
          ),
          // trailing info
          if (showInfo)
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: Colors.black87,
            ),
        ],
      ),
    );
  }
}
