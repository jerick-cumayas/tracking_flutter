import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class PSCTracking extends StatefulWidget {
  const PSCTracking({super.key});

  @override
  State<PSCTracking> createState() => _PSCTrackingState();
}

class _PSCTrackingState extends State<PSCTracking> {
  Position? _position;
  String _log = "";
  // CameraPosition? _cameraPosition;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // _position = await Geolocator.getCurrentPosition();

    /* _cameraPosition = CameraPosition(
      target: LatLng(_position!.latitude, _position!.longitude),
      zoom: 15,
    ); */
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      timeLimit: Duration(minutes: 1)
    );
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position? position) async {
          _position = position!;

          _addToLog(
            "Timestamp: ${DateTime.now()} Latitude: ${position.latitude} Longitude: ${position.longitude}",
          );

          await post(
            Uri.parse(
              "https://psc-warehouse.primary.com.ph/Delivery/SaveLocation",
            ),
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: {
              "deviceId": "123123",
              "latitude": position.latitude.toString(),
              "longitude": position.longitude.toString(),
            },
          ).then((_){
            print("Sent successfuly.");
          });
        });
  }

  Future<void> openMap() async {
    if (_position != null) {
      final googleUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${_position!.latitude},${_position!.longitude}',
      );
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open the map.';
      }
    }
  }

  void _addToLog(String message) {
    setState(() {
      _log += "$message\n";
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PSC Tracking")),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("TRUCK NO: 131SJN1J11K23KJ"),
            Text("Latitude: ${(_position != null) ? _position!.latitude : ""}"),
            Text(
              "Longitude: ${(_position != null) ? _position!.longitude : ""}",
            ),

            /* ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: Text("Get Coordinates"),
            ) */
            ElevatedButton(
              onPressed: () {
                openMap();
              },
              child: const Text('Open in Google Maps'),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(_log, style: TextStyle(fontFamily: 'monospace')),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _log = "";
                });
              },
              child: Text("Clear"),
            ),
            /*             _position != null
                ? SizedBox(
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: _cameraPosition!,
                      markers: {
                        Marker(
                          markerId: const MarkerId("current_location"),
                          position: LatLng(
                            _position!.latitude,
                            _position!.longitude,
                          ),
                        ),
                      },
                      myLocationEnabled: true,
                      zoomControlsEnabled: true,
                      mapType: MapType.normal,
                    ),
                  )
                : const SizedBox.shrink(), */
          ],
        ),
      ),
      // body: Text("Hello")
    );
  }
}
