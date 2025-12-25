import 'package:chat2date/components/buttons/ds_button.dart';
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
  late final List<ReportReason> _reportItems;
  bool _showModal = false;

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
                  onBack: () => context.pop(),
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
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DsLabel(
                                label: 'เหตุผลที่ต้องการรายงาน',
                                labelFontSize: 16,
                              ),
                              const SizedBox(height: 8),
                              TagSelection(
                                items: _reportItems
                                    .map((t) => t.report)
                                    .toList(),
                                onChanged: (_) {},
                              ),
                            ],
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
                              Container(
                                height: 44,
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  color: Colors.grey.shade100,
                                ),
                                child: const Text(
                                  'จะเพิ่มภายหลัง',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
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
                              Container(
                                height: 80,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  color: Colors.grey.shade100,
                                ),
                                child: const Center(
                                  child: Text(
                                    'อัปโหลดรูป / วิดีโอ (เร็ว ๆ นี้)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
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
                                height: 90,
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
                                  ),
                                ),
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
                  topic: 'ขอบคุณสำหรับรายงาน',
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
