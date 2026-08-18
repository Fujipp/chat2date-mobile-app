import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

//แนวนอน
class ContentSwitcher extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final Function(int) onChanged;

  const ContentSwitcher({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 332,
      height: 39,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutralLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5CE1E6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  items[index].toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.inputText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

//2 ปุ่ม
class IconSwitcher extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const IconSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textMuted, width: 1),
      ),
      child: Row(
        children: [
          Expanded(child: _buildIconButton(0, Icons.person)),
          const SizedBox(width: 4),
          Expanded(child: _buildIconButton(1, Icons.people)),
        ],
      ),
    );
  }

  Widget _buildIconButton(int index, IconData icon) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onChanged(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isSelected ? AppColors.btnPrimary : AppColors.textMuted,
          size: 24,
        ),
      ),
    );
  }
}

//Name
class NameSwitcher extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final Function(int) onChanged;

  const NameSwitcher({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.textMuted),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(items.length, (index) {
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: ShapeDecoration(
                  color: isSelected ? AppColors.btnPrimary : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  items[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
