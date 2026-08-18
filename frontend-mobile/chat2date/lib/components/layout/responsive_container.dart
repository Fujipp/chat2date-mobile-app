import 'package:flutter/material.dart';

enum TagShape { rounded, rectangle }

/// Responsive Container - Flexbox-like layout ที่รองรับทุกขนาดหน้าจอ
class ResponsiveContainer extends StatelessWidget {
  final List<Widget> children;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final double gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Color? backgroundColor;
  final bool shrinkWrap;
  final bool useMaxWidth; // ใช้เต็มความกว้างหน้าจอ

  const ResponsiveContainer({
    super.key,
    required this.children,
    this.width,
    this.height,
    this.padding,
    this.gap = 15,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.backgroundColor,
    this.shrinkWrap = false,
    this.useMaxWidth = false,
    required SingleChildScrollView child,
  });

  /// Preset: Standard Screen Layout (responsive)
  /// ใช้เต็มความกว้างหน้าจอ + padding 40/20 + gap 15
  const ResponsiveContainer.screen({
    super.key,
    required this.children,
    this.gap = 15,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.backgroundColor,
  }) : width = null, // ไม่กำหนดความกว้างตายตัว
       height = null,
       padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
       shrinkWrap = false,
       useMaxWidth = true;

  /// Preset: Card Layout
  const ResponsiveContainer.card({
    super.key,
    required this.children,
    this.width,
    this.gap = 12,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.backgroundColor = Colors.white,
  }) : height = null,
       padding = const EdgeInsets.all(20),
       shrinkWrap = true,
       useMaxWidth = false;

  /// Preset: Modal/Dialog Layout
  const ResponsiveContainer.modal({
    super.key,
    required this.children,
    this.width,
    this.gap = 20,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.backgroundColor = Colors.white,
  }) : height = null,
       padding = const EdgeInsets.all(24),
       shrinkWrap = true,
       useMaxWidth = false;

  /// Preset: Form Layout (responsive with max width constraint)
  const ResponsiveContainer.form({
    super.key,
    required this.children,
    this.gap = 15,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.backgroundColor,
  }) : width = null,
       height = null,
       padding = const EdgeInsets.all(20),
       shrinkWrap = false,
       crossAxisAlignment =
           CrossAxisAlignment.stretch, // ให้ input เต็มความกว้าง
       useMaxWidth = true;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _buildChildrenWithGap(),
    );

    // ถ้ามี padding ให้ wrap ด้วย Padding
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // ถ้าต้องการความกว้างเต็มหน้าจอ
    if (useMaxWidth) {
      content = SizedBox(
        width: double.infinity,
        height: height,
        child: backgroundColor != null
            ? Container(color: backgroundColor, child: content)
            : content,
      );
    }
    // ถ้ากำหนด width, height หรือ backgroundColor
    else if (width != null || height != null || backgroundColor != null) {
      content = Container(
        width: width,
        height: height,
        decoration: backgroundColor != null
            ? BoxDecoration(color: backgroundColor)
            : null,
        child: content,
      );
    }

    return content;
  }

  List<Widget> _buildChildrenWithGap() {
    if (children.isEmpty) return [];
    if (gap == 0) return children;

    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(height: gap));
      }
    }
    return result;
  }
}

// ============================================
// ตัวอย่างการใช้งาน - รองรับทุกหน้าจอ
// ============================================

