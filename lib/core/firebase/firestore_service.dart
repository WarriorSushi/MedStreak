import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service class for handling Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _streaksCollection => _firestore.collection('streaks');
  CollectionReference get _gameResultsCollection => _firestore.collection('game_results');
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // User operations
  Future<void> createOrUpdateUser({
    required String userId,
    required String displayName,
    String? email,
    String? photoUrl,
  }) async {
    await _usersCollection.doc(userId).set({
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Streak operations
  Future<void> updateStreak({
    required String userId,
    required int currentStreak,
    int? highestStreak,
  }) async {
    final streakDoc = await _streaksCollection.doc(userId).get();
    
    // If no streak document exists or the highest streak is less than current
    if (!streakDoc.exists || (streakDoc.data() as Map<String, dynamic>)['highestStreak'] < currentStreak) {
      await _streaksCollection.doc(userId).set({
        'userId': userId,
        'currentStreak': currentStreak,
        'highestStreak': currentStreak,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      // Just update the current streak
      await _streaksCollection.doc(userId).update({
        'currentStreak': currentStreak,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<Map<String, dynamic>?> getStreak(String userId) async {
    final doc = await _streaksCollection.doc(userId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // Reset streak if more than 24 hours have passed
  Future<void> checkAndResetStreak(String userId) async {
    final streakDoc = await _streaksCollection.doc(userId).get();
    
    if (streakDoc.exists) {
      final data = streakDoc.data() as Map<String, dynamic>;
      final lastUpdated = (data['lastUpdated'] as Timestamp).toDate();
      final now = DateTime.now();
      
      // If more than 24 hours have passed, reset streak
      if (now.difference(lastUpdated).inHours > 24) {
        await _streaksCollection.doc(userId).update({
          'currentStreak': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Game results operations
  Future<void> saveGameResult({
    required String userId,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required String gameMode,
    required Duration duration,
  }) async {
    await _gameResultsCollection.add({
      'userId': userId,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'gameMode': gameMode,
      'duration': duration.inSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    // Update user's streak
    final streakData = await getStreak(userId);
    final currentStreak = streakData != null ? streakData['currentStreak'] as int : 0;
    
    // Increment streak if they got a good score (e.g., > 70%)
    if (correctAnswers / totalQuestions >= 0.7) {
      await updateStreak(
        userId: userId,
        currentStreak: currentStreak + 1,
        highestStreak: streakData != null ? streakData['highestStreak'] as int : 0,
      );
    }
  }

  // Leaderboard operations
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    final querySnapshot = await _streaksCollection
        .orderBy('highestStreak', descending: true)
        .limit(limit)
        .get();
    
    final leaderboard = <Map<String, dynamic>>[];
    
    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'] as String;
      
      // Get user details
      final userDoc = await _usersCollection.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      
      if (userData != null) {
        leaderboard.add({
          'userId': userId,
          'displayName': userData['displayName'] ?? 'Anonymous',
          'photoUrl': userData['photoUrl'],
          'highestStreak': data['highestStreak'] ?? 0,
          'currentStreak': data['currentStreak'] ?? 0,
        });
      }
    }
    
    return leaderboard;
  }
}
