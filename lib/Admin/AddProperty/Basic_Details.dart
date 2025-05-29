import 'package:dladmin/Admin/AddProperty/More_Details.dart';
import 'package:dladmin/Admin/AddProperty/Providers/property_form_provider.dart';
import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_dropdown.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import '../../Admin/Add_Agent/providers/Location_DropDwon.dart';

class PropertyFormPage extends ConsumerWidget {
  const PropertyFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(propertyFormProvider);
    final isMobile = MediaQuery.of(context).size.width < 800;
    bool isWeb = identical(0, 0.0);

    return Scaffold(
      resizeToAvoidBottomInset: !isWeb,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: isWeb ? 0 : MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [SizedBox(height: 20),
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
                        label: "Property Location",
                        field: LocationDropdown(
                          onSelected:
                              (val) => ref
                                  .read(propertyFormProvider.notifier)
                                  .setLocation(val),
                        ),
                      ),
                      const SizedBox(height: 15),
                      LabeledFieldWrapper(
                        label: "Property Caption",
                        field: ReusableTextField(
                          label: 'Property Caption',
                          hint: "Enter property Caption",
                          initialValue: form.name,
                          onChanged:
                              (val) => ref
                                  .read(propertyFormProvider.notifier)
                                  .setName(val),
                        ),
                      ),
                      const SizedBox(height: 15),
                      LabeledFieldWrapper(
                        label: "Property Type",
                        field: ReusableDropdown(
                          label: "",
                          hint: "Select Property Type",
                          value: form.type,
                          items: ['Residential', 'Commercial'],
                          onChanged:
                              (val) => ref
                                  .read(propertyFormProvider.notifier)
                                  .setType(val!),
                        ),
                      ),
                      const SizedBox(height: 15),
                      LabeledFieldWrapper(
                        label: "Property Subtype",
                        field: ReusableDropdown(
                          label: "",
                          hint: "Select Subtype",
                          value: form.subtype,
                          items: [
                            'Residential Villa/Houses',
                            'Residential Apartments',
                            'Residential Land',
                            'Residential Other',
                            'Commercial Shop',
                            'Commercial Land',
                            'Commercial Building',
                            'Commercial Other',
                          ],
                          onChanged:
                              (val) => ref
                                  .read(propertyFormProvider.notifier)
                                  .setSubtype(val!),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 17, 70, 114),
                          ),
                          onPressed: () async {
                            final values = ref.read(propertyFormProvider);
                  
                            if (values.location == null ||
                                values.location!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'location' is empty",
                              );
                              return;
                            }
                            if (values.name == null || values.name!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'name' is empty",
                              );
                              return;
                            }
                            if (values.type == null || values.type!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'type' is empty",
                              );
                              return;
                            }
                            if (values.subtype == null ||
                                values.subtype!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'subtype' is empty",
                              );
                              return;
                            }
                  
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: MoreInformation(),
                                duration: Duration(milliseconds: 400),
                              ),
                            );
                            Fluttertoast.showToast(
                              msg: "Property saved successfully!",
                            );
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
            );
          },
        ),
      ),
    );
  }
}
