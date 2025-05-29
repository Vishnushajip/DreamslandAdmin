import 'package:dladmin/Admin/DashBoard/Custom/Label_FieldWrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/user_form_provider.dart';
import '../widgets/custom_text_field.dart';

class FormStep2 extends ConsumerWidget {
  const FormStep2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(userFormProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledFieldWrapper(
            label: "Address",
            field: CustomTextField(
              icon: FontAwesomeIcons.addressBook,
              label: "",
              value: form.address,
              onChanged:
                  (val) => ref
                      .read(userFormProvider.notifier)
                      .updateField('address', val),
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 12),
          LabeledFieldWrapper(
            label: "District",
            field: CustomTextField(
              icon: FontAwesomeIcons.locationArrow,
              label: "District",
              value: form.district,
              onChanged:
                  (val) => ref
                      .read(userFormProvider.notifier)
                      .updateField('district', val),
            ),
          ),
          const SizedBox(height: 12),
          // LabeledFieldWrapper(label: "Place",
          //   field: CustomTextField(
          //     label: "Place",
          //     value: form.district,
          //     onChanged: (val) =>
          //         ref.read(userFormProvider.notifier).updateField('place', val),
          //   ),
          // ),
          const SizedBox(height: 12),
          LabeledFieldWrapper(
            label: "Age",
            field: CustomTextField(
              icon: Icons.fact_check_outlined,
              label: "Age",
              value: form.age,
              onChanged:
                  (val) => ref
                      .read(userFormProvider.notifier)
                      .updateField('age', val),
              isNumber: true,
            ),
          ),
          const SizedBox(height: 12),
          LabeledFieldWrapper(
            label: "Contact Number",
            field: CustomTextField(
              icon: FontAwesomeIcons.squarePhone,
              label: "Contact Number",
              value: form.contactNumber,
              onChanged:
                  (val) => ref
                      .read(userFormProvider.notifier)
                      .updateField('contactNumber', val),
              isNumber: true,
            ),
          ),
          const SizedBox(height: 12),
          LabeledFieldWrapper(
            label: "WhatsApp Number",
            field: CustomTextField(
              icon: FontAwesomeIcons.whatsapp,
              label: "WhatsApp Number",
              value: form.whatsappNumber,
              onChanged:
                  (val) => ref
                      .read(userFormProvider.notifier)
                      .updateField('whatsappNumber', val),
              isNumber: true,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
