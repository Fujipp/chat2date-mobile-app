import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppRawScrollbar extends StatelessWidget {
  const AppRawScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.radius = const Radius.circular(8),
    this.thickness = 4,
    this.minThumbLength = 48,
    this.thumbVisibility = true,
    this.interactive = true,
    this.edgeInset = 2,
  });

  final Widget child;
  final ScrollController? controller;
  final Radius radius;
  final double thickness;
  final double minThumbLength;
  final bool thumbVisibility;
  final bool interactive;
  final double edgeInset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: edgeInset),
      child: RawScrollbar(
        controller: controller,
        thumbVisibility: thumbVisibility,
        thickness: thickness,
        radius: radius,
        interactive: interactive,
        thumbColor: AppColors.surface,
        minThumbLength: minThumbLength,
        child: child,
      ),
    );
  }
}
