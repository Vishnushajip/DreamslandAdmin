import 'dart:io';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

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
      : super(ImageUploadModel(
          images: List.filled(10, null),
          filenames: List.filled(10, 'Choose Image'),
          downloadUrls: [],
        ));

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
    final List<Future<String>> uploadTasks = [];

    for (var image in state.images) {
      if (image != null) {
        uploadTasks.add(_uploadImage(image, storage));
      }
    }

    final results = await Future.wait(uploadTasks);

    state = ImageUploadModel(
      images: state.images,
      filenames: state.filenames,
      downloadUrls: results,
    );
  }

  Future<String> _uploadImage(File image, FirebaseStorage storage) async {
    final imageBytes = await image.readAsBytes();

    final uuid = const Uuid().v4();
    final ref = storage.ref().child('prop/$uuid');

    final uploadTask = await ref.putData(
      imageBytes,
      SettableMetadata(
          contentType: 'image/jpeg'),
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }
}

final imageUploadProvider =
    StateNotifierProvider<ImageUploadNotifier, ImageUploadModel>(
  (ref) => ImageUploadNotifier(),
);
