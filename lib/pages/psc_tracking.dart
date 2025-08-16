import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_flutter/directions.dart';
import 'package:tracking_flutter/schema.dart';

class PscTracking extends StatefulWidget {
  const PscTracking({super.key});

  @override
  State<PscTracking> createState() => _PscTrackingState();
}

class _PscTrackingState extends State<PscTracking> {
  final LatLng _origin = const LatLng(10.3137192, 123.8835331);
  final LatLng _destination = const LatLng(10.309621808601626, 123.89409734968704);

  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(10.3137192, 123.8835331),
    zoom: 14,
  );

  late GoogleMapController _googleMapController;

  Directions? _info; // ✅ make nullable

  Future<void> _getDirections() async {
    final directions = await DirectionsService.getDirections(
      origin: _origin,
      destination: _destination,
    );

    setState(() {
      _info = directions; // ✅ update state
    });
  }

  @override
  void initState() {
    super.initState();
    _getDirections();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PSC Tracking"),
        actions: [
          TextButton(
            onPressed: () => _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _origin, zoom: 15, tilt: 50),
              ),
            ),
            child: const Text("Current"),
          ),
          TextButton(
            onPressed: () => _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _destination, zoom: 15, tilt: 50),
              ),
            ),
            child: const Text("Destination"),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              Marker(
                markerId: const MarkerId("_origin"),
                icon: BitmapDescriptor.defaultMarker,
                position: _origin,
              ),
              Marker(
                markerId: const MarkerId("destination"),
                icon: BitmapDescriptor.defaultMarker,
                position: _destination,
              ),
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId("overview_polyline"),
                  color: Colors.blue,
                  width: 5,
                  points: _info!.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
          ),

          if (_info != null)
            Positioned(
              top: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

