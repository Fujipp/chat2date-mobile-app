import 'package:chat2date/theme/app_colors.dart';
import 'package:chat2date/theme/tokens/typography/body_text_styles.dart';
import 'package:flutter/material.dart';

class DsSegmentedSwitcher extends StatelessWidget {
  const DsSegmentedSwitcher({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.width = 332,
  }) : assert(
         items.length == 2,
         'DsSegmentedSwitcher supports exactly 2 items',
       );

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 39,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;

          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Container(width: 1, height: 10, color: AppColors.inputBorder),
                if (index > 0) const SizedBox(width: 11),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        items[index],
                        textAlign: TextAlign.center,
                        style: AppBodyTextStyles.captionBold.copyWith(
                          color: isSelected
                              ? AppColors.textOnDark
                              : AppColors.textSupport,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
