class UserProfile {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final int handicap;
  final String homeClub;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.handicap = 0,
    this.homeClub = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // Get full display name
  String get displayName => '$firstName $lastName'.trim();

  // Convert UserProfile to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'handicap': handicap,
      'homeClub': homeClub,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create UserProfile from Firestore Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      photoUrl: map['photoUrl'],
      handicap: map['handicap'] ?? 0,
      homeClub: map['homeClub'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? photoUrl,
    int? handicap,
    String? homeClub,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      handicap: handicap ?? this.handicap,
      homeClub: homeClub ?? this.homeClub,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}