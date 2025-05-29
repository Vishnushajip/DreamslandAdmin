// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_dropdown.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_text_field.dart';
import 'package:dladmin/Admin/Update/Pages/update_GalleryUploadPage.dart';
import 'package:dladmin/Admin/Update/Providers/updateproperty_form_provider.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class updateStatusAndDescriptionPage extends ConsumerWidget {
  final AgentProperty property;

  const updateStatusAndDescriptionPage({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(updatepropertyFormProvider);
    final notifier = ref.read(updatepropertyFormProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Agent Panel",
          style: GoogleFonts.nunito(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 17, 70, 114),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "PROPERTY DETAILS",
                    style: GoogleFonts.cinzel(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                
                LabeledFieldWrapper(
                  label: "Property Status",
                  field: ReusableDropdown(
                    label: "Property Status",
                    hint: "Select Status",
                    value: property.status,
                    items: const ['Available', 'Sold'],
                    onChanged: (val) => notifier.setStatus(val!),
                  ),
                ),
                LabeledFieldWrapper(
                  label: "Pricing Options",
                  field: ReusableDropdown(
                    label: "Pricing Options",
                    hint: "Select Pricing Options",
                    value: property.pricingOptions,
                    items: const [
                      'Negotiable',
                      'Onwards',
                      'Fixed',
                    ],
                    onChanged: (val) => notifier.setPricingOptions(val!),
                  ),
                ),
                LabeledFieldWrapper(
                  label: "Property description",
                  field: ReusableTextField(
                    max: 7,
                    label: "Property description",
                    hint: "Enter property description",
                    initialValue: property.propertyDescription,
                    onChanged: (val) => notifier.setDescription(val),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 17, 70, 114),
                    ),
                    onPressed: () async {
                      if (property.status.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Field 'Property Status' is empty");
                        return;
                      }
                      if (property.pricingOptions.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Field 'Pricing options' is empty");
                        return;
                      }
                      if (property.propertyDescription.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Field 'Property description' is empty");
                        return;
                      }
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: updateGalleryUploadPage(
                                property: property,
                              ),
                              duration: Duration(milliseconds: 400)));
                      debugPrint("Status: ${form.status}");
                      debugPrint("Note: ${form.pricingOptions}");
                      debugPrint("Description: ${form.propertyDescription}");
                    },
                    child: Text(
                      "Next",
                      style: GoogleFonts.cinzel(color: Colors.white),
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
