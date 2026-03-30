import 'package:chat2date/components/common/app_raw_scrollbar.dart';
import 'package:chat2date/components/design_system/organisms/ds_app_secondary_header.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/app_gradients.dart';
import 'package:chat2date/core/theme/tokens/colors/input_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:flutter/material.dart';
import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/features/profile/screens/selection_icon_mapper.dart';

// Category configuration
class LifestyleCategory {
  final String title;
  final IconData icon;
  final int startIndex;
  final int endIndex;
  final Color color;

  const LifestyleCategory({
    required this.title,
    required this.icon,
    required this.startIndex,
    required this.endIndex,
    required this.color,
  });
}

// ในไฟล์ที่คุณมี LifestyleCategory
const List<List<int>> mutuallyExclusiveLifestyleIndices = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
  // 👶 แผนการมีครอบครัว (Indices 19-23)
  [19, 20, 21, 22, 23],
  // 🍺 ดื่มเหล้า (Indices 48-53)
  [48, 49, 50, 51, 52, 53],
  // 🚬 สูบบุหรี่ (Indices 54-58)
  [54, 55, 56, 57, 58],
  // 🍃 กัญชา (Indices 59-62)
  [59, 60, 61, 62],
  // 🍽 ตัวเลือกอาหาร (Indices 67-74)
  [67, 68, 69, 70, 71, 72, 73, 74],
  // 😴 รูทีนการนอน (Indices 79-81)
  [79, 80, 81],
];

// Hard-coded categories based on the SQL data
const List<LifestyleCategory> lifestyleCategories = [
  LifestyleCategory(
    title: '🌟 ราศี',
    icon: Icons.star_outline,
    startIndex: 0,
    endIndex: 11,
    color: Color(0xFF9C27B0),
  ),
  LifestyleCategory(
    title: '🎓 การศึกษา',
    icon: Icons.school_outlined,
    startIndex: 12,
    endIndex: 18,
    color: Color(0xFF2196F3),
  ),
  LifestyleCategory(
    title: '👶 แผนการมีครอบครัว',
    icon: Icons.family_restroom_outlined,
    startIndex: 19,
    endIndex: 23,
    color: Color(0xFFFF9800),
  ),
  LifestyleCategory(
    title: '💬 สไตล์การสื่อสาร',
    icon: Icons.chat_bubble_outline,
    startIndex: 24,
    endIndex: 28,
    color: Color(0xFF4CAF50),
  ),
  LifestyleCategory(
    title: '💖 การแสดงความรัก',
    icon: Icons.favorite_outline,
    startIndex: 29,
    endIndex: 33,
    color: Color(0xFFE91E63),
  ),
  LifestyleCategory(
    title: '🐾 สัตว์เลี้ยง',
    icon: Icons.pets_outlined,
    startIndex: 34,
    endIndex: 47,
    color: Color(0xFF795548),
  ),
  LifestyleCategory(
    title: '🍺 ดื่มเหล้า',
    icon: Icons.local_bar_outlined,
    startIndex: 48,
    endIndex: 53,
    color: Color(0xFFFF5722),
  ),
  LifestyleCategory(
    title: '🚬 สูบบุหรี่',
    icon: Icons.smoking_rooms_outlined,
    startIndex: 54,
    endIndex: 58,
    color: Color(0xFF607D8B),
  ),
  LifestyleCategory(
    title: '🍃 กัญชา',
    icon: Icons.eco_outlined,
    startIndex: 59,
    endIndex: 62,
    color: Color(0xFF4CAF50),
  ),
  LifestyleCategory(
    title: '🏃 ออกกำลังกาย',
    icon: Icons.fitness_center_outlined,
    startIndex: 63,
    endIndex: 66,
    color: Color(0xFFF44336),
  ),
  LifestyleCategory(
    title: '🍽 ตัวเลือกอาหาร',
    icon: Icons.restaurant_outlined,
    startIndex: 67,
    endIndex: 74,
    color: Color(0xFFFF9800),
  ),
  LifestyleCategory(
    title: '📱 โซเชียลมีเดีย',
    icon: Icons.phone_android_outlined,
    startIndex: 75,
    endIndex: 78,
    color: Color(0xFF00BCD4),
  ),
  LifestyleCategory(
    title: '😴 รูทีนการนอน',
    icon: Icons.bedtime_outlined,
    startIndex: 79,
    endIndex: 81,
    color: Color(0xFF673AB7),
  ),
];

