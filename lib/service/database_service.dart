import 'package:firebase_database/firebase_database.dart';

final db = FirebaseDatabase.instance.ref();

// Save user profile info
Future<void> saveUserInfo(String uid, String email,String name,) async {
  try {
    print("🟢 Saving user info for $uid");
    await db.child('users/$uid/profile').set({
      'name' : name,
      'email': email,
      'joinedAt': DateTime.now().toIso8601String(),
    });
    print("✅ User info saved");
  } catch (e) {
    print("❌ Failed to save user info: $e");
    rethrow;
  }
}

// Save a scanned item
Future<void> saveScannedItem(String uid, Map<String, dynamic> item) async {
  final newItem = db.child('users/$uid/scans').push();
  await newItem.set({
    ...item,
    'scannedAt': DateTime.now().toIso8601String(),
  });
}

// Save favorite/saved item
Future<void> saveToFavorites(String uid, Map<String, dynamic> item) async {
  final savedItem = db.child('users/$uid/saved').push();
  await savedItem.set(item);
}

// Save profile image
Future<void> updateProfileImage(String uid, String imageBase64) async {
  try {
    await db.child('users/$uid/profile/imageBase64').set(imageBase64);
    print("✅ Profile image updated");
  } catch (e) {
    print("❌ Failed to update profile image: $e");
    rethrow;
  }
}




