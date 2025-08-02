import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Enable offline persistence
  static Future<void> enableOfflinePersistence() async {
    // Enable offline persistence for Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Check if user is logged in
  static bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with email and password
  static Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  static Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Create or update user profile
  static Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  // Save scan history
  static Future<void> saveScanHistory(String userId, Map<String, dynamic> scanData) async {
    try {
      await _firestore.collection('users').doc(userId)
          .collection('scans').add({
        ...scanData,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update user metrics
      await _updateUserMetrics(userId, scanData);
    } catch (e) {
      print('Error saving scan history: $e');
      rethrow;
    }
  }

  // Get scan history
  static Future<List<Map<String, dynamic>>> getScanHistory(String userId) async {
    try {
      final querySnapshot = await _firestore.collection('users').doc(userId)
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting scan history: $e');
      rethrow;
    }
  }

  // Update user metrics
  static Future<void> _updateUserMetrics(String userId, Map<String, dynamic> scanData) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          transaction.set(userRef, {
            'totalScans': 1,
            'co2Saved': _calculateCO2Savings(scanData),
            'rewardPoints': _calculateRewardPoints(scanData),
          });
        } else {
          final currentData = userDoc.data()!;
          transaction.update(userRef, {
            'totalScans': (currentData['totalScans'] ?? 0) + 1,
            'co2Saved': (currentData['co2Saved'] ?? 0) + _calculateCO2Savings(scanData),
            'rewardPoints': (currentData['rewardPoints'] ?? 0) + _calculateRewardPoints(scanData),
          });
        }
      });
    } catch (e) {
      print('Error updating user metrics: $e');
      rethrow;
    }
  }

  // Calculate CO2 savings based on waste type and weight
  static double _calculateCO2Savings(Map<String, dynamic> scanData) {
    // CO2 savings in kg per kg of recycled material
    const Map<String, double> co2SavingsPerKg = {
      'plastic': 2.5,
      'paper': 1.5,
      'metal': 4.0,
      'glass': 0.3,
      'cardboard': 1.2,
    };

    final wasteType = scanData['wasteType'].toString().toLowerCase();
    final weight = scanData['weight'] ?? 0.1; // Default to 0.1 kg if not specified

    return (co2SavingsPerKg[wasteType] ?? 0.0) * weight;
  }

  // Calculate reward points based on waste type and recyclability
  static int _calculateRewardPoints(Map<String, dynamic> scanData) {
    // Base points for different waste types
    const Map<String, int> basePoints = {
      'plastic': 10,
      'paper': 5,
      'metal': 15,
      'glass': 8,
      'cardboard': 5,
    };

    final wasteType = scanData['wasteType'].toString().toLowerCase();
    final isRecyclable = scanData['recyclability'].toString().toLowerCase() == 'recyclable';

    // Get base points for the waste type
    int points = basePoints[wasteType] ?? 0;

    // Bonus points for recyclable items
    if (isRecyclable) {
      points *= 2;
    }

    return points;
  }

  // Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }
}