import 'package:flutter/material.dart';

//แนวนอน
class ContentSwitcher extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final Function(int) onChanged;

  const ContentSwitcher({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFf8f9fe),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[400]!, width: 1),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.cyan[400] : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  items[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
    Key? key,
    required this.selectedIndex,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      width: 120,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[400]!, width: 1),
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
          color: isSelected ? Colors.cyan[400] : Colors.grey[600],
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
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      width: 120,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[400]!, width: 1),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.cyan[400] : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  items[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
