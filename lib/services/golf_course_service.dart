import 'dart:convert';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:flutter/services.dart';
import '../models/golf_course.dart';

class GolfCourseService {
  static GolfCourseService? _instance;
  List<GolfCourse>? _courses;
  
  // Singleton pattern
  static GolfCourseService get instance {
    _instance ??= GolfCourseService._();
    return _instance!;
  }
  
  GolfCourseService._();

  /// Load golf courses from JSON file
  Future<List<GolfCourse>> loadCourses() async {
    if (_courses != null) {
      return _courses!; // Return cached data
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/golf_courses.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      _courses = jsonData.map((courseData) => GolfCourse.fromJson(courseData)).toList();
      return _courses!;
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  /// Get all courses
  Future<List<GolfCourse>> getAllCourses() async {
    return await loadCourses();
  }

  /// Search courses by name (case insensitive)
  Future<List<GolfCourse>> searchByName(String query) async {
    final courses = await loadCourses();
    if (query.isEmpty) return courses;
    
    final lowercaseQuery = query.toLowerCase();
    return courses.where((course) => 
      course.name.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Search courses by city
  Future<List<GolfCourse>> searchByCity(String city) async {
    final courses = await loadCourses();
    if (city.isEmpty) return courses;
    
    final lowercaseCity = city.toLowerCase();
    return courses.where((course) => 
      course.city?.toLowerCase().contains(lowercaseCity) ?? false
    ).toList();
  }

  /// Get courses within a certain distance from a point (basic implementation)
  Future<List<GolfCourse>> getCoursesNearby(double lat, double lon, double radiusKm) async {
    final courses = await loadCourses();
    
    final nearby = courses.where((course) {
      final distance = _calculateDistance(lat, lon, course.lat, course.lon);
      return distance <= radiusKm;
    }).toList();
    
    return nearby;
  }

  /// Get a specific course by ID
  Future<GolfCourse?> getCourseById(int id) async {
    final courses = await loadCourses();
    try {
      return courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get courses with contact information
  Future<List<GolfCourse>> getCoursesWithContact() async {
    final courses = await loadCourses();
    return courses.where((course) => course.hasContactInfo).toList();
  }

  /// Get courses grouped by city
  Future<Map<String, List<GolfCourse>>> getCoursesByCity() async {
    final courses = await loadCourses();
    final Map<String, List<GolfCourse>> grouped = {};
    
    for (final course in courses) {
      final city = course.city ?? 'Unknown';
      grouped.putIfAbsent(city, () => []).add(course);
    }
    
    return grouped;
  }

  /// Clear cached data (useful for refreshing)
  void clearCache() {
    _courses = null;
  }

  /// Basic distance calculation using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        (sin(dLon / 2) * sin(dLon / 2));
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}