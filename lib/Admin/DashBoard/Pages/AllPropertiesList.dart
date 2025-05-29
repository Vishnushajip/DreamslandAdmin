// ignore_for_file: unused_result

import 'package:dladmin/Admin/AddProperty/Basic_Details.dart';
import 'package:dladmin/Admin/DashBoard/Custom/PropertyRow.dart';
import 'package:dladmin/Admin/DashBoard/Providers/admin_Fetch_All.dart';
import 'package:dladmin/Services/Providers/property_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllPropertiesList extends ConsumerWidget {
  const AllPropertiesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(adminallpropertyprovider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 800;
    final isTablet = screenWidth > 800 && screenWidth <= 1200;

    return propertiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (properties) {
        if (properties.isEmpty) {
          return const Center(child: Text('No properties found'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      ref.refresh(propertyFormProvider);
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('username');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PropertyFormPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Add Property',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return PropertyRow(
                    agent: property.agent,
                    property: property,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
