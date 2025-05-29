import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActionLogger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static Future<void> log({
    required String action,
    Map<String, dynamic>? details,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agentId = prefs.getString('username');

      if (agentId == null || agentId.isEmpty) {
        print('Agent ID not found in SharedPreferences.');
        return;
      }

      await _firestore.collection('activity_logs').add({
        'agentId': agentId,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
        'details': details ?? {},
      });
    } catch (e) {
      print('Failed to log action: $e');
    }
  }
}
