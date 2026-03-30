import 'dart:convert';

import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/core/theme/app_assets.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const MarkerId _currentMarkerId = MarkerId('current');
const MarkerId _partnerMarkerId = MarkerId('partner');
const MarkerId _partnerApproxMarkerId = MarkerId('partner_approx');
const MarkerId _destinationMarkerId = MarkerId('destination');
const PolylineId _routePolylineId = PolylineId('route');

LatLngBounds _boundsFromPoints(List<LatLng> points) {
  assert(points.isNotEmpty);
  double minLat = points.first.latitude;
  double maxLat = points.first.latitude;
  double minLng = points.first.longitude;
  double maxLng = points.first.longitude;

  for (final point in points.skip(1)) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLng) minLng = point.longitude;
    if (point.longitude > maxLng) maxLng = point.longitude;
  }

  final latPadding = (maxLat - minLat).abs() < 0.0006 ? 0.0018 : 0.0;
  final lngPadding = (maxLng - minLng).abs() < 0.0006 ? 0.0018 : 0.0;

  return LatLngBounds(
    southwest: LatLng(minLat - latPadding, minLng - lngPadding),
    northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
  );
}

// ===================== Full Screen Map Page =====================
class FullScreenMapPage extends StatefulWidget {
  final String? destinationPlaceId;
  final String googleApiKey;
  final LatLng? partnerLocation;

  const FullScreenMapPage({
    super.key,
    required this.destinationPlaceId,
    required this.googleApiKey,
    this.partnerLocation,
  });

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Stream<Position>? _positionStream;
  LatLng? _lastRouteOrigin;
  DateTime? _lastRouteRefreshedAt;
  LatLng? _lastDestinationLatLng;
  bool _isRouteLoading = false;
  bool _hasAppliedInitialScope = false;

