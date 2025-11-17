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

  const TagSelectionScreen({
    super.key,
    required this.title,
    required this.items,
    this.initialSelected,
    this.onSelectionChanged,
  });

  @override
  State<TagSelectionScreen> createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends State<TagSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected ?? []);
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
                        ),
                      ),
              ),
            ],
          ),

          Positioned(
            top: 50,
            left: 16,
            child: InkWell(
              onTap: () => Navigator.pop(context, _selected),
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
    final items = ModalRoute.of(context)!.settings.arguments as List<Lifestyle>;
    return TagSelectionScreen(
      title: 'ไลฟ์สไตล์',
      items: items.map((l) => l.lifestyle).toList(),
      initialSelected: [],
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
    final List<Interest> items = ModalRoute.of(context)!.settings.arguments as List<Interest>;
    return TagSelectionScreen(
      title: 'สิ่งที่สนใจ',
      items: items.map((l) => l.interest).toList(),
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
    final List<Tag> items = ModalRoute.of(context)!.settings.arguments as List<Tag>;
    return TagSelectionScreen(
      title: 'Tags',
      items: items.map((l) => l.tag).toList(),
      onSelectionChanged: (selected) {
        Navigator.pop(context, selected);
      },
    );
  }
}
