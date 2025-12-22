import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserReportScreen extends StatefulWidget {
  const UserReportScreen({super.key, this.avatarUrl, this.userName});

  final String? avatarUrl;
  final String? userName;

  @override
  State<UserReportScreen> createState() => _UserReportScreenState();
}

class _UserReportScreenState extends State<UserReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 16, // ✅ เพิ่มแนวนอน
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity, // ✅ สำคัญมาก
              height: 85,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 10, // ตอนนี้ 0 ก็พอแล้ว
                    child: IconButton(
                      splashRadius: 26,
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/icons/icon_arrow-back-circle.svg',
                        width: 45,
                        height: 45,
                      ),
                    ),
                  ),
                  const Text(
                    'รายงาน',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: widget.avatarUrl != null
                      ? NetworkImage(widget.avatarUrl!)
                      : null,
                  child: widget.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 60)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userName ?? 'Name',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
