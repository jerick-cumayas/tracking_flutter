import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});
  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  Timer? timer;
  GoogleMapController? _mapController;
  LatLng _currentLatLng = const LatLng(0, 0);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _startForegroundService();
    _requestPermissions().then((_) {
      _initLocation();
      _startTracking();
    });
  }

  Future<void> _requestPermissions() async {
    await Geolocator.requestPermission();
  }

  Future<void> _initLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    );
    _updateMap(pos.latitude, pos.longitude);
  }

  void _startTracking() {
    timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best, // same behavior as before
          distanceFilter: 0, // meters before update
        ),
      );
      _updateMap(pos.latitude, pos.longitude);
      _sendLocation(pos.latitude, pos.longitude);
    });
  }

  Future<void> _sendLocation(double lat, double lon) async {
    try {
      // await http.post(
      //   Uri.parse("https://yourapi.com/track"),
      //   body: {
      //     "vehicle_id": "123",
      //     "latitude": lat.toString(),
      //     "longitude": lon.toString(),
      //   },
      // );
      await post(
        Uri.parse("https://psc-warehouse.primary.com.ph/Delivery/SaveLocation"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "deviceId": "12312123123",
          "latitude": lat.toString(),
          "longitude": lon.toString(),
        },
      ).then((response) {
        print("Sending location $lat $lon");

        // Response status code
        print("Status code: ${response.statusCode}");

        // Raw response body
        print("Body: ${response.body}");

        // If response is JSON, decode it
        try {
          final data = jsonDecode(response.body);
          print("Decoded JSON: $data");
        } catch (e) {
          print("Response is not valid JSON");
        }
      });
    } catch (e) {
      print("Error sending location: $e");
    }
  }

  void _updateMap(double lat, double lon) {
    setState(() {
      _currentLatLng = LatLng(lat, lon);
      _markers = {
        Marker(
          markerId: const MarkerId("vehicle"),
          position: _currentLatLng,
          infoWindow: const InfoWindow(title: "My Location"),
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLatLng));
  }

  static const platform = MethodChannel('com.example.tracking_flutter/service');

  Future<void> _startForegroundService() async {
    try {
      await platform.invokeMethod('startService');
    } on PlatformException catch (e) {
      print("Error starting service: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracking")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _currentLatLng, zoom: 16),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
