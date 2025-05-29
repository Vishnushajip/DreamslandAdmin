import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final selectedDeletedByProvider = StateProvider<String>((ref) => 'All');

final deletedPropertiesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final selectedDeletedBy = ref.watch(selectedDeletedByProvider);

  try {
    final startOfDay = Timestamp.fromDate(DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0));
    final endOfDay = Timestamp.fromDate(DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59));

    print("🕑 Querying from ${startOfDay.toDate()} to ${endOfDay.toDate()}");

    Query query = FirebaseFirestore.instance
        .collection('deleted_properties')
        .where('deletedAt', isGreaterThanOrEqualTo: startOfDay)
        .where('deletedAt', isLessThanOrEqualTo: endOfDay)
        .orderBy('deletedAt', descending: true);

    if (selectedDeletedBy != 'All') {
      query = query.where('deletedBy', isEqualTo: selectedDeletedBy);
    }

    final querySnapshot = await query.get();

    print(
        "✅ Fetched ${querySnapshot.docs.length} documents for ${selectedDate.toLocal()}");

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['deletedAt'] is Timestamp) {
        data['deletedAt'] = (data['deletedAt'] as Timestamp).toDate();
      }
      return data;
    }).toList();
  } catch (error, stackTrace) {
    print("🔥 Error fetching deleted properties: $error");
    print("📄 Stack Trace: $stackTrace");
    rethrow;
  }
});
final deletedByListProvider = FutureProvider<List<String>>((ref) async {
  try {
    final thirtyDaysAgo =
        Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30)));

    final querySnapshot = await FirebaseFirestore.instance
        .collection('deleted_properties')
        .where('deletedAt', isGreaterThanOrEqualTo: thirtyDaysAgo)
        .get();

    final deletedByList = querySnapshot.docs
        .map((doc) => doc['deletedBy']?.toString() ?? 'Unknown')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    deletedByList.sort((a, b) => a.compareTo(b));
    deletedByList.insert(0, 'All');

    print("✅ DeletedBy List: ${deletedByList.join(', ')}");

    return deletedByList;
  } catch (error, stackTrace) {
    print("🔥 Error fetching deletedBy list: $error");
    print("📄 Stack Trace: $stackTrace");
    rethrow;
  }
});