// Interest categories
const List<LifestyleCategory> interestCategories = [
  LifestyleCategory(
    title: '🌍 การท่องเที่ยว',
    icon: Icons.flight_takeoff,
    startIndex: 0,
    endIndex: 14,
    color: Color(0xFF2196F3),
  ),
  LifestyleCategory(
    title: '🎵 ดนตรี',
    icon: Icons.music_note,
    startIndex: 15,
    endIndex: 29,
    color: Color(0xFFE91E63),
  ),
  LifestyleCategory(
    title: '💪 ออกกำลังกาย',
    icon: Icons.fitness_center,
    startIndex: 30,
    endIndex: 41,
    color: Color(0xFFF44336),
  ),
  LifestyleCategory(
    title: '⚽ กีฬา',
    icon: Icons.sports_soccer,
    startIndex: 42,
    endIndex: 53,
    color: Color(0xFF4CAF50),
  ),
  LifestyleCategory(
    title: '🎬 ภาพยนตร์และซีรีส์',
    icon: Icons.movie,
    startIndex: 54,
    endIndex: 65,
    color: Color(0xFF9C27B0),
  ),
  LifestyleCategory(
    title: '🎨 ศิลปะและความคิดสร้างสรรค์',
    icon: Icons.palette,
    startIndex: 66,
    endIndex: 76,
    color: Color(0xFFFF9800),
  ),
  LifestyleCategory(
    title: '🎮 เกมและเทคโนโลยี',
    icon: Icons.videogame_asset,
    startIndex: 77,
    endIndex: 90,
    color: Color(0xFF00BCD4),
  ),
  LifestyleCategory(
    title: '☕ อาหารและเครื่องดื่ม',
    icon: Icons.restaurant_menu,
    startIndex: 91,
    endIndex: 103,
    color: Color(0xFF795548),
  ),
  LifestyleCategory(
    title: '🌳 กิจกรรมกลางแจ้งและธรรมชาติ',
    icon: Icons.nature_people,
    startIndex: 104,
    endIndex: 118,
    color: Color(0xFF4CAF50),
  ),
  LifestyleCategory(
    title: '🚶 การเดินและไลฟ์สไตล์',
    icon: Icons.directions_walk,
    startIndex: 119,
    endIndex: 128,
    color: Color(0xFF607D8B),
  ),
  LifestyleCategory(
    title: '🎉 ไนท์ไลฟ์และสังคม',
    icon: Icons.nightlife,
    startIndex: 129,
    endIndex: 138,
    color: Color(0xFF673AB7),
  ),
  LifestyleCategory(
    title: '🛍️ ช้อปปิ้งและแฟชั่น',
    icon: Icons.shopping_bag,
    startIndex: 139,
    endIndex: 148,
    color: Color(0xFFE91E63),
  ),
  LifestyleCategory(
    title: '💼 การงานและพัฒนาตนเอง',
    icon: Icons.work_outline,
    startIndex: 149,
    endIndex: 157,
    color: Color(0xFF2196F3),
  ),
  LifestyleCategory(
    title: '🌟 อาสาสมัครและกิจกรรมเพื่อสังคม',
    icon: Icons.volunteer_activism,
    startIndex: 158,
    endIndex: 160,
    color: Color(0xFFFF5722),
  ),
  LifestyleCategory(
    title: '🎓 ภาษาและการศึกษา',
    icon: Icons.translate,
    startIndex: 161,
    endIndex: 166,
    color: Color(0xFF9C27B0),
  ),
];

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
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  late List<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected ?? []);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
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

  List<_SelectionItemData> get _filteredTagItems => widget.items
      .asMap()
      .entries
      .where(
        (entry) => _searchQuery.isEmpty
            ? true
            : entry.value.toLowerCase().contains(_searchQuery.toLowerCase()),
      )
      .map(
        (entry) => _SelectionItemData(
          index: entry.key,
          label: entry.value,
          fallbackIcon: Icons.label_outline,
        ),
      )
      .toList();

  void _toggleTag(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else if (_selected.length < 5) {
        _selected.add(index);
      } else {
        Toast.show(
          context,
          type: ToastType.warning,
          title: 'จำนวน Tag เกิน',
          message: 'สามารถเลือก Tag สูงสุด 5 ข้อ',
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selected.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              DsAppSecondaryHeader(
                variant: DsAppSecondaryHeaderVariant.baseText,
                title: 'Tag',
                onBackTap: () => Navigator.pop(context, _selected),
              ),
              DsTextField(
                controller: _searchController,
                hintText: 'ค้นหา Tag',
                required: false,
                suffixIcon: Icons.search,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Row(
                  children: [
                    Text(
                      'เลือกแล้ว $selectedCount/5 รายการ',
                      style: const TextStyle(
                        color: TextColors.supportText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                child: _filteredTagItems.isEmpty
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
                    : Center(
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: WidgetStateProperty.all(
                              const Color(0xFF5CE1E6).withValues(alpha: 0.7),
                            ),
                            trackColor: WidgetStateProperty.all(
                              Colors.grey.shade300,
                            ),
                            trackBorderColor: WidgetStateProperty.all(
                              Colors.grey.shade400,
                            ),
                          ),
                        child: AppRawScrollbar(
                            controller: _scrollController,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(top: 8),
                              child: _buildSelectionGrid(
                                items: _filteredTagItems,
                                selected: _selected,
                                onToggle: _toggleTag,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const int _minimumSelectionCount = 3;
const int _maximumSelectionCount = 5;

class _SelectionItemData {
  final int index;
  final String label;
  final IconData fallbackIcon;

  const _SelectionItemData({
    required this.index,
    required this.label,
    required this.fallbackIcon,
  });
}

enum _SelectionTileState { selected, enabled, disabled }

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.state,
    required this.onTap,
    required this.span,
    required this.width,
    required this.fallbackIcon,
  });

  final String label;
  final _SelectionTileState state;
  final VoidCallback? onTap;
  final int span;
  final double width;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final bool selected = state == _SelectionTileState.selected;
    final bool disabled = state == _SelectionTileState.disabled;
    final IconData mappedIcon = mapSelectionIcon(
      label,
      fallback: fallbackIcon,
    );
    final Color foreground = selected
        ? TextColors.secondary
        : disabled
            ? TextColors.disabled
            : TextColors.supportText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: width,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.themeApp2 : null,
            color: selected
                ? null
                : disabled
                    ? InputColors.backgroundDisabled
                    : InputColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: InputColors.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mappedIcon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displaySelectionLabel(label),
                  maxLines: span == 1 ? 1 : 2,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int _tileSpanForLabel(String label) {
  final int length = displaySelectionLabel(label).runes.length;
  if (length >= 18) return 3;
  if (length >= 10) return 2;
  return 1;
}

Widget _buildSelectionGrid({
  required List<_SelectionItemData> items,
  required List<int> selected,
  required void Function(int index) onToggle,
}) {
  final bool isAtMax = selected.length >= _maximumSelectionCount;

  return LayoutBuilder(
    builder: (context, constraints) {
      const double spacing = 11;
      const int columns = 3;
      final double singleWidth =
          (constraints.maxWidth - (spacing * (columns - 1))) / columns;

      return Wrap(
        spacing: spacing,
        runSpacing: 15,
        children: items.map((item) {
          final bool isSelected = selected.contains(item.index);
          final bool isDisabled = !isSelected && isAtMax;
          final int span = _tileSpanForLabel(item.label);
          final double width =
              (singleWidth * span) + (spacing * (span - 1));

          return _SelectionTile(
            label: item.label,
            span: span,
            width: width,
            fallbackIcon: item.fallbackIcon,
            state: isSelected
                ? _SelectionTileState.selected
                : isDisabled
                    ? _SelectionTileState.disabled
                    : _SelectionTileState.enabled,
            onTap: isDisabled ? null : () => onToggle(item.index),
          );
        }).toList(),
      );
    },
  );
}

Widget _buildCategorySection({
  required LifestyleCategory category,
  required List<_SelectionItemData> items,
  required List<int> selected,
  required void Function(int index) onToggle,
}) {
  if (items.isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category.icon, size: 18, color: TextColors.secondary),
            const SizedBox(width: 8),
            Text(
              displaySelectionLabel(category.title),
              style: const TextStyle(
                color: TextColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSelectionGrid(
          items: items,
          selected: selected,
          onToggle: onToggle,
        ),
      ],
    ),
  );
}

class _SelectionHelperText extends StatelessWidget {
  const _SelectionHelperText({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final bool valid = selectedCount >= _minimumSelectionCount;
    final int remaining = _minimumSelectionCount - selectedCount;

    return Row(
      children: [
        Text(
          valid
              ? 'เลือกแล้ว $selectedCount/$_maximumSelectionCount รายการ'
              : 'เลือกเพิ่มอีก $remaining รายการ',
          style: TextStyle(
            color: valid ? TextColors.supportText : AppColors.brandSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SelectionEmptyState extends StatelessWidget {
  const _SelectionEmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: TextColors.disabled),
          const SizedBox(height: 12),
          Text(
            'ไม่พบผลลัพธ์',
            style: TextStyle(
              color: TextColors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '"$query"',
              style: TextStyle(
                color: TextColors.supportText,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LifestylesSelectionScreen extends StatefulWidget {
  const LifestylesSelectionScreen({super.key});

  @override
  State<LifestylesSelectionScreen> createState() =>
      _LifestylesSelectionScreenState();
}

class _LifestylesSelectionScreenState extends State<LifestylesSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  late List<int> _selected;
  late List<Lifestyle> _items;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _handleExclusivity(int newSelectedIndex) {
    for (var group in mutuallyExclusiveLifestyleIndices) {
      if (group.contains(newSelectedIndex)) {
        // ถ้า index ใหม่เป็นส่วนหนึ่งของกลุ่มที่ขัดแย้ง
        for (var conflictingIndex in group) {
          // ลบรายการอื่นทั้งหมดในกลุ่มออก ยกเว้นรายการที่เพิ่งเลือกเข้ามาใหม่
          if (conflictingIndex != newSelectedIndex) {
            _selected.remove(conflictingIndex);
          }
        }
        break;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _items = args['items'];
    _selected = List<int>.from(args['selected']);
  }

  void _onSearchChanged() {
    if (_searchQuery != _searchController.text) {
      setState(() {
        _searchQuery = _searchController.text;
      });
    }
  }

  List<Lifestyle> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    return _items
        .where(
          (item) =>
              item.lifestyle.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<_SelectionItemData> get _gridItems => _filteredItems
      .asMap()
      .entries
      .map((entry) => _SelectionItemData(
            index: _items.indexOf(entry.value),
            label: entry.value.lifestyle,
            fallbackIcon: Icons.auto_awesome_outlined,
          ))
      .toList();

  List<Widget> _buildCategorySections() {
    return lifestyleCategories.map((category) {
      final items = _items
          .asMap()
          .entries
          .where(
            (entry) =>
                entry.key >= category.startIndex && entry.key <= category.endIndex,
          )
          .where(
            (entry) => _searchQuery.isEmpty
                ? true
                : entry.value.lifestyle.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
          )
          .map(
            (entry) => _SelectionItemData(
              index: entry.key,
              label: entry.value.lifestyle,
              fallbackIcon: category.icon,
            ),
          )
          .toList();

      return _buildCategorySection(
        category: category,
        items: items,
        selected: _selected,
        onToggle: _toggleSelection,
      );
    }).whereType<Widget>().toList();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        if (_selected.length < _maximumSelectionCount) {
          _selected.add(index);
          _handleExclusivity(index);
        } else {
          Toast.show(
            context,
            type: ToastType.warning,
            title: 'จำนวนเกิน',
            message: 'เลือกได้สูงสุด 5 รายการ',
          );
        }
      }
    });
  }

  bool _canConfirmSelection() => _selected.length >= _minimumSelectionCount;

  Future<bool> _handleBack() async {
    if (_canConfirmSelection()) {
      Navigator.pop(context, _selected);
      return true;
    }

    Toast.show(
      context,
      type: ToastType.warning,
      title: 'เลือกไม่ครบ',
      message: 'กรุณาเลือกอย่างน้อย 3 รายการ',
    );
    return false;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                DsAppSecondaryHeader(
                  variant: DsAppSecondaryHeaderVariant.baseText,
                  title: 'ไลฟ์สไตล์',
                  onBackTap: _handleBack,
                ),
                DsTextField(
                  controller: _searchController,
                  hintText: 'ค้นหาไลฟ์สไตล์',
                  required: false,
                  suffixIcon: Icons.search,
                ),
                const SizedBox(height: 8),
                _SelectionHelperText(selectedCount: _selected.length),
                const SizedBox(height: 16),
                Expanded(
                  child: _gridItems.isEmpty
                    ? _SelectionEmptyState(query: _searchQuery)
                    : ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(
                            const Color(0xFF5CE1E6).withValues(alpha: 0.7),
                          ),
                          trackColor: WidgetStateProperty.all(
                            Colors.grey.shade300,
                          ),
                          trackBorderColor: WidgetStateProperty.all(
                            Colors.grey.shade400,
                          ),
                        ),
                        child: AppRawScrollbar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              children: _buildCategorySections(),
                            ),
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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
    return InterestsSelectionScreenWidget(
      items: items,
      initialSelected: selected,
    );
  }
}

// New Interests Selection Screen with Categories
class InterestsSelectionScreenWidget extends StatefulWidget {
  final List<Interest> items;
  final List<int> initialSelected;

  const InterestsSelectionScreenWidget({
    super.key,
    required this.items,
    required this.initialSelected,
  });

  @override
  State<InterestsSelectionScreenWidget> createState() =>
      _InterestsSelectionScreenWidgetState();
}

class _InterestsSelectionScreenWidgetState
    extends State<InterestsSelectionScreenWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  late List<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchQuery != _searchController.text) {
      setState(() {
        _searchQuery = _searchController.text;
      });
    }
  }

  List<Interest> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where(
          (item) =>
              item.interest.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<_SelectionItemData> get _gridItems => _filteredItems
      .asMap()
      .entries
      .map((entry) => _SelectionItemData(
            index: widget.items.indexOf(entry.value),
            label: entry.value.interest,
            fallbackIcon: Icons.interests_outlined,
          ))
      .toList();

  List<Widget> _buildCategorySections() {
    return interestCategories.map((category) {
      final items = widget.items
          .asMap()
          .entries
          .where(
            (entry) =>
                entry.key >= category.startIndex && entry.key <= category.endIndex,
          )
          .where(
            (entry) => _searchQuery.isEmpty
                ? true
                : entry.value.interest.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
          )
          .map(
            (entry) => _SelectionItemData(
              index: entry.key,
              label: entry.value.interest,
              fallbackIcon: category.icon,
            ),
          )
          .toList();

      return _buildCategorySection(
        category: category,
        items: items,
        selected: _selected,
        onToggle: _toggleSelection,
      );
    }).whereType<Widget>().toList();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        if (_selected.length < _maximumSelectionCount) {
          _selected.add(index);
        } else {
          Toast.show(
            context,
            type: ToastType.warning,
            title: 'จำนวนเกิน',
            message: 'เลือกได้สูงสุด 5 รายการ',
          );
        }
      }
    });
  }

  bool _canConfirmSelection() => _selected.length >= _minimumSelectionCount;

  Future<bool> _handleBack() async {
    if (_canConfirmSelection()) {
      Navigator.pop(context, _selected);
      return true;
    }

    Toast.show(
      context,
      type: ToastType.warning,
      title: 'เลือกไม่ครบ',
      message: 'กรุณาเลือกอย่างน้อย 3 รายการ',
    );
    return false;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                DsAppSecondaryHeader(
                  variant: DsAppSecondaryHeaderVariant.baseText,
                  title: 'สิ่งที่สนใจ',
                  onBackTap: _handleBack,
                ),
                DsTextField(
                  controller: _searchController,
                  hintText: 'ค้นหาสิ่งที่สนใจ',
                  required: false,
                  suffixIcon: Icons.search,
                ),
                const SizedBox(height: 8),
                _SelectionHelperText(selectedCount: _selected.length),
                const SizedBox(height: 16),
                Expanded(
                  child: _gridItems.isEmpty
                    ? _SelectionEmptyState(query: _searchQuery)
                    : ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(
                            const Color(0xFF5CE1E6).withValues(alpha: 0.7),
                          ),
                          trackColor: WidgetStateProperty.all(
                            Colors.grey.shade300,
                          ),
                          trackBorderColor: WidgetStateProperty.all(
                            Colors.grey.shade400,
                          ),
                        ),
                        child: AppRawScrollbar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              children: _buildCategorySections(),
                            ),
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TagsSelectionScreen extends StatelessWidget {
  const TagsSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    late final List<Tag> items;
    List<int>? initialSelected;

    if (args is Map<String, dynamic>) {
      items = (args['items'] as List<Tag>? ?? const <Tag>[]);
      initialSelected = (args['selected'] as List?)?.cast<int>();
    } else {
      items = args as List<Tag>;
    }

    return TagSelectionScreen(
      title: 'Tags',
      items: items.map((l) => l.tag).toList(),
      initialSelected: initialSelected,
      onSelectionChanged: (selected) {
        Navigator.pop(context, selected);
      },
    );
  }
}
