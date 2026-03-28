import 'package:chat2date/theme/app_assets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DsUserSelectorValue { single, group }

class DsUserSelector extends StatelessWidget {
  const DsUserSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 120,
    this.height = 45,
  });

  final DsUserSelectorValue value;
  final ValueChanged<DsUserSelectorValue> onChanged;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.surface),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SelectorIconButton(
            assetPath: value == DsUserSelectorValue.single
                ? AppAssets.selectorUserSingleActive
                : AppAssets.selectorUserSingleInactive,
            semanticLabel: 'Single user',
            onTap: () => onChanged(DsUserSelectorValue.single),
          ),
          _SelectorIconButton(
            assetPath: value == DsUserSelectorValue.group
                ? AppAssets.selectorUserGroupActive
                : AppAssets.selectorUserGroupInactive,
            semanticLabel: 'Group users',
            onTap: () => onChanged(DsUserSelectorValue.group),
          ),
        ],
      ),
    );
  }
}

class _SelectorIconButton extends StatelessWidget {
  const _SelectorIconButton({
    required this.assetPath,
    required this.semanticLabel,
    required this.onTap,
  });

  final String assetPath;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 26,
        height: 20,
        child: Center(
          child: SvgPicture.asset(assetPath, semanticsLabel: semanticLabel),
        ),
      ),
    );
  }
}
