import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_dropdown.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_text_field.dart';
import 'package:dladmin/Admin/Update/Pages/Update_More_Details.dart';
import 'package:dladmin/Admin/Update/Providers/updateproperty_form_provider.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import '../../../../Admin/Add_Agent/providers/Location_DropDwon.dart';

class updatePropertyFormPage extends ConsumerWidget {
  final AgentProperty property;
  const updatePropertyFormPage({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(updatepropertyFormProvider);
    final notifier = ref.read(updatepropertyFormProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 800;
    if (form.id == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.initializeFromProperty(property);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: true,
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
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
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
                  label: "Property Location",
                  field: LocationDropdown(
                    initialValue: property.location,

                    onSelected: (val) => notifier.setLocation(val),
                  ),
                ),
                const SizedBox(height: 15),
                LabeledFieldWrapper(
                  label: "Property Caption",
                  field: ReusableTextField(
                    label: 'Property Caption',
                    hint: "Enter property Caption",
                    initialValue: property.name,
                    onChanged: (val) => notifier.setName(val),
                  ),
                ),
                const SizedBox(height: 15),
                LabeledFieldWrapper(
                  label: "Property Type",
                  field: ReusableDropdown(
                    initialValue: property.type,
                    label: "Property Type",
                    hint: "Select Property Type",
                    value: property.type,
                    items: ['Residential', 'Commercial'],
                    onChanged: (val) => notifier.setType(val!),
                  ),
                ),
                const SizedBox(height: 15),
                LabeledFieldWrapper(
                  label: "Property Subtype",
                  field: ReusableDropdown(
                    initialValue: property.subtype,
                    label: "Property Subtype",
                    hint: "Select Subtype",
                    value: property.subtype,
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
                    onChanged: (val) => notifier.setSubtype(val!),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 17, 70, 114),
                    ),
                    onPressed: () {
                      if (property.location.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Field 'location' is empty",
                        );
                        return;
                      }
                      if (property.name.isEmpty) {
                        Fluttertoast.showToast(msg: "Field 'name' is empty");
                        return;
                      }
                      if (property.type.isEmpty) {
                        Fluttertoast.showToast(msg: "Field 'type' is empty");
                        return;
                      }
                      if (property.subtype.isEmpty) {
                        Fluttertoast.showToast(msg: "Field 'subtype' is empty");
                        return;
                      }

                      debugPrint("Saved Values:");
                      debugPrint("Location: ${property.location}");
                      debugPrint("Name: ${property.name}");
                      debugPrint("Type: ${property.type}");
                      debugPrint("Subtype: ${property.subtype}");
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: updateMoreInformation(property: property),
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
      ),
    );
  }
}
