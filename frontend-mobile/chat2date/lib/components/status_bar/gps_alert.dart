import 'dart:convert';

import 'package:chat2date/components/toasts/toast.dart';
import 'package:chat2date/theme/app_colors.dart';
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
                        color: Colors.black.withOpacity(0.15),
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
  final Color backgroundColor;
  final VoidCallback onTap;

  const _AlertActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(child: icon),
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
            showCountdown: false,
          );
        }
      });
    }
  }

  bool _isExpanded = true;
  bool _showMapContent = true;
  bool _hasSosTriggered = false;
  bool _isKeyboardVisible = false;

  int _selectedButtonIndex = 0;
  int _emergencyStep = 0;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentPosition;

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
        _currentPosition = LatLng(pos.latitude, pos.longitude);
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

  final List<String> _emergencyTexts = const [
    'กดอีก 2 ครั้งเพื่อส่งสัญญาณฉุกเฉิน และโทรหาเบอร์ลำดับที่ 1 และแจ้งแอดมิน',
    'กดอีก 1 ครั้งเพื่อส่งสัญญาณฉุกเฉิน และโทรหาเบอร์ลำดับที่ 1 และแจ้งแอดมิน',
    'กดอีก 1 ครั้งเพื่อส่งสัญญาณฉุกเฉิน และโทรหาเบอร์ลำดับที่ 2 และแจ้งแอดมิน',
  ];
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

  void _onButtonTapped(int index) {
    // ปุ่มแรก → เปิด full screen map
    if (index == 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FullScreenMapPage(
            destinationPlaceId: widget.destinationPlaceId,
            googleApiKey: widget.googleApiKey,
          ),
        ),
      );
      return;
    }
    if (index == 1) {
      widget.onShareLocation();
      setState(() => _selectedButtonIndex = 1);
      return;
    }
    setState(() {
      _selectedButtonIndex = 2;
      _emergencyStep = (_emergencyStep < 3) ? _emergencyStep + 1 : 3;
    });

    if (_emergencyStep == 3) {
      _triggerEmergency();
    }
  }

  void _triggerEmergency() {
    final number = widget.emergencyNumbers.isNotEmpty
        ? widget.emergencyNumbers[0].replaceAll('-', '')
        : '191';
    launchUrl(Uri(scheme: 'tel', path: number));
    _hasSosTriggered = true;
    widget.onSosTriggered(number);
  }

  String _getCurrentInstructionText() {
    if (_selectedButtonIndex == 2 &&
        _emergencyStep > 0 &&
        _emergencyStep <= 3) {
      return _emergencyTexts[_emergencyStep - 1];
    }
    return '';
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _AlertActionButton(
          icon: SvgPicture.asset(
            'assets/icons/ui/icon_share.svg',
            width: 25,
            height: 25,
          ),
          backgroundColor: AppColors.surfaceMuted,
          onTap: () => _onButtonTapped(1),
        ),
        _AlertActionButton(
          icon: SvgPicture.asset(
            'assets/icons/ui/icon_emergency.svg',
            width: 25,
            height: 25,
          ),
          backgroundColor: AppColors.surfaceMuted,
          onTap: () => _onButtonTapped(2),
        ),
        _AlertActionButton(
          icon: Icon(Icons.fullscreen, color: AppColors.neutral700, size: 35),
          backgroundColor: AppColors.surfaceMuted,
          onTap: () => _onButtonTapped(0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: AnimatedSize(
        duration: _isKeyboardVisible
            ? const Duration(milliseconds: 0)
            : (_isExpanded
                  ? const Duration(milliseconds: 300) // ขยาย: ช้าปกติ
                  : const Duration(milliseconds: 50)),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          padding: _isExpanded
              ? const EdgeInsets.all(0)
              : const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _toggleExpansion,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  margin: _isExpanded
                      ? const EdgeInsets.symmetric(horizontal: 16.0)
                      : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(
                        child: Text(
                          'LOCATION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          _isExpanded
                              ? Icons.keyboard_double_arrow_up
                              : Icons.keyboard_double_arrow_down,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!_isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _buildActionButtons(),
                ),
                if (_emergencyStep > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      _getCurrentInstructionText(),
                      style: TextStyle(
                        color: (_selectedButtonIndex == 2 && _emergencyStep > 0)
                            ? AppColors.error
                            : Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],

              if (_isExpanded && _showMapContent)
                SizedBox(
                  height: 340.0,
                  child: Column(
                    children: [
                      Expanded(
                        child: GoogleMap(
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
                            if (widget.destinationPlaceId != null) _drawRoute();
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          markers: _markers,
                          polylines: _polylines,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: _buildActionButtons(),
                      ),
                      if (_emergencyStep > 0)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12.0,
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: Text(
                            _getCurrentInstructionText(),
                            style: TextStyle(
                              color:
                                  (_selectedButtonIndex == 2 &&
                                      _emergencyStep > 0)
                                  ? AppColors.error
                                  : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