  @override
  void initState() {
    super.initState();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
      ),
    );
  }

  Future<void> _drawRoute([LatLng? currentLocation]) async {
    if (widget.destinationPlaceId == null || _isRouteLoading) return;

    final pos = currentLocation == null
        ? await Geolocator.getCurrentPosition()
        : null;
    final originLatLng = currentLocation ?? LatLng(pos!.latitude, pos.longitude);
    if (!_shouldRefreshRoute(originLatLng)) {
      _updateCurrentMarkers(originLatLng);
      return;
    }
    _isRouteLoading = true;
    final origin = '${originLatLng.latitude},${originLatLng.longitude}';
    final dest = 'place_id:${widget.destinationPlaceId}';

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$origin'
      '&destination=$dest'
      '&key=${widget.googleApiKey}'
      '&language=th',
    );

    final res = await http.get(url);
    final data = json.decode(res.body);
    if (!mounted) {
      _isRouteLoading = false;
      return;
    }

    if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
      final points = _decodePolyline(
        data['routes'][0]['overview_polyline']['points'],
      );

      final endLocation = data['routes'][0]['legs'][0]['end_location'];
      final destLatLng = LatLng(endLocation['lat'], endLocation['lng']);

      setState(() {
        _polylines = {
          Polyline(
            polylineId: _routePolylineId,
            points: points,
            color: AppColors.brandPrimary,
            width: 4,
          ),
        };
        _lastDestinationLatLng = destLatLng;
        _applyMapDecorations(
          currentLocation: originLatLng,
          destinationLocation: destLatLng,
          destinationTitle: data['routes'][0]['legs'][0]['end_address']?.toString(),
        );
      });
      _scopeToRelevantArea(
        currentLocation: originLatLng,
        destinationLocation: destLatLng,
        routePoints: points,
      );
      _lastRouteOrigin = originLatLng;
      _lastRouteRefreshedAt = DateTime.now();
    }
    _isRouteLoading = false;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  void _updateCurrentMarkers(LatLng currentLocation) {
    if (!mounted) return;
    setState(() {
      _applyMapDecorations(
        currentLocation: currentLocation,
        destinationLocation: _lastDestinationLatLng,
      );
    });
    _scopeToRelevantArea(
      currentLocation: currentLocation,
      destinationLocation: _lastDestinationLatLng,
    );
  }

  bool _shouldRefreshRoute(LatLng origin) {
    final lastOrigin = _lastRouteOrigin;
    final lastAt = _lastRouteRefreshedAt;
    if (lastOrigin == null || lastAt == null) return true;
    final movedMeters = Geolocator.distanceBetween(
      lastOrigin.latitude,
      lastOrigin.longitude,
      origin.latitude,
      origin.longitude,
    );
    final elapsed = DateTime.now().difference(lastAt);
    return movedMeters >= 25 || elapsed >= const Duration(seconds: 15);
  }

  void _applyMapDecorations({
    required LatLng currentLocation,
    LatLng? destinationLocation,
    String? destinationTitle,
  }) {
    _markers
      ..removeWhere(
        (marker) => marker.markerId == _currentMarkerId,
      )
      ..removeWhere(
        (marker) => marker.markerId == _destinationMarkerId,
      )
      ..removeWhere(
        (marker) => marker.markerId == _partnerMarkerId,
      )
      ..removeWhere(
        (marker) => marker.markerId == _partnerApproxMarkerId,
      )
      ..add(
        Marker(
          markerId: _currentMarkerId,
          position: currentLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRose,
          ),
          infoWindow: const InfoWindow(title: 'ตำแหน่งของฉัน'),
        ),
      );

    if (destinationLocation != null) {
      _markers.add(
        Marker(
          markerId: _destinationMarkerId,
          position: destinationLocation,
          infoWindow: InfoWindow(title: destinationTitle ?? 'สถานที่เดต'),
        ),
      );
    }
  }

  Future<void> _scopeToRelevantArea({
    required LatLng currentLocation,
    LatLng? destinationLocation,
    List<LatLng>? routePoints,
    bool force = false,
  }) async {
    final controller = _mapController;
    if (controller == null) return;
    if (_hasAppliedInitialScope && !force) return;

    final points = <LatLng>[currentLocation];
    if (routePoints != null && routePoints.isNotEmpty) {
      points.addAll(routePoints);
    } else if (destinationLocation != null) {
      points.add(destinationLocation);
    }

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      _hasAppliedInitialScope = true;
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(_boundsFromPoints(points), 56),
    );
    _hasAppliedInitialScope = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<Position>(
            stream: _positionStream,
            builder: (context, snapshot) {
              final currentLocation = snapshot.hasData
                  ? LatLng(snapshot.data!.latitude, snapshot.data!.longitude)
                  : const LatLng(0, 0);

              if (snapshot.hasData && _mapController != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (widget.destinationPlaceId != null) {
                    _drawRoute(currentLocation);
                  } else {
                    _updateCurrentMarkers(currentLocation);
                  }
                });
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLocation,
                  zoom: snapshot.hasData ? 15 : 2,
                ),
                onMapCreated: (controller) async {
                  _mapController = controller;

                  if (snapshot.hasData) {
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(currentLocation, 15),
                    );
                    _hasAppliedInitialScope = false;

                    if (widget.destinationPlaceId != null) {
                      _drawRoute(currentLocation);
                    } else {
                      _updateCurrentMarkers(currentLocation);
                    }
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                polylines: _polylines,
              );
            },
          ),

          // Back button (top-left)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                      boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== Alert Action Button =====================
