import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';

class TagSelectionScreen extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<int>? initialSelected;
  final Function(List<int>)? onSelectionChanged;
  final Function(List<int> selectedIndices)? onChanged;

  const TagSelectionScreen({
    super.key,
    required this.title,
    required this.items,
    this.initialSelected,
    this.onSelectionChanged,
    this.onChanged,
  });

  @override
  State<TagSelectionScreen> createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends State<TagSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<int> _selected;

  List<int> _mapFilteredIndicesToOriginalIndices(List<int> filteredIndices) {
    final originalIndices = <int>[];
    final filteredList = _filteredItems;

    // หาชื่อ tag ที่เลือกใน filtered list
    final selectedNames = filteredIndices.map((i) => filteredList[i]).toSet();

    // หา index ของ tag เหล่านี้ใน original list
    for (int i = 0; i < widget.items.length; i++) {
      if (selectedNames.contains(widget.items[i])) {
        originalIndices.add(i);
      }
    }

    return originalIndices;
  }

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected ?? []);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // ต้องตรวจสอบว่าค่าที่เปลี่ยนไปนั้นใหม่จริง ๆ เพื่อหลีกเลี่ยงการเรียก setState ซ้ำซ้อน
    if (_searchQuery != _searchController.text) {
      setState(() {
        _searchQuery = _searchController.text;
      });
    }
  }

  List<String> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where(
          (item) => item.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 135, 20, 0),
                child: DsTextField(
                  controller: _searchController,
                  supportText: widget.title,
                  required: true,
                  suffixIcon: Icons.search,
                ),
              ),

              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'พบ ${_filteredItems.length} รายการ',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                        child: const Text('ล้าง'),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ไม่พบผลลัพธ์',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '"$_searchQuery"',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TagSelection(
                          items: _filteredItems,
                          initialSelected: _selected,
                          shape: TagShape.rectangle,
                          forceGridMode: false,
                          onChanged: (newSelected) {
                            setState(() {
                              _selected = newSelected;
                            });
                            print('Selected in screen: $_selected');
                          },
                        ),
                      ),
              ),
            ],
          ),

          Positioned(
            top: 50,
            left: 16,
            child: InkWell(
              onTap: () => Navigator.pop(
                context,
                _mapFilteredIndicesToOriginalIndices(_selected),
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.brandSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LifestylesSelectionScreen extends StatelessWidget {
  const LifestylesSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    final List<Lifestyle> items = args['items'];
    final List<int> selected = List<int>.from(args['selected']);
    return TagSelectionScreen(
      title: 'ไลฟ์สไตล์',
      items: items.map((l) => l.lifestyle).toList(),
      initialSelected: selected,
      onSelectionChanged: (selected) {
        Navigator.pop(context, selected);
      },
    );
  }
}

class InterestsSelectionScreen extends StatelessWidget {
  const InterestsSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    final List<Interest> items = args['items'];
    final List<int> selected = List<int>.from(args['selected'] ?? []);
    return TagSelectionScreen(
      title: 'สิ่งที่สนใจ',
      items: items.map((l) => l.interest).toList(),
      initialSelected: selected,
      onSelectionChanged: (selected) {
        Navigator.pop(context, selected);
      },
    );
  }
}

class TagsSelectionScreen extends StatelessWidget {
  const TagsSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Tag> items =
        ModalRoute.of(context)!.settings.arguments as List<Tag>;
    return TagSelectionScreen(
      title: 'Tags',
      items: items.map((l) => l.tag).toList(),
      onSelectionChanged: (selected) {
        Navigator.pop(context, selected);
      },
    );
  }
}
