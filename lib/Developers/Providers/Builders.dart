import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dladmin/Services/Scaffold_Messanger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class BuilderProfile {
  final String name;
  final String id;
  final String description;
  final String imageUrl;
  final String coverImageUrl;

  BuilderProfile({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.coverImageUrl,
    required this.id,
  });

  factory BuilderProfile.fromFirestore(Map<String, dynamic> data) {
    return BuilderProfile(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
    );
  }
}

final builderProfilesProvider = FutureProvider<List<BuilderProfile>>((
  ref,
) async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection('Developers')
          .limit(10)
          .orderBy('createdAt', descending: true)
          .get();

  return snapshot.docs
      .map((doc) => BuilderProfile.fromFirestore(doc.data()))
      .toList();
});

class DeletionNotifier extends StateNotifier<Set<String>> {
  final Ref ref;
  DeletionNotifier(this.ref) : super({});

  bool isDeleting(String id) => state.contains(id);

  Future<void> deleteDeveloper(
    String id,
    BuildContext context,
    String name,
  ) async {
    state = {...state, id};
    try {
      await FirebaseFirestore.instance
          .collection('Developers')
          .where("name", isEqualTo: name)
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });

      CustomMessenger(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        context: context,
        message: 'Deleted $name',
      );

      ref.invalidate(developersProvider);
    } catch (e) {
      CustomMessenger(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        context: context,
        message: 'Error deleting $name: ${e.toString()}',
      );
    } finally {
      state = {...state}..remove(id);
    }
  }
}

final deletionNotifierProvider =
    StateNotifierProvider<DeletionNotifier, Set<String>>(
      (ref) => DeletionNotifier(ref),
    );
final developersProvider = FutureProvider<List<BuilderProfile>>((ref) async {
  final snapshot =
      await FirebaseFirestore.instance.collection('Developers').get();
  return snapshot.docs
      .map((doc) => BuilderProfile.fromFirestore(doc.data()))
      .toList();
});
