import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/common/loading_component.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/inputs/ds_text_field/ds_text_field.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

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
                      DsTextField(label: 'ชื่อเล่น', labelFontSize: 20),

                      DsTextField(
                        label: 'เพศที่สนใจ',
                        labelFontSize: 20,
                        suffixIcon: Icons.keyboard_arrow_down_rounded,
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
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 2),
    );
  }
}
