import 'package:dladmin/Admin/AddProperty/Providers/PropertyUploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Services/providers/owner_info_provider.dart';
import '../DashBoard/Custom/Label_FieldWrapper.dart';
import '../DashBoard/Custom/reusable_text_field.dart';

class OwnerInformationPage extends ConsumerWidget {
  const OwnerInformationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owner = ref.watch(ownerInfoProvider);
    final notifier = ref.read(ownerInfoProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isLoading = ref.watch(propertyUploadProvider);
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

                      SizedBox(height: 20),
                      LabeledFieldWrapper(
                        label: "Property Owner Name",
                        field: ReusableTextField(
                          label: "Property Owner Name",
                          hint: "Enter full name",
                          initialValue: owner.name,
                          onChanged: notifier.setName,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LabeledFieldWrapper(
                        label: "Phone Number",
                        field: ReusableTextField(
                          keyboardType: TextInputType.number,
                          label: "Phone Number",
                          hint: "Enter phone number",
                          initialValue: owner.phone,
                          onChanged: notifier.setPhone,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LabeledFieldWrapper(
                        label: "WhatsApp Number",
                        field: ReusableTextField(
                          keyboardType: TextInputType.number,
                          label: "WhatsApp Number",
                          hint: "Enter WhatsApp number",
                          initialValue: owner.whatsapp,
                          onChanged: notifier.setWhatsapp,
                        ),
                      ),
                      const SizedBox(height: 30),
                      isLoading
                          ? Center(
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: Color.fromARGB(255, 17, 70, 114),
                              size: 25,
                            ),
                          )
                          : Align(
                            alignment: Alignment.center,
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
                                if (owner.name == null || owner.name!.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Field 'Owner Name' is empty",
                                  );
                                  return;
                                }
                                if (owner.phone == null ||
                                    owner.phone!.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Field 'Owner Phone Number' is empty",
                                  );
                                  return;
                                }
                                submitProperty(ref, context);
                              },
                              child: Text(
                                "Save Property",
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
