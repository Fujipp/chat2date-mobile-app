import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Checks location permission; if denied, routes to `/home`.
Future<void> ensureLocationOrGoHome(BuildContext context) async {
  var status = await Permission.location.status;

  if (status.isGranted) {
    return; // OK, continue
  }

  status = await Permission.location.request();

  if (status.isGranted) {
    return; // Granted after request
  }

  // Denied or permanentlyDenied → go home
  Navigator.pushReplacementNamed(context, '/home');
}

/// Wrap a screen that needs location: it will request on first build and
/// navigate to `/home` if user denies.
class LocationGate extends StatefulWidget {
  final Widget child;
  const LocationGate({super.key, required this.child});

  @override
  State<LocationGate> createState() => _LocationGateState();
}

class _LocationGateState extends State<LocationGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensureLocationOrGoHome(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
