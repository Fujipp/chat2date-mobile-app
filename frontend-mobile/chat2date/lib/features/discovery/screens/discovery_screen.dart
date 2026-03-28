import 'dart:math';
import 'dart:ui';

import 'package:chat2date/components/buttons/ds_button.dart';
import 'package:chat2date/components/buttons/ds_svg_swap_button.dart';
import 'package:chat2date/components/common/custom_range_slider.dart';
import 'package:chat2date/components/common/modal_component.dart';
import 'package:chat2date/components/common/style_component.dart';
import 'package:chat2date/components/inputs/ds_label.dart';
import 'package:chat2date/components/layout/header.dart';
import 'package:chat2date/components/layout/menu_bar.dart';
import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/models/dto/discovery_dto.dart';
import 'package:chat2date/models/user.dart';
import 'package:chat2date/services/discovery_service.dart';
import 'package:chat2date/services/fcm_token_service.dart';
import 'package:chat2date/services/location_service.dart';
import 'package:chat2date/services/swipe_quota_service.dart';
import 'package:chat2date/services/user_service.dart';
import 'package:chat2date/stores/user_store.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    // ปิด settings overlay เมื่อมีการเปลี่ยนหน้า
    if (_isSettingsOpen) {
      _settingsOverlay?.remove();
      _settingsOverlay = null;
      _isSettingsOpen = false;
    }
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
        // ปิดก่อนนำทางเพื่อไม่ให้ overlay ติดตามไปหน้าถัดไป
        _settingsOverlay?.remove();
        _settingsOverlay = null;
        _isSettingsOpen = false;
        Navigator.pushReplacementNamed(context, '/chat-list');
        break;
      case 2:
        _settingsOverlay?.remove();
        _settingsOverlay = null;
        _isSettingsOpen = false;
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 3:
        _settingsOverlay?.remove();
        _settingsOverlay = null;
        _isSettingsOpen = false;
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

  // Settings
  OverlayEntry? _settingsOverlay;
  bool _isSettingsOpen = false;
  RangeValues _selectedRange = const RangeValues(0, 1800);
  void _closeSettingsOverlay() {
    if (_isSettingsOpen) {
      _settingsOverlay?.remove();
      _settingsOverlay = null;
      _isSettingsOpen = false;
    }
  }

  Future<void> _loadPersistedRange() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final start = prefs.getDouble('distanceRange:${_userId}:start');
      final end = prefs.getDouble('distanceRange:${_userId}:end');
      if (start != null && end != null) {
        setState(() {
          _selectedRange = RangeValues(
            start.clamp(0.0, 1800.0),
            end.clamp(0.0, 1800.0),
          );
        });
      }
    } catch (_) {}
  }

  // ✅ Key สำหรับบังคับให้ rebuild CandidateView
  Key _candidateKey = UniqueKey();

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
          _candidateKey = UniqueKey();
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
          _candidateKey = UniqueKey();
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
    _settingsOverlay?.remove();
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

  void _togglePanel(BuildContext context) {
    if (_isSettingsOpen) {
      _closeSettingsOverlay();
      return;
    }

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);

    _settingsOverlay = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setStateOverlay) {
          return Positioned(
            top: offset.dy + 80,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ตั้งค่าการค้นหา",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DsLabel(
                          label: 'ช่วงระยะห่างที่คุณอยากเจอ',
                          required: true,
                          labelFontSize: 20,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedRange.start.round()} Km.',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${_selectedRange.end.round()} Km.',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomRangeSlider(
                          values: _selectedRange,
                          min: 0,
                          max: 1800,
                          persistKey: _userId != null
                              ? 'distanceRange:${_userId}'
                              : null,
                          onChangeEnd: (r) async {
                            // sync ค่าที่แสดงกับที่บันทึกไว้
                            setStateOverlay(() {
                              _selectedRange = r;
                            });
                          },
                          onChanged: (RangeValues values) {
                            setStateOverlay(() {
                              _selectedRange = values;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: DsButton(
                            label: 'ยืนยัน',
                            onPressed: () async {
                              setStateOverlay(() {
                                _isSettingsOpen = false;
                              });
                              _settingsOverlay?.remove();
                              _settingsOverlay = null;

                              if (_userId != null) {
                                await ref
                                    .read(discoveryProvider(_userId!).notifier)
                                    .refresh(
                                      minDistance: _selectedRange.start.round(),
                                      maxDistance: _selectedRange.end.round(),
                                    );
                                final Map<String, Object> preferenceMatch = {
                                  "interestedDistanceMin": _selectedRange.start
                                      .round(),
                                  "interestedDistanceMax": _selectedRange.end
                                      .round(),
                                };
                                await ref
                                    .read(userServiceProvider)
                                    .addPreferenceMatchUser(preferenceMatch);

                                // ✅ สร้าง key ใหม่หลัง refresh
                                setState(() {
                                  _candidateKey = UniqueKey();
                                });
                              }
                            },
                            fontWeight: FontWeight.w700,
                            size: DsButtonSize.md,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    overlay.insert(_settingsOverlay!);
    _isSettingsOpen = true;
  }

  @override
  Widget build(BuildContext context) {
    // รอจนกว่าจะได้ userId
    if (_userId == null) {
      return Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 25),
            ChatToDateHeaderWhite(
              leftIconPath: 'assets/icons/ui/icon_chat2date_full.svg',
              rightIconPath: 'assets/icons/ui/icon_menu.svg',
              iconColor: const Color(0xFF5ce1e6),
              onBack: () {},
              onSettings: () {},
            ),
            const Expanded(child: _DiscoveryLoadingWidget()),
          ],
        ),
        bottomNavigationBar: widget.showBottomNav
            ? CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: _handleBottomNavTap,
              )
            : null,
      );
    }

    final discoveryState = ref.watch(discoveryProvider(_userId!));
    final currentCandidate = discoveryState.currentCandidate;

    // ✅ แสดง Loading ถ้ายังไม่เคยโหลด หรือกำลัง initialize
    if (discoveryState.isInitializing || !discoveryState.hasLoadedOnce) {
      return Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 25),
            ChatToDateHeaderWhite(
              leftIconPath: 'assets/icons/ui/icon_chat2date_full.svg',
              rightIconPath: 'assets/icons/ui/icon_menu.svg',
              iconColor: const Color(0xFF5ce1e6),
              onBack: () {},
              onSettings: () async {
                await ref
                    .read(locationServiceProvider)
                    .tryUpdateLocationSilently();
                _togglePanel(context);
              },
            ),
            const Expanded(child: _DiscoveryLoadingWidget()),
          ],
        ),
        bottomNavigationBar: widget.showBottomNav
            ? CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: _handleBottomNavTap,
              )
            : null,
      );
    }

    // แสดง error state
    if (discoveryState.error != null) {
      return Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 25),
            ChatToDateHeaderWhite(
              leftIconPath: 'assets/icons/ui/icon_chat2date_full.svg',
              rightIconPath: 'assets/icons/ui/icon_menu.svg',
              iconColor: const Color(0xFF5ce1e6),
              onBack: () {},
              onSettings: () async {
                await ref
                    .read(locationServiceProvider)
                    .tryUpdateLocationSilently();
                _togglePanel(context);
              },
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('เกิดข้อผิดพลาด: ${discoveryState.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(discoveryProvider(_userId!).notifier)
                            .refresh();
                        setState(() {
                          _candidateKey = UniqueKey();
                        });
                      },
                      child: const Text('ลองอีกครั้ง'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.showBottomNav
            ? CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: _handleBottomNavTap,
              )
            : null,
      );
    }

    // ✅ ไม่มี candidates (แต่โหลดเสร็จแล้ว)
    if (currentCandidate == null || discoveryState.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 25),
            ChatToDateHeaderWhite(
              leftIconPath: 'assets/icons/ui/icon_chat2date_full.svg',
              rightIconPath: 'assets/icons/ui/icon_menu.svg',
              iconColor: const Color(0xFF5ce1e6),
              onBack: () {},
              onSettings: () async {
                await ref
                    .read(locationServiceProvider)
                    .tryUpdateLocationSilently();
                _togglePanel(context);

                if (_userId != null) {
                  await ref
                      .read(discoveryProvider(_userId!).notifier)
                      .refresh(
                        minDistance: _selectedRange.start.round(),
                        maxDistance: _selectedRange.end.round(),
                      );

                  // รีเฟรช widget หรือแสดงข้อมูลใหม่
                  setState(() {
                    _candidateKey = UniqueKey(); // force rebuild widget
                  });
                }
              },
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFFF5F8).withOpacity(0.3),
                      const Color(0xFFFFE5ED).withOpacity(0.5),
                    ],
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with gradient background
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFE5EE), Color(0xFFFFCCDD)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8FB3).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_search,
                            size: 80,
                            color: Color(0xFFFF8FB3),
                          ),
                        ),

                        const SizedBox(height: 32),

                        const Text(
                          'ไม่พบคนที่เหมาะสมในขณะนี้',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'ไม่ต้องกังวล! เรามีคำแนะนำให้คุณ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Suggestions card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '💡 ลองปรับเปลี่ยน',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 16),

                              _SuggestionItem(
                                icon: Icons.location_on,
                                text: 'เพิ่มระยะทางการค้นหา',
                                color: const Color(0xFFFF8FB3),
                              ),
                              const SizedBox(height: 12),

                              _SuggestionItem(
                                icon: Icons.favorite,
                                text: 'ปรับประเภทคู่เดตที่สนใจ',
                                color: const Color(0xFFFF8FB3),
                              ),
                              const SizedBox(height: 12),

                              _SuggestionItem(
                                icon: Icons.refresh,
                                text: 'ลองค้นหาใหม่อีกครั้ง',
                                color: const Color(0xFFFF8FB3),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Action buttons
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await ref
                                      .read(
                                        discoveryProvider(_userId!).notifier,
                                      )
                                      .refresh(
                                        minDistance: _selectedRange.start
                                            .round(),
                                        maxDistance: _selectedRange.end.round(),
                                      );
                                  setState(() {
                                    _candidateKey = UniqueKey();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF8FB3),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.refresh, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'ค้นหาใหม่',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(locationServiceProvider)
                                      .tryUpdateLocationSilently();
                                  if (context.mounted) {
                                    _togglePanel(context);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFF8FB3),
                                  side: const BorderSide(
                                    color: Color(0xFFFF8FB3),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.tune, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'ปรับการตั้งค่า',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.showBottomNav
            ? CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: _handleBottomNavTap,
              )
            : null,
      );
    }

    // ✅ มี candidate - ใช้ CandidateView ที่มี FutureBuilder
    return _CandidateView(
      key: _candidateKey, // บังคับ rebuild เมื่อเปลี่ยน candidate
      userId: _userId!,
      candidate: currentCandidate,
      selectedIndex: _selectedIndex,
      showBottomNav: widget.showBottomNav,
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
      onTogglePanel: () => _togglePanel(context),
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
      onBottomNavTap: _handleBottomNavTap,
      remainingAction: remainingAction,
    );
  }
}

