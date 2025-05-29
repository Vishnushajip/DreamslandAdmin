import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dladmin/Admin/Add_Agent/widgets/custom_text_field.dart';
import 'package:dladmin/Developers/Providers/Builders.dart';
import 'package:dladmin/Services/Scaffold_Messanger.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

final builderImageDataProvider = StateProvider<Uint8List?>((ref) => null);
final builderFileNameProvider = StateProvider<String>((ref) => '');
final builderNameProvider = StateProvider<String>((ref) => '');
final builderDescriptionProvider = StateProvider<String>((ref) => '');
final isUploadingProvider = StateProvider<bool>((ref) => false);
final builderCoverImageDataProvider = StateProvider<Uint8List?>((ref) => null);
final builderCoverFileNameProvider = StateProvider<String>((ref) => '');

class BuilderProfileImage extends ConsumerWidget {
  BuilderProfileImage({super.key});

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(bool isCover, WidgetRef ref) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final fileName = pickedFile.name;

      if (isCover) {
        ref.read(builderCoverImageDataProvider.notifier).state = bytes;
        ref.read(builderCoverFileNameProvider.notifier).state = fileName;
      } else {
        ref.read(builderImageDataProvider.notifier).state = bytes;
        ref.read(builderFileNameProvider.notifier).state = fileName;
      }
    }
  }

  Future<void> _uploadToFirebase(BuildContext context, WidgetRef ref) async {
    final Uint8List? imageData = ref.read(builderImageDataProvider);
    final String fileName = ref.read(builderFileNameProvider);
    final Uint8List? coverImageData = ref.read(builderCoverImageDataProvider);
    final String coverFileName = ref.read(builderCoverFileNameProvider);
    final String name = ref.read(builderNameProvider);
    final String description = ref.read(builderDescriptionProvider);

    if (imageData == null ||
        coverImageData == null ||
        name.isEmpty ||
        description.isEmpty) {
      CustomMessenger(
        context: context,
        message: "All fields including profile and cover image are required",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ).show();
      return;
    }

    ref.read(isUploadingProvider.notifier).state = true;

    try {
      final uuid = const Uuid();
      final profileImageRef = FirebaseStorage.instance.ref().child(
        'builder_profiles/${uuid.v4()}_$fileName',
      );
      final coverImageRef = FirebaseStorage.instance.ref().child(
        'builder_profiles/${uuid.v4()}_$coverFileName',
      );

      await profileImageRef.putData(imageData);
      await coverImageRef.putData(coverImageData);

      final imageUrl = await profileImageRef.getDownloadURL();
      final coverImageUrl = await coverImageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('Developers').doc(name).set({
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'coverImageUrl': coverImageUrl,
        'createdAt': Timestamp.now(),
      });

      ref.invalidate(builderImageDataProvider);
      ref.invalidate(builderFileNameProvider);
      ref.invalidate(builderCoverImageDataProvider);
      ref.invalidate(builderCoverFileNameProvider);
      ref.invalidate(builderNameProvider);
      ref.invalidate(builderDescriptionProvider);
      ref.invalidate(developersProvider);

      CustomMessenger(
        context: context,
        message: "Profile uploaded successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      ).show();
    } catch (e) {
      CustomMessenger(
        context: context,
        message: "Failed to upload profile: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ).show();
    } finally {
      ref.read(isUploadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Add Builder',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 600;

            final profileForm = BuilderProfileForm(
              imageData: ref.watch(builderImageDataProvider),
              onPickImage: () => pickImage(false, ref),
              coverImageData: ref.watch(builderCoverImageDataProvider),
              onPickCoverImage: () => pickImage(true, ref),
              name: ref.watch(builderNameProvider),
              onNameChanged:
                  (val) => ref.read(builderNameProvider.notifier).state = val,
              description: ref.watch(builderDescriptionProvider),
              onDescriptionChanged:
                  (val) =>
                      ref.read(builderDescriptionProvider.notifier).state = val,
              isUploading: ref.watch(isUploadingProvider),
              onUpload: () => _uploadToFirebase(context, ref),
            );

            return isDesktop
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: profileForm),
                    const SizedBox(width: 20),
                  ],
                )
                : profileForm;
          },
        ),
      ),
    );
  }
}

class BuilderProfileForm extends StatelessWidget {
  final Uint8List? imageData;
  final VoidCallback onPickImage;
  final Uint8List? coverImageData;
  final VoidCallback onPickCoverImage;
  final String name;
  final ValueChanged<String> onNameChanged;
  final String description;
  final ValueChanged<String> onDescriptionChanged;
  final bool isUploading;
  final VoidCallback onUpload;

  const BuilderProfileForm({
    super.key,
    required this.imageData,
    required this.onPickImage,
    required this.coverImageData,
    required this.onPickCoverImage,
    required this.name,
    required this.onNameChanged,
    required this.description,
    required this.onDescriptionChanged,
    required this.isUploading,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.upload, color: Colors.black),
            label: Text(
              'Choose Profile Image',
              style: GoogleFonts.nunito(color: Colors.black),
            ),
            onPressed: onPickImage,
          ),
          if (imageData != null) ...[
            const SizedBox(height: 12),
            Image.memory(imageData!, height: 200, fit: BoxFit.cover),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.image_outlined, color: Colors.black),
            label: Text(
              'Choose Cover Image',
              style: GoogleFonts.nunito(color: Colors.black),
            ),
            onPressed: onPickCoverImage,
          ),
          if (coverImageData != null) ...[
            const SizedBox(height: 12),
            Image.memory(coverImageData!, height: 200, fit: BoxFit.cover),
          ],
          const SizedBox(height: 20),
          CustomTextField(label: "Name", value: name, onChanged: onNameChanged),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Description',
            value: description,
            maxLines: 3,
            onChanged: onDescriptionChanged,
          ),
          const SizedBox(height: 24),
          isUploading
              ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 1,
                ),
              )
              : SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: onUpload,
                  child: Text(
                    'Upload',
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
