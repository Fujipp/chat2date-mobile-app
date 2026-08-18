import 'package:chat2date/components/design_system/controls/ds_progress_ring.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class KycLoadingScreen extends StatefulWidget {
  const KycLoadingScreen({super.key});

  @override
  State<KycLoadingScreen> createState() => _KycLoadingScreenState();
}

class _KycLoadingScreenState extends State<KycLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  int _durationMs = 3000;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _durationMs),
      lowerBound: 0,
      upperBound: 1,
    );

    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['ms'] is int && (args['ms'] as int) > 0) {
        _durationMs = args['ms'] as int;
        _ctrl.duration = Duration(milliseconds: _durationMs);
      }

      _ctrl
        ..reset()
        ..forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 364),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) {
                  final progress = _ctrl.isCompleted
                      ? 1.0
                      : _anim.value.clamp(0.0, 1.0);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DsProgressRing(value: progress),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 364,
                        child: Text(
                          'กรุณารอสักครู่',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w400,
                                fontSize: 22,
                                height: 28 / 22,
                              ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
