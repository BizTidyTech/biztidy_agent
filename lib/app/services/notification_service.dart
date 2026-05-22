import 'package:biztidy_agent_app/main.dart' show logger;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static const String _oneSignalAppId = 'da910aed-26e9-43c1-8ff5-2d2b66f49558';

  /// Call once in main() before runApp
  static Future<void> initialize() async {
    OneSignal.initialize(_oneSignalAppId);

    // Ask for notification permission
    await OneSignal.Notifications.requestPermission(true);

    // Listen for when a player ID becomes available and save it
    OneSignal.User.pushSubscription.addObserver((state) {
      final id = state.current.id;
      if (id != null && id.isNotEmpty) {
        _saveTokenToFirestore(id);
      }
    });
  }

  /// Call this right after a successful sign-in so the token is always fresh
  static Future<void> saveTokenOnLogin() async {
    try {
      final id = OneSignal.User.pushSubscription.id;
      if (id != null && id.isNotEmpty) {
        await _saveTokenToFirestore(id);
      }
    } catch (e) {
      logger.e('saveTokenOnLogin error: $e');
    }
  }

  /// Removes the token from Firestore on sign-out so the agent
  /// stops receiving notifications when logged out
  static Future<void> clearTokenOnLogout() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('Agents')
          .doc(user.uid)
          .update({'oneSignalPlayerId': FieldValue.delete()});
    } catch (e) {
      logger.e('clearTokenOnLogout error: $e');
    }
  }

  static Future<void> _saveTokenToFirestore(String playerId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('Agents')
          .doc(user.uid)
          .update({'oneSignalPlayerId': playerId});
      logger.i('OneSignal player ID saved: $playerId');
    } catch (e) {
      logger.e('_saveTokenToFirestore error: $e');
    }
  }
}