class _AlertActionButton extends StatelessWidget {
  final Widget icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _AlertActionButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: iconColor, size: 26),
              child: DefaultTextStyle(
                style: TextStyle(color: iconColor),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== GpsMapAlert =====================
class GpsMapAlert extends StatefulWidget {
  const GpsMapAlert({
    super.key,
    required this.onLocate,
    required this.onShareLocation,
    required this.onSosTriggered,
    required this.emergencyNumbers,
    required this.destinationPlaceId,
    required this.googleApiKey,
    this.partnerLocation,
  });

  final VoidCallback onLocate;
  final VoidCallback onShareLocation;
  final Future<void> Function(String calledNumber) onSosTriggered;
  final List<String> emergencyNumbers;
  final String? destinationPlaceId;
  final String googleApiKey;
  final LatLng? partnerLocation;

  @override
  State<GpsMapAlert> createState() => _GpsMapAlertState();
}

class _GpsMapAlertState extends State<GpsMapAlert>
    with WidgetsBindingObserver {
  LatLng? _lastRouteOrigin;
  DateTime? _lastRouteRefreshedAt;
  LatLng? _lastDestinationLatLng;
  bool _isRouteLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;

    final isKeyboardUp = bottomInset > 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (isKeyboardUp && _isExpanded) {
        setState(() {
          _isKeyboardVisible = isKeyboardUp;
          _showMapContent = false;
          _isExpanded = false;
        });
      } else if (isKeyboardUp != _isKeyboardVisible) {
        setState(() {
          _isKeyboardVisible = isKeyboardUp;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasSosTriggered) {
      _hasSosTriggered = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Toast.show(
            context,
            type: ToastType.info,
            title: 'บันทึกหลักฐานแล้ว',
            message: 'ติดต่อแอดมินเพื่อขอพิกัดและเวลาได้เลย',
            durationSeconds: 5,
          );
        }
      });
    }
  }

  bool _isExpanded = false;
  bool _showMapContent = false;
  bool _hasSosTriggered = false;
  bool _isKeyboardVisible = false;

  int _emergencyStep = 0;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Stream<Position>? _positionStream;

  Future<void> _drawRoute([LatLng? currentLocation]) async {
    if (widget.destinationPlaceId == null || _isRouteLoading) return;

    final pos = currentLocation == null
        ? await Geolocator.getCurrentPosition()
        : null;
    final originLatLng = currentLocation ?? LatLng(pos!.latitude, pos.longitude);
    if (!_shouldRefreshRoute(originLatLng)) {
      _updateCurrentMarkers(originLatLng);
      return;
    }
    _isRouteLoading = true;
    final origin = '${originLatLng.latitude},${originLatLng.longitude}';
    final dest = 'place_id:${widget.destinationPlaceId}';

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$origin'
      '&destination=$dest'
      '&key=${widget.googleApiKey}'
      '&language=th',
    );

    final res = await http.get(url);
    final data = json.decode(res.body);
    if (!mounted) {
      _isRouteLoading = false;
      return;
    }

    if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
      final points = _decodePolyline(
        data['routes'][0]['overview_polyline']['points'],
      );

      final endLocation = data['routes'][0]['legs'][0]['end_location'];
      final destLatLng = LatLng(endLocation['lat'], endLocation['lng']);

      setState(() {
        _polylines = {
          Polyline(
            polylineId: _routePolylineId,
            points: points,
            color: AppColors.brandPrimary,
            width: 4,
          ),
        };
        _lastDestinationLatLng = destLatLng;
        _applyMapMarkers(
          currentLocation: originLatLng,
          destinationLocation: destLatLng,
          destinationTitle: data['routes'][0]['legs'][0]['end_address']?.toString(),
        );
      });
      _scopeModalMap(
        currentLocation: originLatLng,
        destinationLocation: destLatLng,
        routePoints: points,
      );
      _lastRouteOrigin = originLatLng;
      _lastRouteRefreshedAt = DateTime.now();
    }
    _isRouteLoading = false;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  void _updateCurrentMarkers(LatLng currentLocation) {
    if (!mounted) return;
    setState(() {
      _applyMapMarkers(
        currentLocation: currentLocation,
        destinationLocation: _lastDestinationLatLng,
      );
    });
    _scopeModalMap(
      currentLocation: currentLocation,
      destinationLocation: _lastDestinationLatLng,
    );
  }

  // Kept as a compatibility hook for stale post-frame callbacks after hot reload.
  // ignore: unused_element
  void _maybeFollowCurrentLocation(LatLng currentLocation) {
    _scopeModalMap(
      currentLocation: currentLocation,
      destinationLocation: _lastDestinationLatLng,
    );
  }

  bool _shouldRefreshRoute(LatLng origin) {
    final lastOrigin = _lastRouteOrigin;
    final lastAt = _lastRouteRefreshedAt;
    if (lastOrigin == null || lastAt == null) return true;
    final movedMeters = Geolocator.distanceBetween(
      lastOrigin.latitude,
      lastOrigin.longitude,
      origin.latitude,
      origin.longitude,
    );
    final elapsed = DateTime.now().difference(lastAt);
    return movedMeters >= 25 || elapsed >= const Duration(seconds: 15);
  }

  void _applyMapMarkers({
    required LatLng currentLocation,
    LatLng? destinationLocation,
    String? destinationTitle,
  }) {
    _markers
      ..removeWhere((marker) => marker.markerId == _currentMarkerId)
      ..removeWhere((marker) => marker.markerId == _destinationMarkerId)
      ..removeWhere((marker) => marker.markerId == _partnerMarkerId)
      ..add(
        Marker(
          markerId: _currentMarkerId,
          position: currentLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRose,
          ),
          infoWindow: const InfoWindow(title: 'ตำแหน่งของฉัน'),
        ),
      );

    if (destinationLocation != null) {
      _markers.add(
        Marker(
          markerId: _destinationMarkerId,
          position: destinationLocation,
          infoWindow: InfoWindow(title: destinationTitle ?? 'สถานที่เดต'),
        ),
      );
    }

    if (widget.partnerLocation != null) {
      _markers.add(
        Marker(
          markerId: _partnerMarkerId,
          position: widget.partnerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'คู่เดตของคุณ'),
        ),
      );
    }
  }

  Future<void> _scopeModalMap({
    required LatLng currentLocation,
    LatLng? destinationLocation,
    List<LatLng>? routePoints,
  }) async {
    final controller = _mapController;
    if (controller == null) return;

    final points = <LatLng>[currentLocation];
    if (routePoints != null && routePoints.isNotEmpty) {
      points.addAll(routePoints);
    } else if (destinationLocation != null) {
      points.add(destinationLocation);
    }
    if (widget.partnerLocation != null) {
      points.add(widget.partnerLocation!);
    }

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(_boundsFromPoints(points), 42),
    );
  }

  List<String> get _emergencyTexts {
    final int total = widget.emergencyNumbers.length;
    return [
      'กดอีก 2 ครั้งเพื่อส่งสัญญาณฉุกเฉิน\nและโทรหาเบอร์ฉุกเฉินลำดับที่ 1 และแจ้งเตือนแอดมิน',
      'กดอีก 1 ครั้งเพื่อส่งสัญญาณฉุกเฉิน\nและโทรหาเบอร์ฉุกเฉินลำดับที่ 1 และแจ้งเตือนแอดมิน',
      if (total >= 2)
        'กดอีก 1 ครั้งเพื่อโทรหาเบอร์ฉุกเฉินลำดับที่ 2\nและแจ้งเตือนแอดมิน'
      else
        'กดอีก 1 ครั้งเพื่อโทรหา 191\nและแจ้งเตือนแอดมิน',
      if (total >= 3)
        'กดอีก 1 ครั้งเพื่อโทรหาเบอร์ฉุกเฉินลำดับที่ 3\nและแจ้งเตือนแอดมิน'
      else
        'กดอีก 1 ครั้งเพื่อโทรหา 191\nและแจ้งเตือนแอดมิน',
    ];
  }

  void _toggleExpansion() {
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;
    final isKeyboardCurrentlyUp = bottomInset > 0;

    if (isKeyboardCurrentlyUp) {
      FocusScope.of(context).unfocus(); // สั่งเก็บคีย์บอร์ด
    }

    final delayMs = isKeyboardCurrentlyUp && !_isExpanded ? 280 : 0;
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      setState(() {
        _isExpanded = !_isExpanded;
        if (!_isExpanded) {
          _showMapContent = false;
        }
      });
      if (_isExpanded) {
        Future.delayed(const Duration(milliseconds: 110), () {
          if (!mounted || !_isExpanded) return;
          setState(() {
            _showMapContent = true;
          });
        });
      }
    });
  }

  void _handleMapPressed() {
    widget.onLocate();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) => FullScreenMapPage(
          destinationPlaceId: widget.destinationPlaceId,
          googleApiKey: widget.googleApiKey,
          partnerLocation: widget.partnerLocation,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _handleSharePressed() {
    widget.onShareLocation();
  }

  void _handleEmergencyPressed() {
    setState(() {
      _emergencyStep += 1;
    });

    if (_emergencyStep >= 3) {
      _triggerEmergency(callIndex: _emergencyStep - 3); // 0, 1, 2
    }
  }

  void _triggerEmergency({int callIndex = 0}) {
    final String number;
    if (callIndex < widget.emergencyNumbers.length) {
      number = widget.emergencyNumbers[callIndex].replaceAll('-', '');
    } else {
      number = '191';
    }

    launchUrl(Uri(scheme: 'tel', path: number));
    _hasSosTriggered = true;
    widget.onSosTriggered(number);
  }

  String _getCurrentInstructionText() {
    if (_emergencyStep > 0) {
      final texts = _emergencyTexts;
      final idx = (_emergencyStep - 1).clamp(0, texts.length - 1);
      return texts[idx];
    }
    return '';
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AlertActionButton(
          icon: SvgPicture.asset(
            'assets/icons/ui/icon_share.svg',
            width: 25,
            height: 25,
            colorFilter: const ColorFilter.mode(
              AppColors.brandPrimary,
              BlendMode.srcIn,
            ),
          ),
          iconColor: AppColors.brandPrimary,
          onTap: _handleSharePressed,
        ),
        const SizedBox(width: 40),
        _AlertActionButton(
          icon: SvgPicture.asset(
            'assets/icons/ui/icon_emergency.svg',
            width: 25,
            height: 25,
            colorFilter: const ColorFilter.mode(
              AppColors.error,
              BlendMode.srcIn,
            ),
          ),
          iconColor: AppColors.error,
          onTap: _handleEmergencyPressed,
        ),
        const SizedBox(width: 40),
        _AlertActionButton(
          icon: SvgPicture.asset(
            AppAssets.gpsMapIcon,
            width: 25,
            height: 21,
          ),
          iconColor: AppColors.brandSecondary,
          onTap: _handleMapPressed,
        ),
      ],
    );
  }

  Widget _buildInstructionText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Text(
        _getCurrentInstructionText(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.error,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.375,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isExpanded
        ? AppColors.textBlack.withValues(alpha: 0.08)
        : AppColors.inputBorder;
    const expandedMapHeight = 223.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleExpansion,
              child: SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(
                        child: Text(
                          'LOCATION',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textBlack,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ClipRect(
              child: AnimatedContainer(
                duration: _isKeyboardVisible
                    ? Duration.zero
                    : const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                height: _isExpanded ? expandedMapHeight : 0,
                width: double.infinity,
                child: !_showMapContent
                    ? const SizedBox.shrink()
                    : StreamBuilder<Position>(
                        stream: _positionStream,
                        builder: (context, snapshot) {
                          final currentLocation = snapshot.hasData
                              ? LatLng(
                                  snapshot.data!.latitude,
                                  snapshot.data!.longitude,
                                )
                              : const LatLng(0, 0);

                          if (snapshot.hasData && _mapController != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (widget.destinationPlaceId != null) {
                                _drawRoute(currentLocation);
                              } else {
                                _updateCurrentMarkers(currentLocation);
                              }
                            });
                          }

                          return GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: currentLocation,
                              zoom: snapshot.hasData ? 15 : 2,
                            ),
                            onMapCreated: (controller) async {
                              _mapController = controller;
                              if (snapshot.hasData) {
                                controller.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    currentLocation,
                                    15,
                                  ),
                                );
                                if (widget.destinationPlaceId != null) {
                                  _drawRoute(currentLocation);
                                } else {
                                  _updateCurrentMarkers(currentLocation);
                                }
                              }
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                            markers: _markers,
                            polylines: _polylines,
                          );
                        },
                      ),
              ),
            ),
            if (_isExpanded && _emergencyStep > 0) _buildInstructionText(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                _isExpanded ? 12 : 10,
                20,
                10,
              ),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }
}
