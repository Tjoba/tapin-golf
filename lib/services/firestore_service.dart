import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // Create user profile
  Future<void> createUserProfile(UserProfile userProfile) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userProfile.uid)
          .set(userProfile.toMap());
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      UserProfile updatedProfile = userProfile.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_usersCollection)
          .doc(userProfile.uid)
          .update(updatedProfile.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .delete();
    } catch (e) {
      print('Error deleting user profile: $e');
      rethrow;
    }
  }

  // Stream user profile changes
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Update specific fields
  Future<void> updateUserField(String uid, String field, dynamic value) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        field: value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating user field: $e');
      rethrow;
    }
  }

  // Update handicap
  Future<void> updateHandicap(String uid, int handicap) async {
    try {
      await updateUserField(uid, 'handicap', handicap);
    } catch (e) {
      print('Error updating handicap: $e');
      rethrow;
    }
  }

  // Update home club
  Future<void> updateHomeClub(String uid, String homeClub) async {
    try {
      await updateUserField(uid, 'homeClub', homeClub);
    } catch (e) {
      print('Error updating home club: $e');
      rethrow;
    }
  }
}