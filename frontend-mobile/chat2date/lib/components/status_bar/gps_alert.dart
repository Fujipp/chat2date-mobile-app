import 'dart:convert';

import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ===================== Full Screen Map Page =====================
class FullScreenMapPage extends StatefulWidget {
  final String? destinationPlaceId;
  final String googleApiKey;

  const FullScreenMapPage({
    super.key,
    required this.destinationPlaceId,
    required this.googleApiKey,
  });

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  Future<void> _drawRoute() async {
    if (widget.destinationPlaceId == null) return;

    final pos = await Geolocator.getCurrentPosition();
    final origin = '${pos.latitude},${pos.longitude}';
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

    if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
      final points = _decodePolyline(
        data['routes'][0]['overview_polyline']['points'],
      );

      final endLocation = data['routes'][0]['legs'][0]['end_location'];
      final destLatLng = LatLng(endLocation['lat'], endLocation['lng']);

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 4,
          ),
        };
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destLatLng,
            infoWindow: InfoWindow(
              title: data['routes'][0]['legs'][0]['end_address'],
            ),
          ),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              pos.latitude < destLatLng.latitude
                  ? pos.latitude
                  : destLatLng.latitude,
              pos.longitude < destLatLng.longitude
                  ? pos.longitude
                  : destLatLng.longitude,
            ),
            northeast: LatLng(
              pos.latitude > destLatLng.latitude
                  ? pos.latitude
                  : destLatLng.latitude,
              pos.longitude > destLatLng.longitude
                  ? pos.longitude
                  : destLatLng.longitude,
            ),
          ),
          80,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
            onMapCreated: (controller) async {
              _mapController = controller;

              final pos = await Geolocator.getCurrentPosition();
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(pos.latitude, pos.longitude),
                  15,
                ),
              );

              if (widget.destinationPlaceId != null) {
                _drawRoute();
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            polylines: _polylines,
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
  });

  final VoidCallback onLocate;
  final VoidCallback onShareLocation;
  final Future<void> Function(String calledNumber) onSosTriggered;
  final List<String> emergencyNumbers;
  final String? destinationPlaceId;
  final String googleApiKey;

  @override
  State<GpsMapAlert> createState() => _GpsMapAlertState();
}

class _GpsMapAlertState extends State<GpsMapAlert> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  Future<void> _drawRoute() async {
    if (widget.destinationPlaceId == null) return;

    final pos = await Geolocator.getCurrentPosition();
    final origin = '${pos.latitude},${pos.longitude}';
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

    if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
      final points = _decodePolyline(
        data['routes'][0]['overview_polyline']['points'],
      );

      final endLocation = data['routes'][0]['legs'][0]['end_location'];
      final destLatLng = LatLng(endLocation['lat'], endLocation['lng']);

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 4,
          ),
        };
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destLatLng,
            infoWindow: InfoWindow(
              title: data['routes'][0]['legs'][0]['end_address'],
            ),
          ),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              pos.latitude < destLatLng.latitude
                  ? pos.latitude
                  : destLatLng.latitude,
              pos.longitude < destLatLng.longitude
                  ? pos.longitude
                  : destLatLng.longitude,
            ),
            northeast: LatLng(
              pos.latitude > destLatLng.latitude
                  ? pos.latitude
                  : destLatLng.latitude,
              pos.longitude > destLatLng.longitude
                  ? pos.longitude
                  : destLatLng.longitude,
            ),
          ),
          80,
        ),
      );
    }
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

    if (!_isExpanded) {
      final delayMs = isKeyboardCurrentlyUp ? 300 : 0;

      Future.delayed(Duration(milliseconds: delayMs), () {
        if (!mounted) return;
        setState(() {
          _isExpanded = true;
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _showMapContent = true);
        });
      });
    } else {
      setState(() {
        _showMapContent = false; // ซ่อน map ก่อนทันที
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) setState(() => _isExpanded = false);
      });
    }
  }

  void _handleMapPressed() {
    widget.onLocate();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenMapPage(
          destinationPlaceId: widget.destinationPlaceId,
          googleApiKey: widget.googleApiKey,
        ),
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
          icon: const Icon(Icons.map_rounded, size: 28),
          iconColor: AppColors.brandSecondary,
          onTap: _handleMapPressed,
        ),
      ],
    );
  }

  Widget _buildMapFocusPulse() {
    return IgnorePointer(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary.withValues(alpha: 0.14),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary.withValues(alpha: 0.20),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ],
        ),
      ),
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
        ? AppColors.textBlack.withValues(alpha: 0.1)
        : AppColors.inputBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedSize(
          duration: _isKeyboardVisible
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
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
              if (_isExpanded && _showMapContent)
                SizedBox(
                  height: 223,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(0, 0),
                          zoom: 2,
                        ),
                        onMapCreated: (controller) async {
                          _mapController = controller;
                          final pos = await Geolocator.getCurrentPosition();
                          controller.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(pos.latitude, pos.longitude),
                              15,
                            ),
                          );
                          if (widget.destinationPlaceId != null) {
                            _drawRoute();
                          }
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        markers: _markers,
                        polylines: _polylines,
                      ),
                      _buildMapFocusPulse(),
                    ],
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
      ),
    );
  }
}
