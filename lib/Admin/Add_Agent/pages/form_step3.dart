// ignore_for_file: unused_result

import 'package:dladmin/Admin/Add_Agent/providers/allocated_locations.dart';
import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:dladmin/Landing/floating_bottom_navigation_bar.dart';
import 'package:dladmin/Services/Scaffold_Messanger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_form_provider.dart';
import '../providers/firestore_service.dart';

final isSavingProvider = StateProvider<bool>((ref) => false);

class FormStep3 extends ConsumerWidget {
  const FormStep3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(userFormProvider);
    final isSaving = ref.watch(isSavingProvider);

    final formData = {
      'Firstname': form.firstName,
      'Lastname': form.lastName,
      'Username': form.username,
      'Password': form.password,
      'Personaladdress': form.address,
      'Districtplace': form.district,
      'Age': form.age,
      'Contactnumber': form.contactNumber,
      'Whatsappnumber': form.whatsappNumber,
      'Allocatedlocations': form.allocatedLocations.join(', '),
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          LabeledFieldWrapper(
            label: "Locations",
            field: LocationDropdown(
              icon: Icons.location_on_rounded,
              initialLocations: form.allocatedLocations,
              onSelected: (location) {
                ref
                    .read(userFormProvider.notifier)
                    .addAllocatedLocation(location);
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child:
                isSaving
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: 250,
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _handleSubmit(ref, form, formData, context),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          "Submit",
                          style: GoogleFonts.nunito(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    WidgetRef ref,
    UserFormModel form,
    Map<String, String> formData,
    BuildContext context,
  ) async {
    final missingFields =
        formData.entries
            .where((entry) => entry.value.isEmpty)
            .map((entry) => entry.key)
            .toList();

    if (missingFields.isNotEmpty) {
      CustomMessenger(
        message: "Please fill: ${missingFields.join(', ')}",
        context: context,
        backgroundColor: Colors.red,
        duration: Durations.extralong1,
        textColor: Colors.white,
      ).show();
      return;
    }

    ref.read(isSavingProvider.notifier).state = true;

    try {
      await FirestoreService.saveUserForm(form);
      CustomMessenger(
        message: "Agent Saved Successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
        context: context,
        duration: Durations.extralong1,
      ).show();

      ref.refresh(userFormProvider);
      ref.refresh(isSavingProvider);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Navbar()),
      );
    } catch (e) {
      CustomMessenger(
        message: "Error saving agent",
        backgroundColor: Colors.red,
        context: context,
        textColor: Colors.white,
      ).show;
    } finally {
      ref.read(isSavingProvider.notifier).state = false;
    }
  }
}
