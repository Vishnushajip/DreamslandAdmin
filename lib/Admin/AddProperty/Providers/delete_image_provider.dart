import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';

final deleteImageProvider = StateNotifierProvider<DeleteImageNotifier, bool>(
  (ref) => DeleteImageNotifier(),
);

class DeleteImageNotifier extends StateNotifier<bool> {
  DeleteImageNotifier() : super(false);

  Future<void> deleteImages(List<String> imageUrls) async {
    state = true;

    try {
      for (String imageUrl in imageUrls) {
        await deleteImageFromStorage(imageUrl);
      }

      Fluttertoast.showToast(
        msg: "Images deleted successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Error deleting images}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      state = false;
    }
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      print("Deleted: $imageUrl");
    } catch (e) {
      print("Failed to delete image: $e");
    }
  }
}
