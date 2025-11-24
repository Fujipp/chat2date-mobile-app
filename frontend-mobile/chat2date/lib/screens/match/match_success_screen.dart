import 'package:flutter/material.dart';

class MatchSuccessArgs {
  final String myName;
  final String partnerName;
  final String? myAvatarUrl;
  final String? partnerAvatarUrl;

  const MatchSuccessArgs({
    required this.myName,
    required this.partnerName,
    this.myAvatarUrl,
    this.partnerAvatarUrl,
  });
}

class MatchSuccessScreen extends StatefulWidget {
  static const routeName = '/match-success';

  final MatchSuccessArgs args;

  const MatchSuccessScreen({
    super.key,
    required this.args,
  });

  @override
  State<MatchSuccessScreen> createState() => _MatchSuccessScreenState();
}

class _MatchSuccessScreenState extends State<MatchSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ ตั้ง timer 5 วิ แล้ว pop กลับหน้าเดิม (Discovery)
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'จับคู่สำเร็จ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MatchUserAvatar(
                      name: args.myName,
                      imageUrl: args.myAvatarUrl,
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.favorite,
                      size: 40,
                      color: Color(0xFFFF4B8B),
                    ),
                    const SizedBox(width: 16),
                    _MatchUserAvatar(
                      name: args.partnerName,
                      imageUrl: args.partnerAvatarUrl,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                const Text(
                  'คุณได้คู่แล้วเราจะนำไปสู่การแชท',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
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

class _MatchUserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _MatchUserAvatar({
    required this.name,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF64748B),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
