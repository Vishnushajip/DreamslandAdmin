import 'package:dladmin/Admin/Add_Agent/pages/form_step2.dart';
import 'package:dladmin/Admin/Add_Agent/pages/form_step3.dart';
import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_form_provider.dart';
import '../widgets/custom_text_field.dart';

class FormStep1 extends ConsumerWidget {
  const FormStep1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(userFormProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 17, 70, 114),
        title: Text(
          "Add Agent",
          style: GoogleFonts.nunito(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LabeledFieldWrapper(
                label: "First Name",
                field: CustomTextField(
                  icon: CupertinoIcons.person_alt,
                  label: "First Name",
                  value: form.firstName,
                  onChanged:
                      (val) => ref
                          .read(userFormProvider.notifier)
                          .updateField('firstName', val),
                ),
              ),
              const SizedBox(height: 12),
              LabeledFieldWrapper(
                label: "Last Name",
                field: CustomTextField(
                  icon: CupertinoIcons.person_alt_circle,
                  label: "Last Name",
                  value: form.lastName,
                  onChanged:
                      (val) => ref
                          .read(userFormProvider.notifier)
                          .updateField('lastName', val),
                ),
              ),
              const SizedBox(height: 12),
              LabeledFieldWrapper(
                label: "Username",
                field: CustomTextField(
                  icon: FontAwesomeIcons.adn,
                  label: "Username",
                  value: form.username,
                  onChanged:
                      (val) => ref
                          .read(userFormProvider.notifier)
                          .updateField('username', val),
                ),
              ),
              const SizedBox(height: 12),
              LabeledFieldWrapper(
                label: "Password",
                field: CustomTextField(
                  icon: FontAwesomeIcons.unlockKeyhole,
                  label: "Password",
                  value: form.password,
                  onChanged:
                      (val) => ref
                          .read(userFormProvider.notifier)
                          .updateField('password', val),
                ),
              ),
              const SizedBox(height: 20),
              FormStep2(),
              FormStep3(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
