import 'package:flutter/material.dart';
import 'package:chat2date/components/index.dart'; // DsButton

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  bool _accepted = false; // ผู้ใช้ติ๊กยอมรับแล้วหรือยัง
  bool _unlocked =
      false; // ปลดล็อกช่องติ๊กหรือยัง (เลื่อนถึงท้ายอย่างน้อย 1 ครั้ง)
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        if (!_scrollCtrl.hasClients || _unlocked) return;
        final pos = _scrollCtrl.position;
        // ถือว่า “ถึงล่างสุด” เมื่อเลย maxScrollExtent เล็กน้อย (กัน jitter)
        final atBottom = pos.pixels >= (pos.maxScrollExtent - 8.0);
        if (atBottom) {
          setState(() => _unlocked = true); // ปลดล็อกช่องติ๊กครั้งเดียวพอ
        }
      });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AspectRatio(
          aspectRatio: 375 / 812,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white, // Light-Background
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Stack(
              children: [
                // กล่องนโยบาย (เลื่อนอ่านได้)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 600,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 2,
                          color: Color(0xFFE0E0E0),
                        ), // Light-Divider
                        borderRadius: BorderRadius.circular(29),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 330,
                          child: Text(
                            'นโยบายการลงทะเบียน\nและข้อตกลงการใช้งาน แอพลิเคชั่น\nChat to date',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF0F172A), // text-primary
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollCtrl, // <<— ใช้ controller
                            padding: const EdgeInsets.only(right: 8),
                            child: const Text(
                              // ——— เนื้อหาตามที่ให้ ———
                              '1. เงื่อนไขการลงทะเบียน\n'
                              '1.1 คุณสมบัติผู้ใช้งาน มีอายุ 18 ปีขึ้นไป เป็นคนไทยที่อาศัยอยู่ในประเทศไทย มีสถานะโสด '
                              'มีความต้องการในการหาคู่อย่างจริงจัง ต้องการพูดคุย ทำความรู้สึก และออกเดตร่วมกัน\n'
                              '1.2 ข้อมูลที่จำเป็นต้องให้ ข้อมูลส่วนตัวพื้นฐาน (ชื่อ, อายุ, เพศ) หมายเลขโทรศัพท์สำหรับการยืนยัน OTP '
                              'ภาพถ่ายบัตรประชาชน การสแกนใบหน้าแบบเรียลไทม์เพื่อเปรียบเทียบกับบัตรประชาชน '
                              'ข้อมูลความสนใจและสไตล์การท่องเที่ยว ข้อมูลไลฟ์สไตล์และความชอบ\n\n'
                              '2. การยืนยันตัวตน\n'
                              '2.1 ระบบตรวจสอบความถูกต้อง การสแกนใบหน้าแบบเรียลไทม์พร้อมการตรวจจับการเคลื่อนไหว '
                              'การเปรียบเทียบใบหน้าจริงกับรูปในบัตรประชาชน การยืนยันหมายเลขโทรศัพท์ด้วย OTP\n'
                              '2.2 การป้องกันโปรไฟล์ปลอม ห้ามใช้รูปภาพของบุคคลอื่น ห้ามแก้ไขข้อมูลอายุหรือเพศที่ไม่ตรงกับความเป็นจริง '
                              'ห้ามสร้างบัญชีซ้ำหรือปลอมแปลง\n\n'
                              '3. หน้าที่และความรับผิดชอบของผู้ใช้\n'
                              '3.1 การใช้งานที่เหมาะสม ใช้แอปพลิเคชันเพื่อการหาคู่อย่างจริงจังเท่านั้น มีมารยาทในการสื่อสารและแชต '
                              'เคารพความรู้สึกและขอบเขตส่วนตัวของผู้อื่น ให้ข้อมูลที่ตรงกับความเป็นจริง\n',
                              style: TextStyle(
                                color: Color(0xFF334155), // text-secondary
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        // แถบช่วยบอกสถานะการเลื่อน (optional)
                        SizedBox(
                          height: 6,
                          child: LayoutBuilder(
                            builder: (context, c) {
                              // แถบสถานะ: ยังไม่ได้ปลดล็อก = เส้นเทา, ปลดล็อกแล้ว = เส้นเข้ม
                              return Container(
                                width: c.maxWidth,
                                decoration: BoxDecoration(
                                  color: _unlocked
                                      ? const Color(0xFF7987AC)
                                      : const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // แถวเช็กบ็อกซ์ + ข้อความยินยอม
                Align(
                  alignment: const Alignment(0, 0.77),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 310),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 23,
                          child: Checkbox(
                            value: _accepted,
                            onChanged: _unlocked
                                ? (v) => setState(() => _accepted = v ?? false)
                                : null, // <<— ปิดจนกว่าจะปลดล็อก
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            side: const BorderSide(width: 1),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            _unlocked
                                ? 'ยินยอมนโยบายทั้งหมด'
                                : 'เลื่อนอ่านให้ถึงท้ายสุดก่อนจึงจะยอมรับได้',
                            style: const TextStyle(
                              color: Color(0xFF060606),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ปุ่ม Primary “พร้อมแล้ว”
                Align(
                  alignment: const Alignment(0, 0.93),
                  child: SizedBox(
                    width: 231,
                    height: 40,
                    child: DsButton(
                      label: 'พร้อมแล้ว',
                      size: DsButtonSize.md,
                      variant: DsButtonVariant.primary,
                      onPressed: _accepted
                          ? () => Navigator.pushNamed(context, '/phone')
                          : null, // ❌ ยังไม่ติ๊ก = ปิดปุ่ม
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
