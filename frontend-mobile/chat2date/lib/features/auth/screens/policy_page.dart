import 'package:chat2date/components/design_system/index.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  bool _accepted = false;
  bool _unlocked = false;
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        if (!_scrollCtrl.hasClients || _unlocked) return;
        final pos = _scrollCtrl.position;
        if (pos.pixels >= (pos.maxScrollExtent - 8.0)) {
          setState(() => _unlocked = true);
        }
      });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    bool onKyc = false;
    if (args is Map<String, dynamic>) {
      onKyc = args['goKyc'] as bool? ?? false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // ─── Header ─────────────────────────────
              DsAppSecondaryHeader(
                variant: DsAppSecondaryHeaderVariant.baseText,
                title: 'ข้อตกลง',
                onBackTap: () => Navigator.pop(context),
              ),

              // ─── Policy Content ─────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 2,
                          color: Color(0xFFE0E0E0),
                        ),
                        borderRadius: BorderRadius.circular(29),
                      ),
                    ),
                    child: Scrollbar(
                      controller: _scrollCtrl,
                      thumbVisibility: true,
                      thickness: 4,
                      radius: const Radius.circular(20),
                      child: SingleChildScrollView(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              'นโยบายการลงทะเบียนและข้อตกลงการใช้งาน แอพลิเคชั่น Chat to date',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.38,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '1. เงื่อนไขการลงทะเบียน\n'
                              '1.1 คุณสมบัติผู้ใช้งาน มีอายุ 18 ปีขึ้นไป\n'
                              'เป็นคนไทยที่อาศัยอยู่ในประเทศไทย มีสถานะโสด\n'
                              'มีความต้องการในการหาคู่อย่างจริงจังต้องการพูดคุย\n'
                              'ทำความรู้จักและออกเดตร่วมกัน\n'
                              '1.2 ข้อมูลที่จำเป็นต้องให้ข้อมูลส่วนตัวพื้นฐาน \n'
                              '(ชื่อ, อายุ, เพศ) หมายเลขโทรศัพท์สำหรับการยืนยัน OTP'
                              'ภาพถ่ายบัตรประชาชนการสแกนใบหน้าแบบ\n'
                              'เรียลไทม์เพื่อเปรียบเทียบกับบัตรประชาชน\n'
                              'ข้อมูลความสนใจและสไตล์การท่องเที่ยว\n'
                              'ข้อมูลไลฟ์สไตล์และความชอบ\n'
                              '2. การยืนยันตัวตน\n'
                              '2.1 ระบบตรวจสอบความถูกต้อง\n'
                              'การสแกนใบหน้าแบบเรียลไทม์พร้อมการตรวจจับการเคลื่อนไหว\n'
                              'การเปรียบเทียบใบหน้าจริงกับรูปในบัตรประชาชน\n'
                              'การยืนยันหมายเลขโทรศัพท์ด้วย OTP\n'
                              '2.2 การป้องกันโปรไฟล์ปลอม\n'
                              'ห้ามใช้รูปภาพของบุคคลอื่น\n'
                              'ห้ามแก้ไขข้อมูลอายุหรือเพศที่ไม่ตรงกับความเป็นจริง\n'
                              'ห้ามสร้างบัญชีซ้ำหรือปลอมแปลง\n'
                              '3. หน้าที่และความรับผิดชอบของผู้ใช้\n'
                              '3.1 การใช้งานที่เหมาะสม\n'
                              'ใช้แอปพลิเคชันเพื่อการหาคู่อย่างจริงจังเท่านั้น\n'
                              'มีมารยาทในการสื่อสารและแชต\n'
                              'เคารพความรู้สึกและขอบเขตส่วนตัวของผู้อื่น\n'
                              'ให้ข้อมูลที่ตรงกับความเป็นจริง\n',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Scroll to bottom link ──────────────
              GestureDetector(
                onTap: _scrollToBottom,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'เลื่อนลงล่างสุด',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _unlocked
                          ? AppColors.textSecondary
                          : Colors.black,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              // ─── Checkbox ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 23,
                      child: Checkbox(
                        value: _accepted,
                        onChanged: _unlocked
                            ? (v) => setState(() => _accepted = v ?? false)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(
                          width: 1,
                          color: _unlocked
                              ? AppColors.brandPrimary
                              : const Color(0xFFB9B9B9),
                        ),
                        activeColor: AppColors.brandPrimary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Text(
                      'ยินยอมนโยบายทั้งหมด',
                      style: TextStyle(
                        color: _unlocked
                            ? Colors.black
                            : const Color(0xFFB8B8B8),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Button ─────────────────────────────
              SizedBox(
                width: 231,
                child: DsButton(
                  label: 'ไปหน้าถัดไป',
                  size: DsButtonSize.md,
                  variant: DsButtonVariant.outlinePrimary,
                  onPressed: _accepted
                      ? () {
                          if (onKyc) {
                            Navigator.pushNamed(context, '/kyc-id-ocr');
                          } else {
                            Navigator.pushNamed(context, '/phone');
                          }
                        }
                      : null,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
