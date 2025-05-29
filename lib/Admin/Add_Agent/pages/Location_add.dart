import 'dart:io';
import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/Add_LocationImage.dart';
import '../widgets/custom_text_field.dart';

class LocationUploadPage extends ConsumerWidget {
  const LocationUploadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imageUploadProvider);
    final location = ref.watch(locationNameProvider);
    final isUploading = ref.watch(isUploadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF1C3A6B),
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Add Location",
          style: GoogleFonts.nunito(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              LabeledFieldWrapper(
                label: "Location",
                field: CustomTextField(
                  icon: FontAwesomeIcons.locationArrow,
                  label: "Location Name",
                  value: location,
                  onChanged:
                      (val) =>
                          ref.read(locationNameProvider.notifier).state = val,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Color(0xFF1C3A6B),
                  ),
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: Text(
                    "Choose Image",
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (pickedFile != null) {
                      final file = File(pickedFile.path);
                      ref
                          .read(imageUploadProvider.notifier)
                          .setImage(0, file, pickedFile.name);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  imageState.filenames[0] != 'No file chosen'
                      ? 'Selected: ${imageState.filenames[0]}'
                      : 'No image selected',
                  style: GoogleFonts.nunito(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              isUploading
                  ? Center(child: const CircularProgressIndicator())
                  : Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: Color(0xFF1C3A6B),
                      ),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        "Save Location",
                        style: GoogleFonts.nunito(color: Colors.white),
                      ),
                      onPressed: () async {
                        final file = imageState.images[0];
                        final name = ref.read(locationNameProvider);

                        if (file == null || name.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Location and image are required"),
                            ),
                          );
                          return;
                        }

                        ref.read(isUploadingProvider.notifier).state = true;

                        await ref
                            .read(imageUploadProvider.notifier)
                            .uploadImages();

                        final imageUrl =
                            ref.read(imageUploadProvider).downloadUrls[0];

                        await LocationService.saveLocation(name, imageUrl);

                        ref.invalidate(imageUploadProvider);
                        ref.invalidate(locationNameProvider);
                        ref.read(isUploadingProvider.notifier).state = false;
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          msg: "Location added successfully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
