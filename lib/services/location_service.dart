import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static LocationService? _instance;
  
  // Singleton pattern
  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }
  
  LocationService._();

  /// Check if location services are enabled and permissions are granted
  Future<bool> isLocationAvailable() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      final isAvailable = await isLocationAvailable();
      if (!isAvailable) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      // Log location errors for debugging
      debugPrint('LocationService: Error getting location - $e');
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  /// Get a mock location for testing (Stockholm, Sweden)
  Position getMockLocation() {
    return Position(
      latitude: 59.3293,
      longitude: 18.0686,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }
}