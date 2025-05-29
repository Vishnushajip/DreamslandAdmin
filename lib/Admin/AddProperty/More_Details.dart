// ignore_for_file: unused_result

import 'package:dladmin/Admin/AddProperty/Providers/property_listing_provider.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/Fetch_docs.dart';
import '../DashBoard/Custom/Label_FieldWrapper.dart';
import '../DashBoard/Custom/reusable_dropdown.dart';
import '../DashBoard/Custom/reusable_text_field.dart';
import 'Providers/property_form_provider.dart';
import 'StatusAndDescriptionPage.dart';

final agentUsernamesProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('agents')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => doc['Username']?.toString() ?? '')
                .where((username) => username.isNotEmpty)
                .toList(),
      );
});
final builderUsernamesProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('Developers')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => doc['name']?.toString() ?? '')
                .where((username) => username.isNotEmpty)
                .toList(),
      );
});

class MoreInformation extends ConsumerWidget {
  const MoreInformation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final model = ref.watch(propertyListingProvider);
    final notifier = ref.read(propertyListingProvider.notifier);
    final values = ref.read(propertyFormProvider);
    bool isWeb = identical(0, 0.0);

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
                      if (values.subtype == "Residential Villa/Houses" ||
                          values.subtype == "Residential Apartments" ||
                          values.subtype == "Residential Other")
                        LabeledFieldWrapper(
                          label: "BHK",
                          field: ReusableTextField(
                            keyboardType: TextInputType.number,
                            hint: "BHK",
                            label: "BHK",
                            initialValue: model.bhk,
                            onChanged: notifier.setBHK,
                          ),
                        ),
                      const SizedBox(height: 15),
                      if (values.subtype == "Residential Villa/Houses" ||
                          values.subtype == "Residential Apartments" ||
                          values.subtype == "Commercial Shop" ||
                          values.subtype == "Commercial Building" ||
                          values.subtype == "Residential Other")
                        LabeledFieldWrapper(
                          label: "Square Feet",
                          field: ReusableTextField(
                            keyboardType: TextInputType.number,
                            hint: "Square Feet",
                            label: "Square Feet",
                            initialValue: model.sqft,
                            onChanged: notifier.setSqft,
                          ),
                        ),
                      const SizedBox(height: 15),
                      LabeledFieldWrapper(
                        label: "Price",
                        field: ReusableTextField(
                          keyboardType: TextInputType.number,
                          hint: "Price",
                          label: "Price",
                          initialValue: model.price,
                          onChanged: notifier.setPrice,
                        ),
                      ),
                      const SizedBox(height: 15),
                      LabeledFieldWrapper(
                        label: "Plot Area",
                        field: ReusableTextField(
                          keyboardType: TextInputType.number,
                          hint: "Plot Area",
                          label: "Plot Area",
                          initialValue: model.area,
                          onChanged: notifier.setArea,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FutureBuilder<String?>(
                        future: SharedPreferences.getInstance().then(
                          (prefs) => prefs.getString('builder'),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }

                          final currentUsername = snapshot.data;

                          if (currentUsername == 'builder') {
                            return Consumer(
                              builder: (context, ref, child) {
                                final buildersAsync = ref.watch(
                                  builderUsernamesProvider,
                                );

                                return buildersAsync.when(
                                  loading: () => const SizedBox.shrink(),
                                  error:
                                      (error, stack) => const SizedBox.shrink(),
                                  data: (builders) {
                                    return LabeledFieldWrapper(
                                      label: "Select Builder",
                                      field: ReusableDropdown(
                                        hint: "Select Builder",
                                        label: "",
                                        value: model.builder,
                                        items: builders,
                                        onChanged:
                                            (val) => notifier.setBuilder(val!),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }

                          if (currentUsername == null ||
                              currentUsername.isEmpty) {
                            return Consumer(
                              builder: (context, ref, child) {
                                final agentsAsync = ref.watch(
                                  agentUsernamesProvider,
                                );

                                return agentsAsync.when(
                                  loading: () => const SizedBox.shrink(),
                                  error:
                                      (error, stack) => const SizedBox.shrink(),
                                  data: (agents) {
                                    return LabeledFieldWrapper(
                                      label: "Select Agent",
                                      field: ReusableDropdown(
                                        hint: "Select Agent",
                                        label: "",
                                        value: model.builder,
                                        items: agents,
                                        onChanged:
                                            (val) => notifier.setBuilder(val!),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                      LabeledFieldWrapper(
                        label: "Plot Unit",
                        field: ReusableDropdown(
                          hint: "Plot Unit",
                          label: "",
                          value: model.unit,
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
                              initialDate: model.listedOn,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              notifier.setListedOn(picked);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              readOnly: true,
                              decoration: _inputDecoration("Pick a date"),
                              controller: TextEditingController(
                                text: DateFormat(
                                  'dd-MM-yyyy',
                                ).format(model.listedOn),
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
                            final prefs = await SharedPreferences.getInstance();
                            final username = prefs.getString('username');

                            if (username != null) {
                              notifier.setBuilder(username);
                              print('Builder set to: $username');
                            } else {
                              print('Username not found in SharedPreferences');
                            }
                            ref.refresh(agentIdProvider);
                            final values = ref.read(propertyListingProvider);

                            if (values.price == null || values.price!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'Price' is empty",
                              );
                              return;
                            }
                            if (values.area == null || values.area!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'Plot Area' is empty",
                              );
                              return;
                            }
                            if (values.unit == null || values.unit!.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Field 'Plot Unit' is empty",
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: StatusAndDescriptionPage(),
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
