import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/common/image_upload_grid.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/inputs/ds_text_field/tag_autocomplete.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/responsive_container.dart';
import 'package:chat2date/models/report_reason.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class UserReportScreen extends StatefulWidget {
  const UserReportScreen({
    super.key,
    this.avatarUrl,
    this.userName,
    this.reportItems,
  });

  final String? avatarUrl;
  final String? userName;
  final List<ReportReason>? reportItems;

  @override
  State<UserReportScreen> createState() => _UserReportScreenState();
}

class _UserReportScreenState extends State<UserReportScreen> {
  Key _imageGridKey = UniqueKey();
  late final List<ReportReason> _reportItems;
  bool _showModal = false;
  List<String> otherReasons = []; // เก็บรายการเหตุผลที่เพิ่ม
  final TextEditingController _controller = TextEditingController();
  final int charLimit = 50;

  @override
  void initState() {
    super.initState();
    _reportItems =
        widget.reportItems ??
        [
          ReportReason(id: 1, report: 'สแปม'),
          ReportReason(id: 2, report: 'โปรไฟล์ปลอม'),
          ReportReason(id: 3, report: 'พฤติกรรมไม่เหมาะสม'),
          ReportReason(id: 4, report: 'ภาษาที่ไม่เหมาะสม'),
          ReportReason(id: 5, report: 'อื่น ๆ'),
        ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            /// ================== Layer 1 : หน้ารายงาน ==================
            Column(
              children: [
                Header(
                  name: 'รายงานผู้ใช้',
                  onBack: () =>
                      Navigator.pushReplacementNamed(context, '/chat'),
                  showAvatar: false,
                  showBorder: false,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: widget.avatarUrl != null
                                  ? NetworkImage(widget.avatarUrl!)
                                  : null,
                              child: widget.avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 60,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.userName ?? 'Name',
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        // ---- เหตุผลที่ต้องการรายงาน ----
                        SizedBox(
                          width: double.infinity, // ให้ขยายเต็มพื้นที่ที่เหลือ
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                            ), // ใส่ทั้งซ้ายและขวาให้เท่ากัน
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DsLabel(
                                  label: 'เหตุผลที่ต้องการรายงาน',
                                  labelFontSize: 16,
                                ),
                                const SizedBox(height: 12),
                                TagSelection(
                                  // ✅ เปิดโหมดใหม่ที่เราสร้างไว้
                                  items: _reportItems
                                      .map((t) => t.report)
                                      .toList(),
                                  onChanged: (selectedList) {
                                    print("Selected: $selectedList");
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ---- เหตุผลอื่น ๆ ----
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DsLabel(label: 'เหตุผลอื่น ๆ', labelFontSize: 16),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- ส่วนแสดง Chip ที่เด้งขึ้นมา ---
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: otherReasons.map((reason) {
                                      return Chip(
                                        label: Text(
                                          reason,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFFFF8EBD,
                                        ), // สีชมพูตามรูป
                                        deleteIcon: const Icon(
                                          Icons.cancel,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            otherReasons.remove(
                                              reason,
                                            ); // ลบ Chip ออกจากรายการ
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        side: BorderSide.none,
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 12),

                                  // --- ส่วน TextField ---
                                  SizedBox(
                                    height:
                                        55, // ปรับความสูงให้พอดีกับ 1 บรรทัด (เพื่อให้แนวเดียวกับปุ่ม +)
                                    child: TextField(
                                      controller: _controller,
                                      maxLength: charLimit,
                                      textAlignVertical: TextAlignVertical
                                          .center, // ปรับให้อยู่ตรงกลางแนวตั้ง
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'ระบุเหตุผลอื่นๆ...',
                                        hintStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        // ปรับ padding ให้ข้อความอยู่ตรงกลาง และไม่เบียดปุ่ม
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 0,
                                            ),

                                        counterText:
                                            "", // ซ่อนตัวนับด้านล่างถ้าอยากให้คลีน (หรือจะเปิดไว้ก็ได้)

                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: Color(0xFF005581),
                                            size:
                                                28, // ปรับขนาดลงเล็กน้อยให้พอดีกับความสูงช่อง
                                          ),
                                          onPressed: () {
                                            if (_controller.text
                                                .trim()
                                                .isNotEmpty) {
                                              setState(() {
                                                otherReasons.add(
                                                  _controller.text.trim(),
                                                );
                                                _controller.clear();
                                              });
                                            }
                                          },
                                        ),

                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ), // ทำขอบมนให้เหมือน Chip
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ---- คำอธิบายเพิ่มเติม ----
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DsLabel(
                                label: 'คำอธิบายเพิ่มเติม',
                                labelFontSize: 16,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 120,
                                child: TextField(
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    hintText: 'ใส่คำอธิบาย',
                                    hintStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: const EdgeInsets.all(12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),

                                    // 2. สถานะตอนกดพิมพ์ (ถ้าอยากให้เป็นสีเทาเหมือนเดิม)
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ---- แนบหลักฐาน ----
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DsLabel(label: 'แนบหลักฐาน', labelFontSize: 16),
                              const SizedBox(height: 8),
                              ImageUploadGrid(
                                isHorizontal: true,
                                maxImages: 3,
                                itemHeight: 70,
                                itemWidth: 70,
                                key:
                                    _imageGridKey, // ✅ ใช้ key เพื่อ force rebuild
                                onImagesChanged: (images) {
                                  setState(() {
                                    // _selectedImages = images
                                    //     .map((xFile) => File(xFile.path))
                                    //     .toList();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        DsButton(
                          label: 'บันทึก',
                          onPressed: () {
                            setState(() {
                              _showModal = true;
                            });

                            // ปิด modal หลัง 5 วินาที
                            Future.delayed(const Duration(seconds: 5), () {
                              if (!mounted) return;
                              setState(() {
                                _showModal = false;
                              });
                            });
                          },
                          variant: DsButtonVariant.primary,
                          size: DsButtonSize.md,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// ================== Layer 2 : Dim + Modal ==================
            if (_showModal) ...[
              Positioned.fill(child: Container(color: const Color(0x66B2B2B2))),

              Center(
                child: ModalComponent(
                  topic: 'ขอบคุณสำหรับการรายงาน',
                  description:
                      'เราได้ทำการส่งเรื่องของคุณ\nให้ทาง admin เป็นที่เรียบร้อยแล้ว \nและจะดำเนินการบล็อคบัญชีที่ถูกรายงานให้กับคุณทันที',
                  textOnly: true,
                  spaceTop: 20,
                  spaceBottom: 20,
                  width: 330,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
