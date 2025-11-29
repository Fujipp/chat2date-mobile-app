import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:chat2date/models/interest.dart';
import 'package:chat2date/models/lifestyle.dart';
import 'package:chat2date/models/tag.dart';
import 'package:chat2date/components/toasts/toast.dart';

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
  String _searchQuery = '';
  late List<int> _selected;

  List<int> _mapFilteredIndicesToOriginalIndices(List<int> filteredIndices) {
    final originalIndices = <int>[];
    final filteredList = _filteredItems;

    final selectedNames = filteredIndices.map((i) => filteredList[i]).toSet();

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
                    : Center(
                        child: SingleChildScrollView(
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

// New Lifestyle Selection Screen with Categories
class LifestylesSelectionScreen extends StatefulWidget {
  const LifestylesSelectionScreen({super.key});

  @override
  State<LifestylesSelectionScreen> createState() =>
      _LifestylesSelectionScreenState();
}

class _LifestylesSelectionScreenState extends State<LifestylesSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
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

  void _toggleSelection(int index) {
    setState(() {
      if (_selected.contains(index)) {
        // อนุญาตให้ยกเลิกการเลือกได้เสมอ
        _selected.remove(index);
      } else {
        // 1. ตรวจสอบจำนวนสูงสุด (5) ก่อนเพิ่มรายการใหม่
        if (_selected.length < 5) {
          _selected.add(index);
          // 2. จัดการความขัดแย้งทันที
          _handleExclusivity(index);
        } else {
          // TODO: แสดง SnackBar/Dialog แจ้งเตือน: "เลือกได้สูงสุด 5 รายการ"
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

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCategorySection(LifestyleCategory category) {
    final categoryItems = _items
        .asMap()
        .entries
        .where(
          (entry) =>
              entry.key >= category.startIndex &&
              entry.key <= category.endIndex,
        )
        .toList();

    // Filter items if search is active
    final filteredCategoryItems = _searchQuery.isEmpty
        ? categoryItems
        : categoryItems
              .where(
                (entry) => entry.value.lifestyle.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    if (filteredCategoryItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.color.withOpacity(0.1),
                  category.color.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: category.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(category.icon, color: category.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredCategoryItems.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Category Items
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filteredCategoryItems.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _selected.contains(index);

              return InkWell(
                onTap: () => _toggleSelection(index),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? category.color : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? category.color : Colors.grey[300]!,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: category.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      Text(
                        item.lifestyle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 30),
              // Search Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: DsTextField(
                  controller: _searchController,
                  supportText: 'ค้นหาไลฟ์สไตล์',
                  required: false,
                  suffixIcon: Icons.search,
                ),
              ),
              // Search Results Info
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
              // Categories List
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
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: lifestyleCategories
                            .map((category) => _buildCategorySection(category))
                            .toList(),
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            // ใช้ Builder เพื่อให้สามารถเข้าถึง context ใหม่สำหรับการแสดง SnackBar
            child: Builder(
              builder: (context) {
                final int selectedCount = _selected.length;
                // กฎ: ต้องเลือก 3, 4, หรือ 5 รายการ
                final bool isValid = selectedCount >= 3 && selectedCount <= 5;
                // กำหนดสี: สีหลักถ้าถูกต้อง / สีแดงถ้าไม่ถูกต้อง
                final Color buttonColor = isValid
                    ? AppColors.brandSecondary
                    : Colors.red.shade700;

                String buttonText;
                if (selectedCount < 3) {
                  // แสดงจำนวนที่ต้องเลือกเพิ่ม
                  buttonText = 'เลือกเพิ่มอีก ${3 - selectedCount} รายการ';
                } else if (selectedCount > 5) {
                  // แสดงการแจ้งเตือนเมื่อเกิน
                  buttonText = 'เลือกเกิน 5 รายการ! กรุณาลบออก';
                } else {
                  // แสดงสถานะที่เลือกสำเร็จ
                  buttonText = 'เลือกแล้ว $selectedCount รายการ • ยืนยัน';
                }

                return InkWell(
                  onTap: isValid
                      ? () =>
                            Navigator.pop(
                              context,
                              _selected,
                            ) // อนุญาตให้ยืนยันเมื่อถูกต้อง
                      : () {
                          // ป้องกันการยืนยันเมื่อเลือกไม่ครบ 3 หรือเกิน 5
                          Toast.show(
                            context,
                            type: selectedCount < 3
                                ? ToastType.warning
                                : ToastType.error,
                            title: selectedCount < 3
                                ? 'ข้อมูลไม่ครบ'
                                : 'จำนวนเกิน',
                            message: selectedCount < 3
                                ? 'กรุณาเลือกอย่างน้อย 3 รายการ'
                                : 'คุณเลือกเกิน 5 รายการ กรุณาลบออกก่อนยืนยัน',
                          );
                        },
                  borderRadius: BorderRadius.circular(30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      // ใช้สีที่คำนวณไว้
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: buttonColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          // เปลี่ยน Icon ตามสถานะ (ถูกต้อง/แจ้งเตือน)
                          isValid ? Icons.check_circle : Icons.warning_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          // ใช้ข้อความที่คำนวณไว้
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

  void _toggleSelection(int index) {
    setState(() {
      if (_selected.contains(index)) {
        // อนุญาตให้ยกเลิกการเลือกได้เสมอ
        _selected.remove(index);
      } else {
        // 1. ตรวจสอบจำนวนสูงสุด (5) ก่อนเพิ่มรายการใหม่
        if (_selected.length < 5) {
          _selected.add(index);
          // * ถ้าไม่มีความขัดแย้งใน Interest ก็ไม่ต้องเรียก _handleExclusivity()
        } else {
          // TODO: แสดง SnackBar/Dialog แจ้งเตือน: "เลือกได้สูงสุด 5 รายการ"
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('คุณเลือกได้สูงสุดเพียง 5 รายการเท่านั้น'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCategorySection(LifestyleCategory category) {
    final categoryItems = widget.items
        .asMap()
        .entries
        .where(
          (entry) =>
              entry.key >= category.startIndex &&
              entry.key <= category.endIndex,
        )
        .toList();

    final filteredCategoryItems = _searchQuery.isEmpty
        ? categoryItems
        : categoryItems
              .where(
                (entry) => entry.value.interest.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    if (filteredCategoryItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.color.withOpacity(0.1),
                  category.color.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: category.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(category.icon, color: category.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredCategoryItems.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filteredCategoryItems.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _selected.contains(index);

              return InkWell(
                onTap: () => _toggleSelection(index),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? category.color : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? category.color : Colors.grey[300]!,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: category.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      Text(
                        item.interest,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: DsTextField(
                  controller: _searchController,
                  supportText: 'ค้นหาสิ่งที่สนใจ',
                  required: false,
                  suffixIcon: Icons.search,
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: interestCategories
                            .map((category) => _buildCategorySection(category))
                            .toList(),
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            // ใช้ Builder เพื่อให้สามารถเข้าถึง context ใหม่สำหรับการแสดง SnackBar
            child: Builder(
              builder: (context) {
                final int selectedCount = _selected.length;
                // กฎ: ต้องเลือก 3, 4, หรือ 5 รายการ
                final bool isValid = selectedCount >= 3 && selectedCount <= 5;
                // กำหนดสี: สีหลักถ้าถูกต้อง / สีแดงถ้าไม่ถูกต้อง
                final Color buttonColor = isValid
                    ? AppColors.brandSecondary
                    : Colors.red.shade700;

                String buttonText;
                if (selectedCount < 3) {
                  // แสดงจำนวนที่ต้องเลือกเพิ่ม
                  buttonText = 'เลือกเพิ่มอีก ${3 - selectedCount} รายการ';
                } else if (selectedCount > 5) {
                  // แสดงการแจ้งเตือนเมื่อเกิน
                  buttonText = 'เลือกเกิน 5 รายการ! กรุณาลบออก';
                } else {
                  // แสดงสถานะที่เลือกสำเร็จ
                  buttonText = 'เลือกแล้ว $selectedCount รายการ • ยืนยัน';
                }

                return InkWell(
                  onTap: isValid
                      ? () =>
                            Navigator.pop(
                              context,
                              _selected,
                            ) // อนุญาตให้ยืนยันเมื่อถูกต้อง
                      : () {
                          // ป้องกันการยืนยันเมื่อเลือกไม่ครบ 3 หรือเกิน 5
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                selectedCount < 3
                                    ? 'กรุณาเลือกอย่างน้อย 3 รายการ'
                                    : 'คุณเลือกเกิน 5 รายการ กรุณาลบออกก่อนยืนยัน',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        },
                  borderRadius: BorderRadius.circular(30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      // ใช้สีที่คำนวณไว้
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: buttonColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          // เปลี่ยน Icon ตามสถานะ (ถูกต้อง/แจ้งเตือน)
                          isValid ? Icons.check_circle : Icons.warning_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          // ใช้ข้อความที่คำนวณไว้
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
