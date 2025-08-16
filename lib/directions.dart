import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:tracking_flutter/schema.dart';

class DirectionsService {
  static const String _baseUrl =
      "https://routes.googleapis.com/directions/v2:computeRoutes";
  static Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    await dotenv.load();
    Response response = await post(
      Uri.parse(_baseUrl),
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": "AIzaSyD7scJAgAMDoj7dnRrICEqVc6x5YWcSKFc",
        "X-Goog-FieldMask":
            "routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline",
      },
      body: jsonEncode({
        "origin": {
          "location": {
            "latLng": {
              "latitude": origin.latitude,
              "longitude": origin.longitude,
            },
          },
        },
        "destination": {
          "location": {
            "latLng": {
              "latitude": destination.latitude,
              "longitude": destination.longitude,
            },
          },
        },
        "travelMode": "DRIVE",
      }),
    );
    print("FETCHING DIRECTINOS;");
    print(response.body);
    if (response.statusCode == 200) {
      return Directions.fromMap(json.decode(response.body));
    }
    return null;
  }
}
