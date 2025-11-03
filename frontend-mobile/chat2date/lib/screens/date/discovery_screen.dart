import 'dart:math';

import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:flutter/widgets.dart';
import 'package:chat2date/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DiscoveryScreen extends StatefulWidget {
  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 121,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 51),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/icon_chat2date_full.svg',
                                  width: 108,
                                  height: 24,
                                ),
                                Spacer(),
                                SvgPicture.asset(
                                  'assets/icons/icon_more-settings.svg',
                                  width: 108,
                                  height: 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity, // เต็มหน้าจอ
              height: 545, // ความสูง 545
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/images/image_majiko.jpg', // รูปผู้หญิง
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: -30, // ลบ 30 ออกไปจากขอบล่างของ SizedBox
                    left: 75, // วางกึ่งกลาง
                    child: SvgPicture.asset(
                      'assets/icons/icon_unlike.svg',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  Positioned(
                    bottom: -30, // ลบ 30 ออกไปจากขอบล่างของ SizedBox
                    right: 75, // วางกึ่งกลาง
                    child: SvgPicture.asset(
                      'assets/icons/icon_like.svg',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width, // ซ้ายครึ่งจอ
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 25,
                          height: 26,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Icon(
                              Icons.keyboard_double_arrow_down,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ปุ่มล่าง: ซ้ายกึ่งกลางจอ, เว้นขอบล่าง 5
                  Positioned(
                    bottom: 5,
                    left: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width, // ซ้ายครึ่งจอ
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 25,
                          height: 26,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Icon(
                              Icons.keyboard_double_arrow_up,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width, // ซ้ายครึ่งจอ
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 25,
                          height: 26,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Icon(
                              Icons.keyboard_double_arrow_down,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ปุ่มล่าง: ซ้ายกึ่งกลางจอ, เว้นขอบล่าง 5
                  Positioned(
                    bottom: 5,
                    left: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width, // ซ้ายครึ่งจอ
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 25,
                          height: 26,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Icon(
                              Icons.keyboard_double_arrow_up,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 16,
                    ), // กำหนด padding ที่ต้องการ
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                              height: 16,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 10,
                              height: 16,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 117.38),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: 311,
                            child: Text(
                              'เมจิโกะ',
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Wrap(
                            spacing: 5, // ระยะห่างแนวนอนระหว่าง tags
                            runSpacing: 7,
                            children: List.generate(5, (index) {
                              return SizedBox(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.btnPrimary,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 60, // กำหนด width ขั้นต่ำ
                                      ),
                                      height: 27,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/icon_tag.svg',
                                            width: 24,
                                            height: 24,
                                          ),
                                          Text(
                                            'Tag ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
//Padding(
                //padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                //child: