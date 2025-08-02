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
    try {
      print('Initializing Firebase...');
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
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
    final user = _auth.currentUser;
    print('Checking if user is logged in: ${user?.uid}');
    return user != null;
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with email and password
  static Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign in successful: ${result.user?.uid}');
      return result;
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  static Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      print('Attempting to sign up with email: $email');
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign up successful: ${result.user?.uid}');
      return result;
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  // Create user profile with initial values
  static Future<void> createUserProfile(String userId, String email) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'name': null,
        'photoUrl': null,
        'totalScans': 0,
        'co2Saved': 0.0,
        'rewardPoints': 0,
        'hazardousWasteHandled': 0,
        'lastScanDate': null,
        'language': 'en', // Default language
        'dailyStreak': 0,
        'consecutiveCorrectScans': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
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
      print('Getting user profile for: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      print('Document exists: ${doc.exists}');
      final data = doc.data();
      print('User profile data: $data');
      return data;
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
      print('Getting scan history for: $userId');
      final querySnapshot = await _firestore.collection('users').doc(userId)
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} scan records');
      final history = querySnapshot.docs.map((doc) => doc.data()).toList();
      print('Scan history: $history');
      return history;
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
            'co2Saved': _calculateCO2Saved(scanData),
            'rewardPoints': _calculateRewardPoints(scanData),
            'hazardousWasteHandled': _isHazardousWaste(scanData) ? 1 : 0,
            'lastScanDate': FieldValue.serverTimestamp(),
            'dailyStreak': 1,
            'consecutiveCorrectScans': 1,
          });
        } else {
          final currentData = userDoc.data()!;
          final co2Saved = _calculateCO2Saved(scanData);
          final rewardPoints = _calculateRewardPoints(scanData);
          final isHazardous = _isHazardousWaste(scanData);
          
          // Calculate daily streak
          final lastScanDate = currentData['lastScanDate'] as Timestamp?;
          final today = DateTime.now();
          final yesterday = today.subtract(const Duration(days: 1));
          int dailyStreak = currentData['dailyStreak'] ?? 0;
          
          if (lastScanDate != null) {
            final lastScan = lastScanDate.toDate();
            if (lastScan.year == yesterday.year && 
                lastScan.month == yesterday.month && 
                lastScan.day == yesterday.day) {
              dailyStreak++;
            } else if (lastScan.year != today.year || 
                      lastScan.month != today.month || 
                      lastScan.day != today.day) {
              dailyStreak = 1;
            }
          } else {
            dailyStreak = 1;
          }
          
          // Calculate consecutive correct scans
          int consecutiveCorrectScans = currentData['consecutiveCorrectScans'] ?? 0;
          consecutiveCorrectScans++;
          
          transaction.update(userRef, {
            'totalScans': (currentData['totalScans'] ?? 0) + 1,
            'co2Saved': (currentData['co2Saved'] ?? 0.0) + co2Saved,
            'rewardPoints': (currentData['rewardPoints'] ?? 0) + rewardPoints,
            'hazardousWasteHandled': (currentData['hazardousWasteHandled'] ?? 0) + (isHazardous ? 1 : 0),
            'lastScanDate': FieldValue.serverTimestamp(),
            'dailyStreak': dailyStreak,
            'consecutiveCorrectScans': consecutiveCorrectScans,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error updating user metrics: $e');
      rethrow;
    }
  }

  // Check if waste is hazardous
  static bool _isHazardousWaste(Map<String, dynamic> scanData) {
    final wasteType = scanData['wasteType'].toString().toUpperCase();
    return ['BATTERIES', 'E-WASTE', 'LIGHT BULBS'].contains(wasteType);
  }

  // Calculate CO2 savings based on waste type and weight
  static double _calculateCO2Saved(Map<String, dynamic> scanData) {
    final co2SavingsPerKg = {
      'plastic': 2.0,
      'metal': 5.0,
      'paper': 1.5,
      'e-waste': 0.4,
      'glass': 0.3,
      'batteries': 0.0, // Hazardous, no direct CO2 saving per kg, but diverted
      'light bulbs': 0.0, // Hazardous, no direct CO2 saving per kg, but diverted
      'organic': 0.0, // Composting benefits, but not direct CO2 saving from recycling
      'clothes': 0.0, // Reuse benefits, but not direct CO2 saving from recycling
      'cardboard': 1.2,
    };
    final wasteType = scanData['wasteType'].toString().toLowerCase();
    final weight = scanData['weight'] ?? 0.1; // Default to 0.1 kg if not specified

    return (co2SavingsPerKg[wasteType] ?? 0.0) * weight;
  }

  // Calculate reward points based on waste type and recyclability
  static int _calculateRewardPoints(Map<String, dynamic> scanData) {
    // Tier-based points for different waste types
    final basePoints = {
      'organic': 2,
      'paper': 2,
      'plastic': 2,
      'clothes': 3,
      'glass': 3,
      'metal': 4,
      'light bulbs': 6,
      'batteries': 8,
      'e-waste': 8,
      'cardboard': 2,
    };

    final wasteType = scanData['wasteType'].toString().toLowerCase();
    int points = basePoints[wasteType] ?? 0;

    // Bonus points for daily streak (every 5 days)
    final userRef = _firestore.collection('users').doc(_auth.currentUser?.uid);
    userRef.get().then((doc) {
      if (doc.exists) {
        final dailyStreak = doc.data()?['dailyStreak'] ?? 0;
        if (dailyStreak % 5 == 0 && dailyStreak > 0) {
          points += 5; // Daily streak bonus
        }
      }
    });

    // Bonus points for consecutive correct scans (every 5 scans)
    userRef.get().then((doc) {
      if (doc.exists) {
        final consecutiveScans = doc.data()?['consecutiveCorrectScans'] ?? 0;
        if (consecutiveScans % 5 == 0 && consecutiveScans > 0) {
          points += 3; // Consecutive correct scans bonus
        }
      }
    });

    return points;
  }

  // Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }
}