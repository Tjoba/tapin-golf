class GolfCourse {
  final int id;
  final String type;
  final String name;
  final double lat;
  final double lon;
  final Map<String, dynamic> tags;

  GolfCourse({
    required this.id,
    required this.type,
    required this.name,
    required this.lat,
    required this.lon,
    required this.tags,
  });

  factory GolfCourse.fromJson(Map<String, dynamic> json) {
    return GolfCourse(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      tags: json['tags'] as Map<String, dynamic>,
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
    };
  }

  // Convenience getters for common tag fields
  String? get city => tags['addr:city'] as String?;
  String? get postcode => tags['addr:postcode'] as String?;
  String? get email => tags['email'] as String?;
  String? get phone => tags['phone'] as String?;
  String? get website => tags['website'] as String?;
  String? get url => tags['url'] as String?;

  // Get the primary website/url
  String? get primaryWebsite => website ?? url;

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