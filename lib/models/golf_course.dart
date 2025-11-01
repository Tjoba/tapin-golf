class GolfCourse {
  final int id;
  final String type;
  final String name;
  final double lat;
  final double lon;
  final Map<String, dynamic> tags;
  final List<String>? holes;
  final String? logo;

  GolfCourse({
    required this.id,
    required this.type,
    required this.name,
    required this.lat,
    required this.lon,
    required this.tags,
    this.holes,
    this.logo,
  });

  factory GolfCourse.fromJson(Map<String, dynamic> json) {
    return GolfCourse(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      tags: json['tags'] as Map<String, dynamic>,
      holes: json['holes'] != null 
          ? List<String>.from(json['holes'] as List)
          : null,
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'lat': lat,
      'lon': lon,
      'tags': tags,
      'holes': holes,
      'logo': logo,
    };
  }

  // Convenience getters for common tag fields
  String? get city => tags['addr:city'] as String?;
  String? get postcode => tags['addr:postcode'] as String?;
  String? get email => tags['email'] as String?;
  String? get phone => tags['phone'] as String?;
  String? get website => tags['website'] as String?;
  String? get url => tags['url'] as String?;
  String? get description => tags['description'] as String?;
  String? get golfCourse => tags['golf:course'] as String?;

  // Get the primary website/url
  String? get primaryWebsite => website ?? url;

  // Get course hole information
  String? get holeInfo {
    // Use the first item from holes array if available
    if (holes != null && holes!.isNotEmpty) {
      return holes!.first;
    }
    return null;
  }

  // Check if course has contact information
  bool get hasContactInfo => email != null || phone != null;

  // Get formatted address
  String get address {
    List<String> addressParts = [];
    if (city != null) addressParts.add(city!);
    if (postcode != null) addressParts.add(postcode!);
    return addressParts.join(', ');
  }

  @override
  String toString() {
    return 'GolfCourse(id: $id, name: $name, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GolfCourse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}