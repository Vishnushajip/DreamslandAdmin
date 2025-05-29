import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/Providers/status_description_provider.dart';
import '../DashBoard/Custom/Label_FieldWrapper.dart';
import '../DashBoard/Custom/reusable_dropdown.dart';
import '../DashBoard/Custom/reusable_text_field.dart';
import 'GalleryUploadPage.dart';

class StatusAndDescriptionPage extends ConsumerWidget {
  const StatusAndDescriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(statusDescriptionProvider);
    final notifier = ref.read(statusDescriptionProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 800;
    bool isWeb = identical(0, 0.0);

    return Scaffold(
      resizeToAvoidBottomInset: !isWeb,
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: isWeb ? 0 : MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
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
                  
                      LabeledFieldWrapper(
                        label: "Property Status",
                        field: ReusableDropdown(
                          label: "",
                          hint: "Select Status",
                          value: form.status,
                          items: const ['Available', 'Sold'],
                          onChanged: (val) => notifier.setStatus(val!),
                        ),
                      ),
                      LabeledFieldWrapper(
                        label: "Verification Status",
                        field: ReusableDropdown(
                          label: "",
                          hint: "Select Status",
                          value: form.verified,
                          items: const ['Verified', 'Not verified'],
                          onChanged: (val) => notifier.setVerified(val!),
                        ),
                      ),
                      LabeledFieldWrapper(
                        label: "Pricing Options",
                        field: ReusableDropdown(
                          label: "",
                          hint: "Select Pricing Options",
                          value: form.note,
                          items: const ['Negotiable', 'Onwards', 'Fixed'],
                          onChanged: (val) => notifier.setNote(val!),
                        ),
                      ),
                      LabeledFieldWrapper(
                        label: "Property description",
                        field: ReusableTextField(
                          max: 7,
                          label: "",
                          hint: "Enter property description",
                          initialValue: form.description,
                          onChanged: (val) => notifier.setDescription(val),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              17,
                              70,
                              114,
                            ),
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final username = prefs.getString('username');
                  
                            if (username == 'builder') {
                              prefs.remove('username');
                            }
                            final values = ref.read(statusDescriptionProvider);
                            if (values.status == null ||
                                values.status!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'Property Status' is empty",
                              );
                              return;
                            }
                            if (values.note == null || values.note!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'Pricing options' is empty",
                              );
                              return;
                            }
                            if (values.description == null ||
                                values.description!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'Property description' is empty",
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: GalleryUploadPage(),
                                duration: Duration(milliseconds: 400),
                              ),
                            );
                          },
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
          },
        ),
      ),
    );
  }
}
