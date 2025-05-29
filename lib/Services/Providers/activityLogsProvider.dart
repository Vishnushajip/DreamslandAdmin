import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityLog {
  final String id;
  final String action;
  final String agentId;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.action,
    required this.agentId,
    required this.timestamp,
  });

  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLog(
      id: doc.id,
      action: data['action'] ?? '',
      agentId: data['agentId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

final activityLogsProvider = StreamProvider.autoDispose<List<ActivityLog>>((
  ref,
) {
  return FirebaseFirestore.instance
      .collection('activity_logs')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => ActivityLog.fromFirestore(doc)).toList(),
      );
});
final activityPreviewProvider = StreamProvider.autoDispose<List<ActivityLog>>((
  ref,
) {
  return FirebaseFirestore.instance
      .collection('activity_logs')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .where((doc) => !doc.data().containsKey('viewed'))
                .map((doc) => ActivityLog.fromFirestore(doc))
                .toList(),
      );
});
