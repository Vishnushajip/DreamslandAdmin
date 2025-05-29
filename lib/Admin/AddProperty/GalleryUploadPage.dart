import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import '../DashBoard/Custom/Label_FieldWrapper.dart';
import 'OwnerInformationPage.dart';
import 'Providers/gallery_upload_provider.dart';

final imageloadingProvider = StateProvider<bool>((ref) => false);

class GalleryUploadPage extends ConsumerWidget {
  const GalleryUploadPage({super.key});

  void pickImage(
    Function(File imageFile, String filename) onImagePicked,
  ) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      onImagePicked(file, pickedFile.name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageUploadProvider);
    final notifier = ref.read(imageUploadProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isUploading = ref.watch(imageloadingProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Agent Panel",
          style: GoogleFonts.nunito(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 17, 70, 114),
      ),
      body: Center(
        child: SingleChildScrollView(
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

                SizedBox(height: 20),
                for (int i = 0; i < 10; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: LabeledFieldWrapper(
                      label: "Image ${i + 1}",
                      field: Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: const BorderSide(color: Colors.grey),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              pickImage((file, fileName) {
                                notifier.setImage(i, file, fileName);
                              });
                            },

                            child: const Text("Choose File"),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              state.filenames[i],
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                isUploading
                    ? Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                        color: Color.fromARGB(255, 17, 70, 114),
                        size: 25,
                      ),
                    )
                    : Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final values = ref.read(imageUploadProvider);

                          ref.read(imageloadingProvider.notifier).state = true;

                          await (ref
                              .read(imageUploadProvider.notifier)
                              .uploadImages());

                          if (values.images
                                  .where((image) => image != null)
                                  .length <
                              4) {
                            ref.read(imageloadingProvider.notifier).state =
                                false;
                            Fluttertoast.showToast(
                              msg:
                                  "Please upload at least 4 images before submitting.",
                            );
                            return;
                          }

                          Fluttertoast.showToast(
                            msg: "Images submitted successfully!",
                          );

                          ref.read(imageloadingProvider.notifier).state = false;

                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: const OwnerInformationPage(),
                              duration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            17,
                            70,
                            114,
                          ),
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
      ),
    );
  }
}
