import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/common/loading_component.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/models/user_has_interest.dart';
import 'package:chat2date/models/user_has_lifestyle.dart';
import 'package:chat2date/models/user_has_tag.dart';
import 'package:chat2date/models/user_has_travelstyle.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:chat2date/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  String nickname = "";
  String? _selectedGenderPreference = "";
  double behaviorScore = 0;
  List<UserHasInterest> user_has_interest = [];
  List<UserHasLifestyle> user_has_lifestyle = [];
  List<UserHasTravelstyle> user_has_travelstyle = [];
  List<UserHasTag> user_has_tag = [];
  String interestGender = "";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final userStore = ref.read(userStoreProvider) as Map<String, dynamic>?;
    final userId = userStore?['user']?['userId'];
    final accessToken = userStore?['accessToken'];
    final userById = await ref.read(userServiceProvider).getUser(userId);
    ref.read(userStoreProvider.notifier).setUser(userById, accessToken);
    final userService = ref.read(userServiceProvider);
    final userProfile = await userService.getProfile(userId);
    user_has_interest = userProfile['interests'];
    user_has_lifestyle = userProfile['lifeStyles'];
    user_has_tag = userProfile['tags'];
    user_has_travelstyle = userProfile['travelStyles'];
    interestGender = userProfile['interestedGender'];
    
    //interestGender = userProfile['']

    

    setState(() {
      nickname = userStore?['user']?['nickname'];
      behaviorScore = (userStore?['user']?['behaviorScore'])/100;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ป้องกัน memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: ChatToDateHeaderWhite(
              leftIconPath: 'assets/images/logo_chat2date_text.png',
              rightIconPath: 'assets/icons/icon_menu.svg',
              iconColor: const Color(0xFF5ce1e6),
              onBack: () {},
              onSettings: () {},
            ),
          ),
          Expanded(
            child: ScrollbarTheme(
              // <--- 1. เพิ่ม ScrollbarTheme เพื่อกำหนดสี
              data: ScrollbarThemeData(
                // ---- นี่คือส่วนที่เพิ่มสีครับ ----
                // สีของแท่ง Scrollbar (thumb)
                thumbColor: WidgetStateProperty.all(
                  const Color(0xFF5ce1e6).withOpacity(
                    0.7,
                  ), // สีฟ้าอมเขียว (สีเดียวกับไอคอน) แบบโปร่งแสง
                ),
                // สีของราง (track)
                trackColor: WidgetStateProperty.all(Colors.grey.shade300),
                // สีขอบของราง (ถ้าต้องการ)
                trackBorderColor: WidgetStateProperty.all(Colors.grey.shade400),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(8),
                interactive:
                    true, // <--- 2. เพิ่มตัวนี้เพื่อให้ Scrollbar เลื่อนได้!
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: ResponsiveContainer.form(
                    children: [
                      DsTextField(
                        label: 'ชื่อเล่น',
                        labelFontSize: 20,
                        controller: TextEditingController(text: nickname),
                      ),

                      // DsTextField(
                      //   label: 'เพศที่สนใจ',
                      //   labelFontSize: 20,
                      //   suffixIcon: Icons.keyboard_arrow_down_rounded,
                      // ),
                      DropdownButtonFormField2<String>(
                        value: _selectedGenderPreference,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'เพศที่สนใจ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.red, // สีแดงของ *
                                  ),
                                ),
                              ],
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.inputBorderHover,
                              width: 1.5,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),

                        isExpanded: true,

                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),

                        // 👇👇 เพิ่มส่วนนี้เพื่อให้เมนูอยู่ล่างเสมอ
                        dropdownStyleData: const DropdownStyleData(
                          offset: Offset(0, 0), // เมนูเริ่มล่างช่อง
                          direction: DropdownDirection
                              .textDirection, // บังคับอยู่ด้านล่าง
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: 'SAME',
                            child: Text('เพศเดียวกัน'),
                          ),
                          DropdownMenuItem(
                            value: 'OPPOSITE',
                            child: Text('เพศตรงข้าม'),
                          ),
                          DropdownMenuItem(
                            value: 'BOTH',
                            child: Text('ได้ทั้งหมด'),
                          ),
                        ],

                        onChanged: (value) {
                          setState(() {
                            _selectedGenderPreference = value;
                          });
                        },
                      ),

                      DsLabel(label: 'แก้ไขรูปภาพที่แสดง', labelFontSize: 20),
                      ImageUploadGrid(
                        onImagesChanged: (images) {
                          print('จำนวนรูปที่เลือก: ${images.length}');
                        },
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DsLabel(
                            label: 'สไตล์การท่องเที่ยว',
                            labelFontSize: 20,
                          ),
                          const SizedBox(height: 0),
                          TagSelection(
                            items: [
                              'Style 1',
                              'Style 2Style',
                              'Style 3',
                              'Style 4',
                              'Style 5Style',
                              'Style 6',
                              'Style 7Style',
                              'Style 8',
                              'Style 9',
                            ],
                          ),
                        ],
                      ),

                      // ไลฟ์สไตล์
                      DsTextField(
                        label: 'ไลฟ์สไตล์',

                        suffixIcon: Icons.arrow_circle_right_rounded,
                        onSuffixTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/lifestylesSelection',
                          );
                        },
                        labelFontSize: 20,
                      ),

                      // สิ่งที่สนใจ
                      DsTextField(
                        label: 'สิ่งที่สนใจ',

                        suffixIcon: Icons.arrow_circle_right_rounded,
                        onSuffixTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/interestsSelection',
                          );
                        },
                        labelFontSize: 20,
                      ),

                      // Tags
                      DsTextField(
                        label: 'tags(ไม่บังคับ)',
                        required: false,
                        suffixIcon: Icons.add,
                        hintText: 'เพิ่มแท็กที่นี่',
                        onSuffixTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/tagsSelection',
                          );
                        },
                        labelFontSize: 20,
                      ),

                      DsLabel(label: 'คะแนนความประพฤติ', labelFontSize: 20),
                      CircularLoading(percent: 0.75),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // หัวข้ออยู่ใน card เลย
                              DsLabel(
                                label: 'เกณฑ์คะแนนความประพฤติ',
                                labelFontSize: 16,
                              ),

                              const SizedBox(height: 12),

                              // เงื่อนไขเป็นบรรทัดย่อย (ใช้ Text.rich เพื่อเน้นตัวหนา)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'ถ้าคะแนน ≤ 50 : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'บัญชีจะถูกจำกัดฟีเจอร์ 3 วัน และปัดได้ไม่เกิน 10 ครั้ง/วัน',
                                    ),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'ถ้าคะแนน < 30 : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'บัญชีจะถูกแบนถาวร และถูกใส่ใน Blacklist (ห้ามกลับมาใช้งาน)',
                                    ),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Divider(),

                              const SizedBox(height: 12),

                              const Text(
                                'วิธีได้คะแนนเพิ่ม',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // รายการวิธีได้คะแนน (แสดงเป็นบูลเล็ตหรือ arrow)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('• ', style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      'อยู่ครบ 30 วันโดยไม่มีใครรายงาน ➜ เพิ่ม 15 คะแนนความประพฤติ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 2 ),
    );
  }
}
