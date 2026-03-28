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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SelectorIconButton(
            assetPath: value == DsUserSelectorValue.single
                ? AppAssets.selectorUserSingleActive
                : AppAssets.selectorUserSingleInactive,
            semanticLabel: 'Single user',
            width: 18.53,
            onTap: () => onChanged(DsUserSelectorValue.single),
          ),
          const SizedBox(width: 35),
          _SelectorIconButton(
            assetPath: value == DsUserSelectorValue.group
                ? AppAssets.selectorUserGroupActive
                : AppAssets.selectorUserGroupInactive,
            semanticLabel: 'Group users',
            width: 25.07,
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
    required this.width,
  });

  final String assetPath;
  final String semanticLabel;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 20,
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: width,
            height: 20,
            fit: BoxFit.contain,
            theme: SvgTheme(
              currentColor: assetPath.endsWith('_active.svg')
                  ? AppColors.brandPrimary
                  : AppColors.surface,
            ),
            semanticsLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}
