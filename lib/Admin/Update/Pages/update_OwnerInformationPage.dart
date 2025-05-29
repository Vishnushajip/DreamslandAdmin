// ignore_for_file: unused_result
import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_text_field.dart';
import 'package:dladmin/Admin/Update/Providers/Update_prop.dart';
import 'package:dladmin/Admin/Update/Providers/update_Agent.dart';
import 'package:dladmin/Admin/Update/Providers/updateproperty_form_provider.dart';
import 'package:dladmin/Landing/floating_bottom_navigation_bar.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:dladmin/Services/providers/PropertyUploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class updateOwnerInformationPage extends ConsumerWidget {
  final AgentProperty property;
  const updateOwnerInformationPage({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(updatepropertyFormProvider);
    final notifier = ref.read(updatepropertyFormProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isLoading = ref.watch(propertyUploadProvider);
    final isUpdating = ref.watch(isUpdatingProvider);

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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 850),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
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

              LabeledFieldWrapper(
                label: "Property Owner Name",
                field: ReusableTextField(
                  label: "Property Owner Name",
                  hint: "Enter full name",
                  initialValue: property.ownerName,
                  onChanged: (value) => notifier.setOwnerName(value),
                ),
              ),
              LabeledFieldWrapper(
                label: "Agent",
                field: Dropdownagent(
                  initialValue: property.ownerName,
                  onSelected: (value) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('username', value);
                  },
                ),
              ),
              const SizedBox(height: 20),
              LabeledFieldWrapper(
                label: "Phone Number",
                field: ReusableTextField(
                  keyboardType: TextInputType.number,
                  label: "Phone Number",
                  hint: "Enter phone number",
                  initialValue: property.phoneNumber,
                  onChanged: (value) => notifier.setPhoneNumber(value),
                ),
              ),
              const SizedBox(height: 20),
              LabeledFieldWrapper(
                label: "WhatsApp Number",
                field: ReusableTextField(
                  label: "WhatsApp Number",
                  hint: "Enter WhatsApp number",
                  initialValue: property.whatsappNumber,
                  onChanged: (value) => notifier.setWhatsAppNumber(value),
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.bottomRight,
                child:
                    isLoading
                        ? LoadingAnimationWidget.threeArchedCircle(
                          color: Color.fromARGB(255, 17, 70, 114),
                          size: 25,
                        )
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              17,
                              70,
                              114,
                            ),
                          ),
                          onPressed: () async {
                            final notifier = ref.read(
                              isUpdatingProvider.notifier,
                            );
                            notifier.state = true;
                            final form = property.id;

                            try {
                              final updatedProperty = await ref.read(
                                updateFromFormProvider(form).future,
                              );

                              Fluttertoast.showToast(
                                toastLength: Toast.LENGTH_LONG,
                                msg:
                                    "Property updated: ${updatedProperty.name}",
                              );

                              ref.refresh(agentPropertiesProvider);
                            } catch (e) {
                              print(e);
                              Fluttertoast.showToast(
                                msg: "Update failed: $e",
                                backgroundColor: Colors.red,
                                toastLength: Toast.LENGTH_LONG,
                              );
                            } finally {
                              ref.read(isUpdatingProvider.notifier).state =
                                  false;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Navbar(),
                                ),
                              );
                            }
                          },
                          child:
                              isUpdating
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    "Update Property",
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white,
                                    ),
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
