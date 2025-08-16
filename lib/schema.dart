import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> json) {
    Map<String, dynamic> data = Map<String, dynamic>.from(json['routes'][0]);

    // Bounds
    Map<String, dynamic> northEast = data["bounds"]["northeast"];
    Map<String, dynamic> southWest = data["bounds"]["northeast"];
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(southWest['lat'], southWest['lng']),
      northeast: LatLng(northEast['lat'], northEast['lng']),
    );

    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    return Directions(
      bounds: bounds,
      polylinePoints: PolylinePoints.decodePolyline(
        data['overview_polyline']['points'],
      ),
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