class ResponsiveContainerDemo extends StatelessWidget {
  const ResponsiveContainerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึงขนาดหน้าจอปัจจุบัน
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Screen: ${screenWidth.toInt()}x${screenHeight.toInt()}'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // แสดงขนาดหน้าจอ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Text(
                '📱 หน้าจอของคุณ: ${screenWidth.toInt()}x${screenHeight.toInt()}px\n'
                'Container จะปรับขนาดอัตโนมัติตามหน้าจอ',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // ตัวอย่างที่ 1: Screen Layout (Responsive)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '1. Screen Layout (Responsive - เต็มหน้าจอ)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ResponsiveContainer.screen(
              backgroundColor: Colors.white,
              children: [
                Container(
                  height: 50,
                  color: Colors.blue[100],
                  child: const Center(
                    child: Text('Header (ความกว้างเต็มหน้าจอ)'),
                  ),
                ),
                Container(
                  height: 80,
                  color: Colors.green[100],
                  child: const Center(child: Text('Content 1')),
                ),
                Container(
                  height: 80,
                  color: Colors.orange[100],
                  child: const Center(child: Text('Content 2')),
                ),
                Container(
                  height: 50,
                  color: Colors.red[100],
                  child: const Center(child: Text('Footer')),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ตัวอย่างที่ 2: Form Layout (Responsive)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '2. Form Layout (Input เต็มความกว้าง)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ResponsiveContainer.form(
              backgroundColor: Colors.white,
              children: [
                const Text(
                  'กรอกข้อมูลของคุณ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'ชื่อเล่น',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'อายุ',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFF739F),
                  ),
                  child: const Text('บันทึก'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ตัวอย่างที่ 3: Card Layout (จำกัดความกว้าง)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '3. Card Layout (จำกัดความกว้างไว้)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ResponsiveContainer.card(
                backgroundColor: Colors.white,
                children: [
                  const Text(
                    'Card Title',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Card นี้มีความกว้างตามเนื้อหา + padding 20px',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('ยกเลิก'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('ยืนยัน'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ตัวอย่างที่ 4: Modal Layout
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '4. Modal Layout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ResponsiveContainer.modal(
                backgroundColor: Colors.white,
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const Text(
                    'สำเร็จ!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'ข้อมูลของคุณถูกบันทึกเรียบร้อยแล้ว',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('ปิด'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ตัวอย่างที่ 5: Tag Selection (Responsive)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '5. Tag Selection in Responsive Form',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ResponsiveContainer.form(
              backgroundColor: Colors.white,
              gap: 20,
              children: [
                const Text(
                  'เลือกความสนใจของคุณ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TagSelection(
                  items: const [
                    'ดนตรี',
                    'กีฬา',
                    'ท่องเที่ยว',
                    'อาหาร',
                    'เทคโนโลยี',
                    'ศิลปะ',
                    'หนังสือ',
                    'เกม',
                  ],
                  initialSelected: [0, 2, 4],
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFFF739F),
                    ),
                    child: const Text('ดำเนินการต่อ'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Tag Selection Component (simplified for demo)
class TagSelection extends StatefulWidget {
  final List<String> items;
  final List<int> initialSelected;
  final TagShape shape;
  final bool forceGridMode;
  final bool readOnly;
  final Function(List<int>)? onChanged;

  const TagSelection({
    super.key,
    required this.items,
    this.initialSelected = const [],
    this.shape = TagShape.rounded,
    this.forceGridMode = true,
    this.readOnly = false,
    this.onChanged,
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

  @override
  void didUpdateWidget(covariant TagSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelected != oldWidget.initialSelected ||
        widget.items != oldWidget.items) {
      _selected = List.from(widget.initialSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // กำหนดจำนวน tag ต่อแถว (ตัวอย่าง: 3 tag ต่อแถว)
        double spacing = 8; // gap ระหว่าง tag
        double? itemWidth;

        final bool isGridActive =
            widget.shape == TagShape.rectangle && widget.forceGridMode;

        if (isGridActive) {
          int itemsPerRow = 3;
          double totalSpacing = spacing * (itemsPerRow - 1);
          itemWidth = (constraints.maxWidth - totalSpacing) / itemsPerRow;
        }

        final double? currentSizedBoxWidth = isGridActive ? itemWidth : null;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(widget.items.length, (index) {
            final isSelected = _selected.contains(index);

            return SizedBox(
              width: currentSizedBoxWidth,
              child: GestureDetector(
                onTap: widget.readOnly
                    ? null
                    : () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(index);
                          } else {
                            _selected.add(index);
                          }
                        });
                        widget.onChanged?.call(List.from(_selected));
                      },
                child: Container(
                  padding: widget.shape == TagShape.rounded
                      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                      : const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  height: widget.shape == TagShape.rectangle ? 48 : null,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF8FB3)
                        : const Color(0xFFF7FAFE),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF739F)
                          : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: widget.shape == TagShape.rounded
                        ? BorderRadius.circular(30)
                        : BorderRadius.circular(12),
                  ),
                  child: widget.shape == TagShape.rounded
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(Icons.check, size: 12),
                            ),
                            Text(
                              widget.items[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.items[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
