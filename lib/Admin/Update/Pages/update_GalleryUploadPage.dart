import 'dart:io';
import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:dladmin/Admin/Update/Pages/update_OwnerInformationPage.dart';
import 'package:dladmin/Admin/Update/Providers/update_gallery_upload_provider.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:dladmin/Services/Scaffold_Messanger.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

final imageloadingProvider = StateProvider<bool>((ref) => false);

Future<void> updateImageAtIndex({
  required String propertyId,
  required int index,
  required String newImageUrl,
}) async {
  final response = await http.put(
    Uri.parse(
        'https://api-fxz7qcfy4q-uc.a.run.app/updatePropertyImages/$propertyId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "updates": [
        {
          "index": index,
          "images": newImageUrl,
        }
      ]
    }),
  );

  if (response.statusCode == 200) {
    debugPrint("Updated image at index $index");
  } else {
    debugPrint("Failed to update: ${response.body}");
    Fluttertoast.showToast(msg: "Failed to update image.");
  }
}

class updateGalleryUploadPage extends ConsumerWidget {
  final AgentProperty property;
  const updateGalleryUploadPage({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isUploading = ref.watch(imageloadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Agent Panel",
          style: GoogleFonts.nunito(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 17, 70, 114),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "PROPERTY DETAILS",
                  style: GoogleFonts.nunito(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              for (int i = 0; i < property.images.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: LabeledFieldWrapper(
                    label: "Image ${i + 1}",
                    field: Row(
                      children: [
                        SizedBox(
                            width: 150,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              width: isMobile ? double.infinity : 160,
                              height: isMobile ? 160 : 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                                image: DecorationImage(
                                  image: NetworkImage(property.images[i]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        final picker = ImagePicker();
                                        final pickedFile =
                                            await picker.pickImage(
                                          source: ImageSource.gallery,
                                          imageQuality: 80,
                                        );
                
                                        if (pickedFile != null) {
                                          final file = File(pickedFile.path);
                                          final uuid = const Uuid().v4();
                
                                          final ref = FirebaseStorage.instance
                                              .ref()
                                              .child('prop/$uuid');
                
                                          final uploadTask =
                                              await ref.putFile(
                                            file,
                                            SettableMetadata(
                                                contentType: 'image/jpeg'),
                                          );
                
                                          final downloadUrl = await uploadTask
                                              .ref
                                              .getDownloadURL();
                
                                          await updateImageAtIndex(
                                            propertyId: property.id,
                                            index: i,
                                            newImageUrl: downloadUrl,
                                          );
                
                                          CustomMessenger(
                                                  context: context,
                                                  message:
                                                      "Image ${i + 1} updated successfully!")
                                              .show();
                                        }
                                      },
                                      child: Text(
                                        "Replace Image",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isMobile ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )),
                              ),
                            )),
                        if (property.images.isNotEmpty &&
                            property.images[i].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Image Uploaded",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: isUploading
                    ? LoadingAnimationWidget.threeArchedCircle(
                        color: Color.fromARGB(255, 17, 70, 114), size: 25)
                    : ElevatedButton(
                        onPressed: () async {
                          final values = ref.read(updateimageUploadProvider);
                          ref.read(imageloadingProvider.notifier).state =
                              true;
                
                          await (ref
                              .read(updateimageUploadProvider.notifier)
                              .uploadImages());
                
                          final isNewUploadRequired = property.images.isEmpty;
                
                          if (isNewUploadRequired &&
                              values.images.contains(null)) {
                            ref.read(imageloadingProvider.notifier).state =
                                false;
                
                            Fluttertoast.showToast(
                              msg:
                                  "Please upload all 4 images before submitting.",
                            );
                            return;
                          }
                
                          for (int i = 0; i < values.filenames.length; i++) {
                            debugPrint(
                                "Image ${i + 1}: ${values.filenames[i]}");
                          }
                
                          Fluttertoast.showToast(
                              msg: "Images submitted successfully!");
                
                          ref.read(imageloadingProvider.notifier).state =
                              false;
                
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: updateOwnerInformationPage(
                                property: property,
                              ),
                              duration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          backgroundColor: Color.fromARGB(255, 17, 70, 114),
                        ),
                        child: Text(
                          "Next",
                          style: GoogleFonts.nunito(color: Colors.white),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
