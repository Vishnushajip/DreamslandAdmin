import 'package:dladmin/Admin/DashBoard/Providers/deleted_properties_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DeletedPropertiesPage extends ConsumerWidget {
  const DeletedPropertiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(deletedPropertiesProvider);
    final deletedByListAsync = ref.watch(deletedByListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDatePicker(ref, context),
                _buildDeletedByDropdown(ref, deletedByListAsync),
              ],
            ),

            const SizedBox(height: 20),
            Expanded(
              child: propertiesAsync.when(
                data: (properties) {
                  if (properties.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.domain_disabled,
                            color: Colors.grey.shade500,
                            size: 60,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No Properties Found',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      final deletedAt =
                          property['deletedAt'] is DateTime
                              ? property['deletedAt'] as DateTime
                              : DateTime.now();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${property['id']} - ${property['ownerName']}',
                            style: GoogleFonts.nunito(fontSize: 16),
                          ),
                          Text(
                            'Phone: ${property['phoneNumber']}',
                            style: GoogleFonts.nunito(fontSize: 14),
                          ),
                          Text(
                            'WhatsApp: ${property['whatsapp']}',
                            style: GoogleFonts.nunito(fontSize: 14),
                          ),
                          Text(
                            'Deleted By: ${property['deletedBy']}',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            'Deleted At: ${DateFormat('dd - MM - yyyy').format(deletedAt)}',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                          const Divider(color: Colors.grey),
                        ],
                      );
                    },
                  );
                },
                loading:
                    () => Center(
                      child: LoadingAnimationWidget.inkDrop(
                        color: const Color.fromARGB(255, 5, 38, 95),
                        size: 60,
                      ),
                    ),
                error: (error, stackTrace) => Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(WidgetRef ref, BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          ref.read(selectedDateProvider.notifier).state = picked;
        }
      },
      child: Text(
        DateFormat('dd - MM - yyyy').format(selectedDate),
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDeletedByDropdown(
    WidgetRef ref,
    AsyncValue<List<String>> deletedByListAsync,
  ) {
    final selectedDeletedBy = ref.watch(selectedDeletedByProvider);

    return deletedByListAsync.when(
      data: (deletedByList) {
        return DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            value: selectedDeletedBy,
            items:
                deletedByList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: GoogleFonts.nunito(fontSize: 12)),
                  );
                }).toList(),
            onChanged:
                (value) =>
                    ref.read(selectedDeletedByProvider.notifier).state = value!,
            buttonStyleData: ButtonStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1),
                color: Colors.white,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
            ),
            iconStyleData: IconStyleData(iconEnabledColor: Colors.blue),
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (error, stackTrace) => SizedBox.shrink(),
    );
  }
}
