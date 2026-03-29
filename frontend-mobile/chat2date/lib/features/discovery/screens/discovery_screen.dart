import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/components/design_system/controls/ds_reaction_button.dart';
import 'package:chat2date/components/design_system/controls/ds_slider.dart';
import 'package:chat2date/components/design_system/organisms/ds_app_home_header.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/models/dto/discovery_dto.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/discovery_service.dart';
import 'package:chat2date/services/fcm_token_service.dart';
import 'package:chat2date/services/location_service.dart';
import 'package:chat2date/services/swipe_quota_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/app_gradients.dart';
import 'package:chat2date/core/theme/tokens/colors/input_colors.dart';
import 'package:chat2date/core/theme/tokens/colors/text_colors.dart';
import 'package:chat2date/features/profile/screens/selection_icon_mapper.dart';
import 'package:chat2date/features/discovery/widgets/home_search_loading_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// NOTE: We deliberately handle location permission inline here (minimal change)
// rather than introducing new global wrappers to satisfy the requirement.
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  final int selectedIndex;
  final bool showBottomNav;

  const DiscoveryScreen({
    super.key,
    this.selectedIndex = 0,
    this.showBottomNav = true,
  });

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

enum ActivePanel { none, top, bottom }

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// Helper: Ensure we have usable location permission + a valid position.
  /// Returns true if location is available and flow can proceed.
  /// If permission is denied or a valid position cannot be obtained, we
  /// immediately redirect to `/home` (global rule for location usage) and
  /// return false to skip the rest of the normal initialization.
  ///
  /// Rationale:
  /// - We treat missing permission or failed position acquisition as an
  ///   unusable state for discovery; user experience should go back to home.
  /// - We do NOT fall back to (0,0); (0,0) is considered an invalid location.
  /// - If user later enables location in system settings, a subsequent call
  ///   that succeeds will allow the original flow to continue unchanged.
  Future<bool> _ensureLocationOrRedirect() async {
    try {
      // 1) Check location service enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _redirectHome();
        return false;
      }

      // 2) Check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _redirectHome();
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        _redirectHome();
        return false;
      }

      // 3) Try to get a position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Treat (0,0) as invalid (do not proceed)
      if (pos.latitude == 0.0 && pos.longitude == 0.0) {
        _redirectHome();
        return false;
      }

      // Success - allow normal flow to continue
      return true;
    } catch (e) {
      // Any failure obtaining location results in redirect
      _redirectHome();
      return false;
    }
  }

  void _redirectHome() {
    if (!mounted) return;
    // Use pushReplacement so user cannot navigate back to broken screen
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _handleBottomNavTap(int index) async {
    setState(() {
      _isDistancePanelOpen = false;
    });
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        final userStore = ref.read(userStoreProvider);
        final userId = (userStore['user'] as User?)?.userId;

        if (userId != null) {
          await ref.read(userServiceProvider).getUser(userId);
        }
        final freshStore = ref.read(userStoreProvider) as Map<String, dynamic>;
        final currentUser = freshStore['user'] as User;
        behaviorScore = currentUser.behaviorScore;

        final quota = await ref.read(swipeQuotaProvider).checkSwipeStatus();

        if (quota.isRestricted) {
          remainingAction = quota.remainingCount;
        } else {
          remainingAction = null;
        }

        if (userId != null) {
          ref
              .read(discoveryProvider(userId).notifier)
              .refresh(
                minDistance: _selectedRange.start.round(),
                maxDistance: _selectedRange.end.round(),
              );
        }
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/chat-list');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  // --- Panel state ---
  final _topCtrl = PanelController();
  final _bottomCtrl = PanelController();
  double _posTop = 0.0;
  double _posBottom = 0.0;
  final ValueNotifier<ActivePanel> activePanel = ValueNotifier(
    ActivePanel.none,
  );

  late int _selectedIndex;

  // --- Card animation (like/unlike) ---
  late final AnimationController _cardCtrl;
  Offset _startPos = Offset.zero;
  Offset _targetPos = Offset.zero;
  double _startRot = 0;
  double _targetRot = 0;
  double _opacity = 1.0;

  int? remainingAction;

  int _index = 0;
  String? _userId;
  int? behaviorScore;

  RangeValues _selectedRange = const RangeValues(0, 160);
  bool _isDistancePanelOpen = false;
  double _distanceKm = 160;
  bool _isSavingDistancePanel = false;

  Future<void> _loadPersistedRange() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final start = prefs.getDouble('distanceRange:${_userId}:start');
      final end = prefs.getDouble('distanceRange:${_userId}:end');
      if (start != null && end != null) {
        setState(() {
          _selectedRange = RangeValues(
            start.clamp(0.0, 160.0),
            end.clamp(0.0, 160.0),
          );
          _distanceKm = _selectedRange.end;
        });
      }
    } catch (_) {}
  }

  Future<void> _persistSelectedRange(RangeValues values) async {
    if (_userId == null) return;

    final normalized = RangeValues(
      values.start.clamp(0.0, 160.0),
      values.end.clamp(0.0, 160.0),
    );

    setState(() {
      _selectedRange = normalized;
      _distanceKm = normalized.end;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      'distanceRange:${_userId}:start',
      normalized.start,
    );
    await prefs.setDouble(
      'distanceRange:${_userId}:end',
      normalized.end,
    );
  }

  Future<void> _refreshCandidatesSafely(RangeValues values) async {
    if (_userId == null) return;

    try {
      await ref.read(discoveryProvider(_userId!).notifier).refresh(
            minDistance: values.start.round(),
            maxDistance: values.end.round(),
          );
      if (!mounted) return;
      setState(() {
        _candidateViewKey = GlobalKey<_CandidateViewState>();
      });
    } catch (_) {}
  }

  Future<void> _syncDistancePreferenceSafely(RangeValues values) async {
    try {
      final Map<String, Object> preferenceMatch = {
        'interestedDistanceMin': values.start.round(),
        'interestedDistanceMax': values.end.round(),
      };
      await ref.read(userServiceProvider).addPreferenceMatchUser(preferenceMatch);
    } catch (_) {}
  }

  void _toggleDistancePanel() {
    setState(() {
      _distanceKm = _selectedRange.end.clamp(1.0, 160.0);
      _isDistancePanelOpen = !_isDistancePanelOpen;
    });
  }

  Future<void> _saveDistancePanel() async {
    if (_isSavingDistancePanel) return;

    final selectedRange = RangeValues(0, _distanceKm.clamp(1.0, 160.0));
    final isUnchanged =
        selectedRange.start.round() == _selectedRange.start.round() &&
        selectedRange.end.round() == _selectedRange.end.round();

    setState(() {
      _isDistancePanelOpen = false;
      _isSavingDistancePanel = true;
    });

    try {
      if (isUnchanged) {
        return;
      }
      await _persistSelectedRange(selectedRange);
      await _syncDistancePreferenceSafely(selectedRange);
      await _refreshCandidatesSafely(selectedRange);
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDistancePanel = false;
        });
      }
    }
  }

  static const BoxDecoration _distancePanelDecoration = BoxDecoration(
    color: AppColors.background,
    boxShadow: [
      BoxShadow(
        color: Color(0x16000000),
        blurRadius: 22,
        spreadRadius: -8,
        offset: Offset(0, 16),
      ),
    ],
  );

  Widget _buildHomeScaffold({
    required Widget child,
    VoidCallback? onActionTap,
    bool hideBottomNav = false,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DsAppHomeHeader(onActionTap: onActionTap),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: child),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    top: _isDistancePanelOpen ? 0 : -220,
                    left: 0,
                    right: 0,
                    child: _buildDistancePanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav && !hideBottomNav
          ? CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: _handleBottomNavTap,
            )
          : null,
    );
  }

  Widget _buildHomeLoadingState({required bool canOpenFilter}) {
    return _buildHomeScaffold(
      onActionTap: canOpenFilter ? _toggleDistancePanel : null,
      child: const _DiscoveryImageLoadingArea(),
    );
  }

  Widget _buildDistancePanel() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        decoration: _distancePanelDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'การตั้งค่าการค้นหา',
              style: TextStyle(
                fontSize: 18,
                height: 24 / 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'ระยะห่างสูงสุด',
                    style: TextStyle(
                      fontSize: 18,
                      height: 24 / 18,
                      color: AppColors.textBlack,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                Text(
                  '${_distanceKm.round()} Km.',
                  style: const TextStyle(
                    fontSize: 18,
                    height: 24 / 18,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            DsSlider(
              value: _distanceKm,
              min: 1,
              max: 160,
              width: double.infinity,
              onChanged: (value) {
                setState(() {
                  _distanceKm = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: DsButton(
                label: 'บันทึก',
                onPressed: _isSavingDistancePanel ? null : _saveDistancePanel,
                width: 231,
                size: DsButtonSize.md,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Key สำหรับบังคับให้ rebuild CandidateView และเข้าถึง state ภายใน
  GlobalKey<_CandidateViewState> _candidateViewKey =
      GlobalKey<_CandidateViewState>();
  bool _isCandidateAboutOpen = false;

  // ---------- Utils ----------

  Color _blurredWhite(double t) {
    if (t < 0.1) return Colors.black.withOpacity(0.01);
    final k = ((t - 0.1) / 0.9).clamp(0.0, 0.5);
    return Colors.white.withOpacity(k);
  }

  void _nextImage(int maxLength) {
    print(_index);
    setState(() => _index = (_index + 1) % maxLength);
  }

  void _prevImage(int maxLength) {
    setState(() => _index = (_index - 1 + maxLength) % maxLength);
  }

  void _animateCard({required Offset to, required double rot}) {
    _startPos = Offset.zero;
    _startRot = 0;
    _targetPos = to;
    _targetRot = rot;

    _cardCtrl
      ..stop()
      ..reset();
    _cardCtrl.forward();
  }

  void _onUnlike() async {
    if (_userId == null) return;

    if (remainingAction == 0) {
      if (remainingAction == 0) {
        _showQuotaLimitModal(10); // แสดง Modal ทันทีถ้าโควตาเดิมหมด
        return;
      }
      return;
    }

    final quota = await ref.read(swipeQuotaProvider).processSwipe();
    if (quota.isRestricted != false) {
      remainingAction = quota.remainingCount;
    }

    _animateCard(to: const Offset(-500, 0), rot: -pi / 10);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        ref.read(discoveryProvider(_userId!).notifier).unlikeCurrentCandidate();
        setState(() {
          _candidateViewKey = GlobalKey<_CandidateViewState>();
        });
      }
    });

    if (remainingAction == 0) {
      _showQuotaLimitModal(10); // แสดง Modal ทันทีถ้าโควตาเดิมหมด
      return;
    }
  }

  void _onLike() async {
    if (_userId == null) return;

    if (remainingAction == 0) {
      if (remainingAction == 0) {
        _showQuotaLimitModal(10); // แสดง Modal ทันทีถ้าโควตาเดิมหมด
        return;
      }
      return;
    }

    final quota = await ref.read(swipeQuotaProvider).processSwipe();
    if (quota.isRestricted != false) {
      remainingAction = quota.remainingCount;
    }

    _animateCard(to: const Offset(0, 400), rot: 0);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        ref.read(discoveryProvider(_userId!).notifier).likeCurrentCandidate();
        // ✅ สร้าง key ใหม่เพื่อ rebuild widget
        setState(() {
          _candidateViewKey = GlobalKey<_CandidateViewState>();
        });
      }
    });

    if (remainingAction == 0) {
      _showQuotaLimitModal(10);
      return;
    }
  }

  void _showQuotaLimitModal(int currentCount) {
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 7500), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return Center(
          child: Material(
            color: Colors.transparent,
            child: ModalComponent(
              svgPath: 'assets/icons/ui/icon_warning.svg',
              heightSvg: 80,
              widthSvg: 80,
              topic: 'แจ้งเตือน',
              description:
                  'คุณใช้สิทธิ์การปัดไปแล้ว $currentCount/10 ครั้ง\n'
                  'คะแนนความประพฤติ: $behaviorScore\n'
                  'สามารถอ่านเกณฑ์ได้ที่ เมนูรูปโปรไฟล์',
              spaceBottom: 20,
              spaceTop: 20,
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // ติดตั้ง observer เพื่อตรวจสิทธิ์ใหม่เมื่อกลับจาก Settings
    WidgetsBinding.instance.addObserver(this);

    _selectedIndex = widget.selectedIndex;

    _cardCtrl =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 380),
          )
          ..addListener(() {
            setState(() {
              final t = _cardCtrl.value;
              _opacity = 1 - t;
            });
          })
          ..addStatusListener((st) async {
            if (st == AnimationStatus.completed) {
              await Future.delayed(const Duration(milliseconds: 150));
              if (!mounted) return;
              setState(() {
                _index = 0;
                _startPos = Offset.zero;
                _targetPos = Offset.zero;
                _startRot = 0;
                _targetRot = 0;
                _opacity = 1.0;
              });
            }
          });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ โหลดครั้งเดียวเมื่อได้ userId แล้ว
    if (_userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        try {
          debugPrint('[Discovery] 🚀 Starting initialization...');

          // 1️⃣ ดึง userId
          final userStore = ref.read(userStoreProvider);

          debugPrint(userStore.toString());
          final user = userStore['user'] as User?;

          if (user == null) {
            debugPrint('❌ User not found in store');
            return;
          }
          final String userId = user.userId;

          if (!mounted) return;

          debugPrint('[Discovery] 📝 Got userId: $userId');
          setState(() {
            _userId = userId;
          });

          debugPrint('[Discovery] 👤 Loading users');
          await ref.read(userServiceProvider).getUser(userId);
          final freshStore =
              ref.read(userStoreProvider) as Map<String, dynamic>;
          final currentUser = freshStore['user'] as User;
          behaviorScore = currentUser.behaviorScore;

          if (!mounted) return;
          debugPrint('[Discovery] ✅ users loaded');

          // 5️⃣ โหลด profile
          debugPrint('[Discovery] 👤 Loading profile...');
          await ref.read(userServiceProvider).getProfile();

          if (!mounted) return;
          debugPrint('[Discovery] ✅ Profile loaded');

          final quota = await ref.read(swipeQuotaProvider).checkSwipeStatus();

          if (quota.isRestricted) {
            remainingAction = quota.remainingCount;
          } else {
            remainingAction = null;
          }

          // โหลดค่า range ที่บันทึกไว้ของผู้ใช้นี้
          await _loadPersistedRange();

          // 2️⃣ Global rule: ensure location available or redirect to /home.
          final hasLocation = await _ensureLocationOrRedirect();
          if (!mounted || !hasLocation) return; // redirected already

          // 3️⃣ Update location (normal flow continues unchanged if success)
          debugPrint('[Discovery] 📍 Updating location...');
          await ref.read(locationServiceProvider).tryUpdateLocationSilently();

          if (!mounted) return;
          debugPrint('[Discovery] ✅ Location updated');

          // 4️⃣ ลงทะเบียน FCM token
          debugPrint('[Discovery] 🔔 Registering FCM...');
          await ref.read(fcmTokenServiceProvider).registerDeviceTokenSilently();

          if (!mounted) return;
          debugPrint('[Discovery] ✅ FCM registered');

          // 6️⃣ โหลด candidates (สุดท้าย - ครั้งเดียว) โดยอิงค่าระยะทางที่เลือกไว้
          debugPrint('[Discovery] 💝 Loading candidates...');
          await ref
              .read(discoveryProvider(userId).notifier)
              .loadCandidates(
                minDistance: _selectedRange.start.round(),
                maxDistance: _selectedRange.end.round(),
              );

          if (!mounted) return;
          debugPrint('[Discovery] 🎉 Initialization complete!');
        } catch (e) {
          print('❌ Error initializing discovery: $e');
        }
      });
    }
  }

  @override
  void dispose() {
    debugPrint('[Discovery] 🔴 Disposing screen...');
    _cardCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // เมื่อผู้ใช้กลับมาจาก Settings ให้เช็คสิทธิ์อีกครั้ง
      if (mounted) {
        final ok = await _ensureLocationOrRedirect();
        if (!ok || !mounted) return; // redirected if false
        // ถ้าอนุญาตแล้วจะไม่ถูกส่งไป /home และ flow เดิมจะดำเนินต่อไป
        // สามารถอัปเดตตำแหน่งแบบเงียบ ๆ ได้
        await ref.read(locationServiceProvider).tryUpdateLocationSilently();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // รอจนกว่าจะได้ userId
    if (_userId == null) {
      return _buildHomeLoadingState(canOpenFilter: true);
    }

    final discoveryState = ref.watch(discoveryProvider(_userId!));
    final currentCandidate = discoveryState.currentCandidate;

    // ✅ แสดง Loading ถ้ายังไม่เคยโหลด หรือกำลัง initialize
    if (discoveryState.isLoading ||
        discoveryState.isInitializing ||
        !discoveryState.hasLoadedOnce) {
      return _buildHomeLoadingState(canOpenFilter: true);
    }

    // Backend error และ empty state ใช้หน้ากลางเดียวกัน
    if (discoveryState.error != null || currentCandidate == null || discoveryState.isEmpty) {
      return _buildHomeFallbackState();
    }

    // ✅ มี candidate - ใช้ CandidateView เป็น content เดียวกันใต้ header/nav กลาง
    return _buildHomeScaffold(
      onActionTap: _toggleDistancePanel,
      hideBottomNav: _isCandidateAboutOpen,
      child: _CandidateView(
        key: _candidateViewKey,
        userId: _userId!,
        candidate: currentCandidate,
        cardCtrl: _cardCtrl,
        startPos: _startPos,
        targetPos: _targetPos,
        startRot: _startRot,
        targetRot: _targetRot,
        opacity: _opacity,
        index: _index,
        topCtrl: _topCtrl,
        bottomCtrl: _bottomCtrl,
        posTop: _posTop,
        posBottom: _posBottom,
        activePanel: activePanel,
        selectedRange: _selectedRange,
        blurredWhite: _blurredWhite,
        onNextImage: _nextImage,
        onPrevImage: _prevImage,
        onLike: _onLike,
        onUnlike: _onUnlike,
        onPanelSlideTop: (p) {
          setState(() {
            _posTop = p;
            if (p > 0) activePanel.value = ActivePanel.top;
          });
        },
        onPanelClosedTop: () {
          setState(() {
            _posTop = 0;
            if (activePanel.value == ActivePanel.top) {
              activePanel.value = ActivePanel.none;
            }
          });
        },
        onPanelSlideBottom: (p) {
          setState(() {
            _posBottom = p;
            if (p > 0) activePanel.value = ActivePanel.bottom;
          });
        },
        onPanelClosedBottom: () {
          setState(() {
            _posBottom = 0;
            if (activePanel.value == ActivePanel.bottom) {
              activePanel.value = ActivePanel.none;
            }
          });
        },
        remainingAction: remainingAction,
        onAboutOpenChanged: (isOpen) {
          if (_isCandidateAboutOpen == isOpen) return;
          setState(() {
            _isCandidateAboutOpen = isOpen;
          });
        },
      ),
    );
  }

  Widget _buildHomeFallbackState() {
    return _buildHomeScaffold(
      onActionTap: _toggleDistancePanel,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                            const Icon(
                              Icons.person_search_rounded,
                              size: 134,
                              color: AppColors.brandPrimary,
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(
                              width: 358,
                              child: Column(
                                children: [
                                  Text(
                                    'ไม่พบคนที่เหมาะสมในขณะนี้',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      height: 28 / 22,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'ไม่ต้องกังวลเรามีคำแนะนำให้คุณ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 22 / 16,
                                      color: TextColors.supportText,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 358,
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                              decoration: BoxDecoration(
                                color: InputColors.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: InputColors.border),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 47,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'คำแนะนำ : ให้ลองปรับเปลี่ยนตามนี้',
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 20 / 14,
                                          color: TextColors.secondary,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ),
                                  _EmptySuggestionLine(
                                    text: 'ปรับระยะทางการค้นหาคู่เดตให้มากขึ้น',
                                  ),
                                  _EmptySuggestionLine(
                                    text: 'ปรับประเภทคู่เดตที่สนใจ',
                                  ),
                                  _EmptySuggestionLine(
                                    text: 'ลองค้นหาใหม่อีกครั้ง',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            DsButton(
                              label: 'ค้นหาอีกครั้ง',
                              onPressed: () async {
                                await _refreshCandidatesSafely(_selectedRange);
                              },
                              width: 231,
                              size: DsButtonSize.md,
                              variant: DsButtonVariant.outlinePrimary,
                              leadingSvgAsset: AppAssets.refreshIcon,
                              iconSize: 17,
                            ),
                            const SizedBox(height: 10),
                            DsButton(
                              label: 'ปรับระยะทางค้นหา',
                              onPressed: _toggleDistancePanel,
                              width: 231,
                              size: DsButtonSize.md,
                              variant: DsButtonVariant.outlinePrimary,
                              leadingSvgAsset: AppAssets.settingsIcon,
                              iconSize: 20,
                            ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Widget แยกสำหรับแสดง Candidate พร้อม Image Preloading
class _CandidateView extends ConsumerStatefulWidget {
  final String userId;
  final DiscoveryResponse candidate;
  final AnimationController cardCtrl;
  final Offset startPos;
  final Offset targetPos;
  final double startRot;
  final double targetRot;
  final double opacity;
  final int index;
  final PanelController topCtrl;
  final PanelController bottomCtrl;
  final double posTop;
  final double posBottom;
  final ValueNotifier<ActivePanel> activePanel;
  final RangeValues selectedRange;
  final Color Function(double) blurredWhite;
  final void Function(int) onNextImage;
  final void Function(int) onPrevImage;
  final VoidCallback onLike;
  final VoidCallback onUnlike;
  final void Function(double) onPanelSlideTop;
  final VoidCallback onPanelClosedTop;
  final void Function(double) onPanelSlideBottom;
  final VoidCallback onPanelClosedBottom;
  final int? remainingAction;
  final ValueChanged<bool> onAboutOpenChanged;

  const _CandidateView({
    super.key,
    required this.userId,
    required this.candidate,
    required this.cardCtrl,
    required this.startPos,
    required this.targetPos,
    required this.startRot,
    required this.targetRot,
    required this.opacity,
    required this.index,
    required this.topCtrl,
    required this.bottomCtrl,
    required this.posTop,
    required this.posBottom,
    required this.activePanel,
    required this.selectedRange,
    required this.blurredWhite,
    required this.onNextImage,
    required this.onPrevImage,
    required this.onLike,
    required this.onUnlike,
    required this.onPanelSlideTop,
    required this.onPanelClosedTop,
    required this.onPanelSlideBottom,
    required this.onPanelClosedBottom,
    required this.onAboutOpenChanged,
    this.remainingAction,
  });

  @override
  ConsumerState<_CandidateView> createState() => _CandidateViewState();
}

class _CandidateViewState extends ConsumerState<_CandidateView> {
  Future<void>? _imagePrecacheFuture;
  bool _hasPreloaded = false;
  bool _isAboutOpen = false;
  bool _isInfoButtonPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasPreloaded && widget.candidate.photos.isNotEmpty) {
      _hasPreloaded = true;
      _imagePrecacheFuture =
          precacheImage(
            NetworkImage(widget.candidate.photos.first),
            context,
          ).catchError((e) {
            print('⚠️ Failed to precache image: $e');
            return null;
          });
    } else if (!_hasPreloaded) {
      _imagePrecacheFuture = Future.value();
      _hasPreloaded = true;
    }
  }

  @override
  void didUpdateWidget(covariant _CandidateView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _toggleAbout() {
    setState(() {
      _isAboutOpen = !_isAboutOpen;
    });
    widget.onAboutOpenChanged(_isAboutOpen);
  }

  Future<void> _handleLike() async {
    final quota = await ref.read(swipeQuotaProvider).checkSwipeStatus();

    if (quota.isRestricted && quota.remainingCount == 0) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'โควตาเต็มแล้ว',
        message: 'คุณปัดครบ 10 คนสำหรับวันนี้แล้วจ้า พรุ่งนี้มาหาคู่ใหม่นะ!',
        durationSeconds: 4,
      );
      return;
    }
    widget.onLike();
  }

  Future<void> _handlePass() async {
    final quota = await ref.read(swipeQuotaProvider).checkSwipeStatus();

    if (quota.isRestricted && quota.remainingCount == 0) {
      if (!mounted) return;
      Toast.show(
        context,
        type: ToastType.warning,
        title: 'โควตาเต็มแล้ว',
        message: 'คุณปัดครบ 10 คนสำหรับวันนี้แล้วจ้า พรุ่งนี้มาหาคู่ใหม่นะ!',
        durationSeconds: 4,
      );
      return;
    }
    widget.onUnlike();
  }

  void _handleImageTap(TapUpDetails details, double width, int imageCount) {
    if (imageCount <= 1) return;
    if (details.localPosition.dx < width / 2) {
      widget.onPrevImage(imageCount);
    } else {
      widget.onNextImage(imageCount);
    }
  }

  Widget _buildClosedTagChip(String label) {
    return Container(
      height: 27,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sell_outlined,
            size: 15,
            color: AppColors.background,
          ),
          const SizedBox(width: 5),
          Text(
            displaySelectionLabel(label),
            style: const TextStyle(
              fontSize: 14,
              height: 1.2,
              color: AppColors.textOnDark,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientChip(String label, {bool compact = false}) {
    final icon = mapSelectionIcon(label);
    final text = displaySelectionLabel(label);
    final height = compact ? 31.0 : 48.0;
    final radius = compact ? 30.0 : 12.0;
    final fontSize = compact ? 16.0 : 14.0;

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 5 : 12,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.themeApp2,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 18, color: AppColors.textBlack),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: fontSize,
                height: compact ? 1 : 20 / 14,
                color: AppColors.textBlack,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildAboutSection(
    String title,
    List<String> items, {
    bool compact = false,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Wrap(
          spacing: compact ? 12 : 15,
          runSpacing: compact ? 12 : 15,
          children: items
              .map((item) => _buildGradientChip(item, compact: compact))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDistanceField() {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: InputColors.border),
      ),
      child: Row(
        children: [
          Text(
            '${widget.candidate.distance.round()}',
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: AppColors.textBlack,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          const Text(
            'km.',
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              color: TextColors.supportText,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoToggleButton({required bool expanded}) {
    final isPressed = _isInfoButtonPressed;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isInfoButtonPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isInfoButtonPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isInfoButtonPressed = false;
        });
      },
      onTap: _toggleAbout,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        scale: isPressed ? 1.18 : 1.0,
        child: SizedBox(
          width: 44,
          height: 44,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: isPressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : const [],
            ),
            child: Center(
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                turns: expanded ? 0.5 : 0,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: isPressed ? 30 : 28,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSheet(double maxHeight) {
    final lifestyles = widget.candidate.lifestyles.take(4).toList();
    final interests = widget.candidate.interests.take(5).toList();
    final travelStyles = widget.candidate.travelStyles.take(3).toList();

    return Container(
      width: double.infinity,
      height: maxHeight,
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAboutSection('ไลฟ์สไตล์', lifestyles),
                      const SizedBox(height: 12),
                      _buildAboutSection('สิ่งที่สนใจ', interests),
                      const SizedBox(height: 12),
                      _buildAboutSection(
                        'สไตล์การท่องเที่ยว',
                        travelStyles,
                        compact: true,
                      ),
                      const SizedBox(height: 12),
                      _buildSectionTitle('ระยะห่าง'),
                      _buildDistanceField(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _imagePrecacheFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _DiscoveryImageLoadingArea();
        }

        final images = widget.candidate.photos;
        final bool hasImages = images.isNotEmpty;
        final String sex = widget.candidate.sex;
        final tags = widget.candidate.tags.take(5).toList();

        final t = Curves.easeOutCubic.transform(widget.cardCtrl.value);
        final dx =
            widget.startPos.dx + (widget.targetPos.dx - widget.startPos.dx) * t;
        final dy =
            widget.startPos.dy + (widget.targetPos.dy - widget.startPos.dy) * t;
        final rot = widget.startRot + (widget.targetRot - widget.startRot) * t;

        return LayoutBuilder(
          builder: (context, constraints) {
            final aboutTop = _isAboutOpen ? 0.0 : constraints.maxHeight + 24;
            final aboutHeight = constraints.maxHeight;

            return Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapUp: (details) => _handleImageTap(
                                  details,
                                  constraints.maxWidth,
                                  images.length,
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  fit: StackFit.expand,
                                  children: [
                                      ClipRect(
                                        child: Opacity(
                                          opacity: widget.opacity,
                                          child: Transform.translate(
                                            offset: Offset(dx, dy),
                                            child: Transform.rotate(
                                              angle: rot,
                                              child: hasImages
                                                  ? Image.network(
                                                      images[widget.index],
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return _buildImageFallback(sex);
                                                      },
                                                    )
                                                  : _buildImageFallback(sex),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: -28,
                                        right: -28,
                                        bottom: -18,
                                        child: IgnorePointer(
                                          child: ImageFiltered(
                                            imageFilter: ImageFilter.blur(
                                              sigmaX: 0,
                                              sigmaY: 18,
                                            ),
                                            child: Container(
                                              height: 278,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.vertical(
                                                  bottom: Radius.circular(42),
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  stops: [0.0, 0.22, 0.58, 1.0],
                                                  colors: [
                                                    Color(0x00000000),
                                                    Color(0x22000000),
                                                    Color(0xCC1F1F1F),
                                                    Colors.black,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (widget.remainingAction != null)
                                        Positioned(
                                          top: 18,
                                          right: 18,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.48),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.2),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.bolt_rounded,
                                                  size: 16,
                                                  color: AppColors.brandSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${widget.remainingAction}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textOnDark,
                                                    fontFamily: 'Inter',
                                                  ),
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
                          if (!_isAboutOpen)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 94,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        max(images.length, 1),
                                        (index) => Container(
                                          width: 5,
                                          height: 5,
                                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                          decoration: BoxDecoration(
                                            color: index == widget.index
                                                ? AppColors.background
                                                : Colors.white.withValues(alpha: 0.42),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${widget.candidate.nickname} (${widget.candidate.age})',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          height: 28 / 22,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textOnDark,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                    if (tags.isNotEmpty) ...[
                                      const SizedBox(height: 11),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Wrap(
                                          spacing: 5,
                                          runSpacing: 7,
                                          children: tags.map(_buildClosedTagChip).toList(),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            top: aboutTop,
                            left: 0,
                            right: 0,
                            height: aboutHeight,
                            child: _buildAboutSheet(aboutHeight),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!_isAboutOpen) ...[
                                  DsReactionButton(
                                    type: DsReactionButtonType.pass,
                                    onTap: _handlePass,
                                  ),
                                  const SizedBox(width: 25),
                                ],
                                _buildInfoToggleButton(expanded: _isAboutOpen),
                                if (!_isAboutOpen) ...[
                                  const SizedBox(width: 25),
                                  DsReactionButton(
                                    type: DsReactionButtonType.match,
                                    onTap: _handleLike,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
          },
        );
      },
    );
  }
}

/// ✅ สร้าง fallback widget สำหรับเวลารูปหาย
Widget _buildImageFallback(String? gender) {
  String assetPath;

  switch (gender?.toLowerCase()) {
    case 'female':
    case 'f':
      assetPath = 'assets/images/placeholders/female.jpg';
      break;
    case 'male':
    case 'm':
      assetPath = 'assets/images/placeholders/male.jpg';
      break;
    default:
      assetPath = 'assets/images/placeholders/female.jpg'; // หรือ default อื่น
  }

  return Image.asset(assetPath, fit: BoxFit.cover);
}

class _DiscoveryImageLoadingArea extends StatelessWidget {
  const _DiscoveryImageLoadingArea();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: const HomeSearchLoadingContent(),
    );
  }
}

class _EmptySuggestionLine extends StatelessWidget {
  final String text;

  const _EmptySuggestionLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                '•',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: TextColors.secondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: TextColors.secondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