// ✅ Widget แยกสำหรับแสดง Candidate พร้อม Image Preloading
class _CandidateView extends ConsumerStatefulWidget {
  final String userId;
  final DiscoveryResponse candidate;
  final int selectedIndex;
  final bool showBottomNav;
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
  final VoidCallback onTogglePanel;
  final void Function(double) onPanelSlideTop;
  final VoidCallback onPanelClosedTop;
  final void Function(double) onPanelSlideBottom;
  final VoidCallback onPanelClosedBottom;
  final void Function(int) onBottomNavTap;
  final int? remainingAction;

  const _CandidateView({
    super.key,
    required this.userId,
    required this.candidate,
    required this.selectedIndex,
    required this.showBottomNav,
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
    required this.onTogglePanel,
    required this.onPanelSlideTop,
    required this.onPanelClosedTop,
    required this.onPanelSlideBottom,
    required this.onPanelClosedBottom,
    required this.onBottomNavTap,
    this.remainingAction,
  });

  @override
  ConsumerState<_CandidateView> createState() => _CandidateViewState();
}

class _CandidateViewState extends ConsumerState<_CandidateView> {
  Future<void>? _imagePrecacheFuture;
  bool _hasPreloaded = false;

  @override
  void initState() {
    super.initState();
    // ✅ ไม่ทำอะไรเลย
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
  Widget build(BuildContext context) {
    // ✅ Match listener ถูกย้ายไปอยู่ที่ GlobalMatchListener ใน main.dart แล้ว
    // ไม่ต้อง listen ที่นี่อีกต่อไป เพราะจะทำงานได้ทุกหน้าแล้ว

    // ✅ ใช้ FutureBuilder รอให้รูปโหลดเสร็จก่อนแสดง
    return FutureBuilder<void>(
      future: _imagePrecacheFuture,
      builder: (context, snapshot) {
        // ยังโหลดรูปอยู่ - แสดง Loading
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Column(
              children: [
                const SizedBox(height: 25),
                ChatToDateHeaderWhite(
                  leftIconPath: 'assets/icons/ui/icon_chat2date_full.svg',
                  rightIconPath: 'assets/icons/ui/icon_menu.svg',
                  iconColor: const Color(0xFF5ce1e6),
                  onBack: () {},
                  onSettings: () async {
                    await ref
                        .read(locationServiceProvider)
                        .tryUpdateLocationSilently();
                    widget.onTogglePanel();
                  },
                ),
                const Expanded(child: _DiscoveryLoadingWidget()),
              ],
            ),
            bottomNavigationBar: widget.showBottomNav
                ? CustomBottomNavBar(
                    selectedIndex: widget.selectedIndex,
                    onTap: widget.onBottomNavTap,
                  )
                : null,
          );
        }

        // รูปโหลดเสร็จแล้ว - แสดงข้อมูล candidate
        final images = widget.candidate.photos;

        // ✅ กรณีไม่มีรูปเลย → ใช้ placeholder แทน
        final bool hasImages = images.isNotEmpty;

        final String sex = widget.candidate.sex;

        final headerTop = [
          {
            'title': 'สไตล์การท่องเที่ยว',
            'style': widget.candidate.travelStyles,
          },
          {'title': 'ระยะห่าง', 'range': widget.candidate.distance},
        ];

        final headerBottom = [
          {
            'title': 'ความสนใจ',
            'style': widget.candidate.interests.take(5).toList(), // ไม่เกิน 5
          },
          {
            'title': 'ไลฟ์สไตล์',
            'style': widget.candidate.lifestyles.take(5).toList(), // ไม่เกิน 5
          },
        ];

        final t = Curves.easeOutCubic.transform(widget.cardCtrl.value);
        final dx =
            widget.startPos.dx + (widget.targetPos.dx - widget.startPos.dx) * t;
        final dy =
            widget.startPos.dy + (widget.targetPos.dy - widget.startPos.dy) * t;
        final rot = widget.startRot + (widget.targetRot - widget.startRot) * t;

        return Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 25),
              ChatToDateHeaderWhite(
                leftIconPath: 'assets/icons/ui/icon_chat2date_full.svg',
                rightIconPath: 'assets/icons/ui/icon_menu.svg',
                iconColor: const Color(0xFF5ce1e6),
                onBack: () {},
                onSettings: () async {
                  await ref
                      .read(locationServiceProvider)
                      .tryUpdateLocationSilently();
                  widget.onTogglePanel();
                },
              ),

              // ===== Canvas (ภาพ + Panels + Overlay) =====
              SizedBox(
                width: double.infinity,
                height: 585,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // --- Profile image (with animation) ---
                    Opacity(
                      opacity: widget.opacity,
                      child: Transform.translate(
                        offset: Offset(dx, dy),
                        child: Transform.rotate(
                          angle: rot,
                          child: hasImages
                              ? Image.network(
                                  images[widget
                                      .index], // ✅ ใช้ได้เพราะเช็คแล้วว่าไม่ว่าง
                                  width: double.infinity,
                                  height: 585,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImageFallback(sex);
                                  },
                                )
                              : _buildImageFallback(sex),
                        ),
                      ),
                    ),

                    if (widget.remainingAction !=
                        null) // แสดงเฉพาะเมื่อมีการจำกัดโควตา
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(
                              0.5,
                            ), // พื้นหลังมืดเพื่อให้เลขสีขาวเด่น
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt, // ไอคอนสายฟ้าสื่อถึงพลังงาน/โควตา
                                color: Color(0xFFFFD700), // สีทอง
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.remainingAction}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // --- Bottom Panel ---
                    if (widget.activePanel.value != ActivePanel.top)
                      ValueListenableBuilder(
                        valueListenable: widget.activePanel,
                        builder: (context, value, _) {
                          if (value == ActivePanel.top) {
                            return const SizedBox.shrink();
                          }
                          return IgnorePointer(
                            ignoring:
                                widget.activePanel.value == ActivePanel.top,
                            child: SlidingUpPanel(
                              controller: widget.bottomCtrl,
                              maxHeight: 436,
                              minHeight: 40,
                              color: widget.blurredWhite(widget.posBottom),
                              backdropEnabled: value == ActivePanel.bottom,
                              isDraggable: value != ActivePanel.top,
                              panelSnapping: true,
                              collapsed: const Center(
                                child: Icon(
                                  Icons.keyboard_double_arrow_up,
                                  color: Colors.white,
                                ),
                              ),
                              onPanelSlide: widget.onPanelSlideBottom,
                              onPanelClosed: widget.onPanelClosedBottom,
                              panel: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5 * widget.posBottom,
                                    sigmaY: 5 * widget.posBottom,
                                  ),
                                  child: Container(
                                    color: Colors.white.withOpacity(
                                      0.2 * widget.posBottom,
                                    ),
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 40,
                                          ).copyWith(
                                            bottom: 56,
                                          ), // กัน content ชิดขอบตอนเลื่อน
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          HeadersWithStyles(headers: headerTop),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    // --- Top Panel ---
                    if (widget.activePanel.value != ActivePanel.bottom)
                      IgnorePointer(
                        ignoring:
                            widget.activePanel.value == ActivePanel.bottom,
                        child: ValueListenableBuilder(
                          valueListenable: widget.activePanel,
                          builder: (context, value, _) {
                            return SlidingUpPanel(
                              controller: widget.topCtrl,
                              slideDirection: SlideDirection.DOWN,
                              maxHeight: 436,
                              minHeight: 40,
                              color: widget.blurredWhite(widget.posTop),
                              backdropEnabled: value == ActivePanel.top,
                              isDraggable: value != ActivePanel.bottom,
                              panelSnapping: true,
                              collapsed: const Center(
                                child: Icon(
                                  Icons.keyboard_double_arrow_down,
                                  color: Colors.white,
                                ),
                              ),
                              onPanelSlide: widget.onPanelSlideTop,
                              onPanelClosed: widget.onPanelClosedTop,
                              panel: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5 * widget.posTop,
                                    sigmaY: 5 * widget.posTop,
                                  ),
                                  child: Container(
                                    color: Colors.white.withOpacity(
                                      0.2 * widget.posTop,
                                    ),
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 32,
                                      ).copyWith(bottom: 56),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          HeadersWithStyles(
                                            headers: headerBottom,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // --- Action buttons ---
                    // UNLIKE (ซ้าย)
                    ValueListenableBuilder<ActivePanel>(
                      valueListenable: widget.activePanel,
                      builder: (context, value, _) {
                        final panelsClosed = value == ActivePanel.none;
                        if (!panelsClosed) return const SizedBox.shrink();

                        return Positioned(
                          left: 75,
                          bottom: -30,
                          child: DsSvgSwapButton(
                            assetA: 'assets/icons/ui/icon_unlike.svg', // 60 x 60
                            assetB:
                                'assets/icons/ui/icon_unlike_active.svg', // 80 x 80
                            iconSize: 60,
                            activeIconSize: 80,
                            padding: 0,
                            onPressed: () async {
                              final quota = await ref
                                  .read(swipeQuotaProvider)
                                  .checkSwipeStatus();

                              if (quota.isRestricted &&
                                  quota.remainingCount == 0) {
                                Toast.show(
                                  context,
                                  type: ToastType.warning,
                                  title: 'โควตาเต็มแล้ว',
                                  message:
                                      'คุณปัดครบ 10 คนสำหรับวันนี้แล้วจ้า พรุ่งนี้มาหาคู่ใหม่นะ!',
                                  durationSeconds: 4,
                                );
                              } else {
                                widget.onUnlike();
                              }
                            },
                          ),
                        );
                      },
                    ),

                    // LIKE (ขวา)
                    ValueListenableBuilder<ActivePanel>(
                      valueListenable: widget.activePanel,
                      builder: (context, value, _) {
                        final panelsClosed = value == ActivePanel.none;
                        if (!panelsClosed) return const SizedBox.shrink();

                        return Positioned(
                          right: 75,
                          bottom: -30,
                          child: DsSvgSwapButton(
                            assetA: 'assets/icons/ui/icon_heart.svg', // 60 x 60
                            assetB:
                                'assets/icons/ui/icon_heart_active.svg', // 77 x 77
                            iconSize: 60,
                            activeIconSize: 77,
                            padding: 0,
                            onPressed: () async {
                              final quota = await ref
                                  .read(swipeQuotaProvider)
                                  .checkSwipeStatus();

                              if (quota.isRestricted &&
                                  quota.remainingCount == 0) {
                                Toast.show(
                                  context,
                                  type: ToastType.warning,
                                  title: 'โควตาเต็มแล้ว',
                                  message:
                                      'คุณปัดครบ 10 คนสำหรับวันนี้แล้วจ้า พรุ่งนี้มาหาคู่ใหม่นะ!',
                                  durationSeconds: 4,
                                );
                              } else {
                                widget.onLike();
                              }
                            },
                          ),
                        );
                      },
                    ),

                    // arrows + name + tags
                    ValueListenableBuilder<ActivePanel>(
                      valueListenable: widget.activePanel,
                      builder: (context, value, _) {
                        final panelsClosed = value == ActivePanel.none;

                        return Stack(
                          children: [
                            if (panelsClosed) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 65,
                                  horizontal: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Spacer(),
                                    Row(
                                      children: [
                                        _ArrowButton(
                                          icon: Icons.chevron_left,
                                          onTap: () =>
                                              widget.onPrevImage(images.length),
                                        ),
                                        const Spacer(),
                                        _ArrowButton(
                                          icon: Icons.chevron_right,
                                          onTap: () =>
                                              widget.onNextImage(images.length),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 118),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: SizedBox(
                                        width: 311,
                                        child: Text(
                                          '${widget.candidate.nickname}, ${widget.candidate.age}',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            color: Colors.white,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (widget.candidate.tags.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Wrap(
                                          spacing: 5,
                                          runSpacing: 7,
                                          children: widget.candidate.tags.map((
                                            tag,
                                          ) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              height: 27,
                                              constraints: const BoxConstraints(
                                                minWidth: 60,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.btnPrimary,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/ui/icon_tag.svg',
                                                    width: 24,
                                                    height: 24,
                                                  ),
                                                  Text(
                                                    tag,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: widget.showBottomNav
              ? CustomBottomNavBar(
                  selectedIndex: widget.selectedIndex,
                  onTap: widget.onBottomNavTap,
                )
              : null,
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

  return SizedBox(
    width: double.infinity,
    height: 585,
    child: Image.asset(assetPath, fit: BoxFit.cover),
  );
}

// ✨ Beautiful Loading Widget (เหมือนเดิม)

class _DiscoveryLoadingWidget extends StatefulWidget {
  const _DiscoveryLoadingWidget();

  @override
  State<_DiscoveryLoadingWidget> createState() =>
      _DiscoveryLoadingWidgetState();
}

class _DiscoveryLoadingWidgetState extends State<_DiscoveryLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _pulseController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 585,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFF5F8).withOpacity(0.3),
                const Color(0xFFFFE5ED).withOpacity(0.5),
                const Color(0xFFFFF0F5).withOpacity(0.4),
              ],
              stops: [
                (_shimmerController.value - 0.2).clamp(0.0, 1.0),
                _shimmerController.value.clamp(0.0, 1.0),
                (_shimmerController.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Subtle background card
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFFB3C6).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB3C6).withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),

              // Center content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Heart with pulse effect
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse ring
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = 1.0 + (_pulseController.value * 0.3);
                            final opacity =
                                (1.0 - _pulseController.value) * 0.5;
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFF8FB3,
                                    ).withOpacity(opacity),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Main heart
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.95, end: 1.05),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFE5EE),
                                      Color(0xFFFFCCDD),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF8FB3,
                                      ).withOpacity(0.3),
                                      blurRadius: 35,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  size: 64,
                                  color: Color(0xFFFF8FB3),
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Text
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFB3C6).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'กำลังค้นหาคนที่ใช่สำหรับคุณ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF8FB3),
                          fontFamily: 'Inter',
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Animated dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            final delay = index * 0.15;
                            final progress =
                                (_shimmerController.value + delay) % 1.0;
                            final opacity = (sin(progress * pi * 2) + 1) / 2;
                            final scale = 0.7 + (opacity * 0.3);

                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(
                                    0xFFFF8FB3,
                                  ).withOpacity(opacity),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF8FB3,
                                      ).withOpacity(opacity * 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Bottom shimmer bars
              Positioned(
                bottom: 80,
                left: 32,
                right: 32,
                child: Column(
                  children: [
                    _ShimmerBar(
                      width: double.infinity,
                      height: 16,
                      animation: _shimmerController,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ShimmerBar(
                            width: double.infinity,
                            height: 32,
                            animation: _shimmerController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ShimmerBar(
                            width: double.infinity,
                            height: 32,
                            animation: _shimmerController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final double width;
  final double height;
  final Animation<double> animation;

  const _ShimmerBar({
    required this.width,
    required this.height,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFFFE5EE).withOpacity(0.3),
            const Color(0xFFFFB3C6).withOpacity(0.4),
            const Color(0xFFFFCCDD).withOpacity(0.35),
            const Color(0xFFFFE5EE).withOpacity(0.3),
          ],
          stops: [
            (animation.value - 0.3).clamp(0.0, 1.0),
            (animation.value - 0.05).clamp(0.0, 1.0),
            (animation.value + 0.05).clamp(0.0, 1.0),
            (animation.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFB3C6).withOpacity(0.25),
          width: 1,
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 22,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 50),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SuggestionItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF666666),
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}
