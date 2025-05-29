// ignore_for_file: curly_braces_in_flow_control_structures, unused_result
import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_dropdown.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_text_field.dart';
import 'package:dladmin/Admin/Update/Pages/UpdateStatusAndDescriptionPage.dart';
import 'package:dladmin/Admin/Update/Providers/updateproperty_form_provider.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

final agentUsernameProvider = StateProvider<String?>((ref) => null);
final agentUsernamesProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance.collection('agents').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => doc['Username']?.toString() ?? '')
          .where((username) => username.isNotEmpty)
          .toList());
});
class updateMoreInformation extends ConsumerWidget {
  final AgentProperty property;

  const updateMoreInformation({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final model = ref.watch(updatepropertyFormProvider);
    final notifier = ref.read(updatepropertyFormProvider.notifier);
    final values = ref.read(updatepropertyFormProvider);

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
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10)
              ],
            ),
            constraints: const BoxConstraints(
              maxWidth: 800,
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
                
                SizedBox(
                  height: 20,
                ),
                if (values.subtype == "Residential Villa/Houses" ||
                    values.subtype == "Residential Apartments" ||
                    values.subtype == "Residential Other")
                  LabeledFieldWrapper(
                    label: "BHK",
                    field: ReusableTextField(
                        keyboardType: TextInputType.number,
                        hint: "BHK",
                        label: "BHK",
                        initialValue: (property.bhk).toString(),
                        onChanged: (value) =>
                            notifier.setBHK(int.tryParse(value) ?? 0)),
                  ),
                const SizedBox(height: 15),
                LabeledFieldWrapper(
                  label: "Square Feet",
                  field: ReusableTextField(
                      keyboardType: TextInputType.number,
                      hint: "Square Feet",
                      label: "Square Feet",
                      initialValue: property.sqft,
                      onChanged: notifier.setSqft),
                ),
                const SizedBox(height: 15),
                LabeledFieldWrapper(
                  label: "Price",
                  field: ReusableTextField(
                    keyboardType: TextInputType.number,
                    hint: "Price",
                    label: "Price",
                    initialValue:
                        model.price?.toString() ?? property.price.toString(),
                    onChanged: (value) => notifier
                        .setPrice(value.isEmpty ? 0 : num.tryParse(value) ?? 0),
                  ),
                ),
                const SizedBox(height: 15),
                LabeledFieldWrapper(
                  label: "Plot Area",
                  field: ReusableTextField(
                      keyboardType: TextInputType.number,
                      hint: "Plot Area",
                      label: "Plot Area",
                      initialValue: property.plotArea,
                      onChanged: (value) => notifier.setPlotArea(value)),
                ),
                const SizedBox(height: 15),
                FutureBuilder<String?>(
                  future: SharedPreferences.getInstance()
                      .then((prefs) => prefs.getString('role')),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }


                    

                    return Consumer(
                      builder: (context, ref, child) {
                        final usernamesAsync =
                            ref.watch(agentUsernamesProvider);

                        return usernamesAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (error, stack) => const SizedBox.shrink(),
                          data: (usernames) {
                            if (property.agent != null &&
                                property.agent!.isNotEmpty &&
                                !usernames.contains(property.agent)) {
                              usernames.insert(0, property.agent!);
                            }

                            return LabeledFieldWrapper(
                              label: "Select Agent",
                              field: ReusableDropdown(
                                hint: "Select Agent",
                                label: "",
                                value: property.agent,
                                items: usernames,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(agentUsernameProvider.notifier)
                                        .state = val;
                                    property.agent = val;
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 15),
                LabeledFieldWrapper(
                  label: "Plot Unit",
                  field: ReusableDropdown(
                    hint: "Plot Unit",
                    label: "Plot Unit",
                    value: property.unit,
                    items: ["Acre", "Cent"],
                    onChanged: (val) => notifier.setUnit(val!),
                  ),
                ),
                const SizedBox(height: 15),
                LabeledFieldWrapper(
                  label: "Listed on",
                  field: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: property.createdAt,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        notifier.setListedOn(picked.millisecondsSinceEpoch);
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        decoration: _inputDecoration("Pick a date"),
                        controller: TextEditingController(
                          text: DateFormat('dd-MM-yyyy')
                              .format(property.createdAt),
                        ),
                      ),
                    ),
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
                      if (property.sqft.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Field 'Sqaure Feet' is empty");
                        return;
                      }
                      if (property.price <= 0) {
                        Fluttertoast.showToast(msg: "Field 'Price' is empty");
                        return;
                      }
                      if (property.plotArea.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Field 'Plot Area' is empty");
                        return;
                      }
                      if (property.unit.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Field 'Plot Unit' is empty");
                        return;
                      }

                      debugPrint("BHK: ${model.bhk}");
                      debugPrint("Sqft: ${model.sqft}");
                      debugPrint("Price: ${model.price}");
                      debugPrint("Plot Area: ${model.plotArea}");
                      debugPrint("Unit: ${model.unit}");
                      debugPrint("Listed On: ${model.listedOn}");
                      // final prefs = await SharedPreferences.getInstance();
                      // prefs.remove("username");
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: updateStatusAndDescriptionPage(
                            property: property,
                          ),
                          duration: Duration(milliseconds: 400),
                        ),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
