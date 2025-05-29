import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'dart:io';

class ImageUploadModel {
  List<File?> images;
  List<String> filenames;
  List<String> downloadUrls;

  ImageUploadModel({
    required this.images,
    required this.filenames,
    required this.downloadUrls,
  });
}

class ImageUploadNotifier extends StateNotifier<ImageUploadModel> {
  ImageUploadNotifier()
    : super(
        ImageUploadModel(
          images: List.filled(10, null),
          filenames: List.filled(10, 'No file chosen'),
          downloadUrls: [],
        ),
      );

  void setImage(int index, File? file, String name) {
    final updatedImages = [...state.images];
    final updatedNames = [...state.filenames];
    updatedImages[index] = file;
    updatedNames[index] = name;

    state = ImageUploadModel(
      images: updatedImages,
      filenames: updatedNames,
      downloadUrls: state.downloadUrls,
    );
  }

  Future<void> uploadImages() async {
    final storage = FirebaseStorage.instance;
    final urls = <String>[];

    for (final image in state.images) {
      if (image != null) {
        final data = await image.readAsBytes();
        final uuid = const Uuid().v4();
        final ref = storage.ref().child('properties/$uuid');

        final uploadTask = await ref.putData(
          data,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final url = await uploadTask.ref.getDownloadURL();
        urls.add(url);
      }
    }

    state = ImageUploadModel(
      images: state.images,
      filenames: state.filenames,
      downloadUrls: urls,
    );
  }
}

final imageUploadProvider =
    StateNotifierProvider<ImageUploadNotifier, ImageUploadModel>(
      (ref) => ImageUploadNotifier(),
    );

final locationNameProvider = StateProvider<String>((ref) => '');
final isUploadingProvider = StateProvider<bool>((ref) => false);

class LocationService {
  static Future<void> saveLocation(String name, String imageUrl) async {
    await FirebaseFirestore.instance.collection('property_location').add({
      'location': name,
      'imageurl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
