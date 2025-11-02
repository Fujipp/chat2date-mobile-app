import 'package:flutter/material.dart';

/// Tag Selection Component - รองรับ single และ multiple selection
class TagSelection extends StatefulWidget {
  final List<String> items;
  final List<int> initialSelected;
  final bool multiSelect;
  final Function(List<int>)? onChanged;
  final Color selectedColor;
  final Color selectedBorderColor;
  final Color selectedTextColor;
  final Color unselectedColor;
  final Color unselectedBorderColor;
  final Color unselectedTextColor;
  final double spacing;
  final double runSpacing;

  const TagSelection({
    super.key,
    required this.items,
    this.initialSelected = const [],
    this.multiSelect = true,
    this.onChanged,
    this.selectedColor = const Color(0xFFFF8FB3),
    this.selectedBorderColor = const Color(0xFFFF739F),
    this.selectedTextColor = const Color(0xFF0F172A),
    this.unselectedColor = const Color(0xFFF7FAFE),
    this.unselectedBorderColor = const Color(0xFFE2E8F0),
    this.unselectedTextColor = const Color(0xFF94A3B8),
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  @override
  State<TagSelection> createState() => _TagSelectionState();
}

class _TagSelectionState extends State<TagSelection> {
  late List<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
  }

  void _toggleSelection(int index) {
    setState(() {
      if (widget.multiSelect) {
        // Multiple selection
        if (_selected.contains(index)) {
          _selected.remove(index);
        } else {
          _selected.add(index);
        }
      } else {
        // Single selection
        if (_selected.contains(index)) {
          _selected.clear();
        } else {
          _selected = [index];
        }
      }
    });
    widget.onChanged?.call(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: List.generate(
        widget.items.length,
        (index) => _TagItem(
          label: widget.items[index],
          isSelected: _selected.contains(index),
          onTap: () => _toggleSelection(index),
          selectedColor: widget.selectedColor,
          selectedBorderColor: widget.selectedBorderColor,
          selectedTextColor: widget.selectedTextColor,
          unselectedColor: widget.unselectedColor,
          unselectedBorderColor: widget.unselectedBorderColor,
          unselectedTextColor: widget.unselectedTextColor,
        ),
      ),
    );
  }
}

/// Internal Tag Item Widget
class _TagItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedBorderColor;
  final Color selectedTextColor;
  final Color unselectedColor;
  final Color unselectedBorderColor;
  final Color unselectedTextColor;

  const _TagItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.selectedBorderColor,
    required this.selectedTextColor,
    required this.unselectedColor,
    required this.unselectedBorderColor,
    required this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: ShapeDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected ? selectedBorderColor : unselectedBorderColor,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(Icons.check, size: 16, color: selectedTextColor),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedTextColor : unselectedTextColor,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// ตัวอย่างการใช้งาน
// ============================================

class TagSelectionDemo extends StatefulWidget {
  const TagSelectionDemo({super.key});

  @override
  State<TagSelectionDemo> createState() => _TagSelectionDemoState();
}

class _TagSelectionDemoState extends State<TagSelectionDemo> {
  List<int> selectedTags = [0, 2, 4, 6]; // เลือก Style 1, 3, 5, 7

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tag Selection Demo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ตัวอย่างที่ 1: Multiple Selection
            const Text(
              'Multiple Selection (Default)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TagSelection(
              items: const [
                'Style 1',
                'Style 2',
                'Style 3',
                'Style 4',
                'Style 5',
                'Style 6',
                'Style 7',
                'Style 8',
                'Style 9',
              ],
              initialSelected: [0, 2, 4, 6],
              onChanged: (selected) {
                setState(() => selectedTags = selected);
                print('Selected: $selected');
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Selected: ${selectedTags.map((i) => 'Style ${i + 1}').join(', ')}',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // ตัวอย่างที่ 2: Single Selection
            const Text(
              'Single Selection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TagSelection(
              items: const ['Option A', 'Option B', 'Option C', 'Option D'],
              multiSelect: false,
              initialSelected: [1],
              onChanged: (selected) {
                print('Single selected: $selected');
              },
            ),

            const SizedBox(height: 32),

            // ตัวอย่างที่ 3: Custom Colors
            const Text(
              'Custom Colors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TagSelection(
              items: const ['Blue', 'Green', 'Purple', 'Orange'],
              selectedColor: const Color(0xFF5CE1E6),
              selectedBorderColor: const Color(0xFF00B8D4),
              selectedTextColor: Colors.white,
              unselectedColor: Colors.grey[100]!,
              unselectedBorderColor: Colors.grey[300]!,
              initialSelected: [0, 2],
            ),

            const SizedBox(height: 32),

            // ตัวอย่างที่ 4: Compact Spacing
            const Text(
              'Compact Spacing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TagSelection(
              items: const [
                'Tag 1',
                'Tag 2',
                'Tag 3',
                'Tag 4',
                'Tag 5',
                'Tag 6',
              ],
              spacing: 6,
              runSpacing: 6,
              initialSelected: [1, 3, 5],
            ),
          ],
        ),
      ),
    );
  }
}
