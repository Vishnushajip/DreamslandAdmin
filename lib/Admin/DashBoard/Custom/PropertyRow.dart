// ignore_for_file: unused_result

import 'package:dladmin/Admin/AddProperty/Providers/property_delete_provider.dart';
import 'package:dladmin/Admin/Update/Pages/UpdateBasic_Details.dart';
import 'package:dladmin/Admin/Update/Pages/Update_More_Details.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyRow extends ConsumerWidget {
  final AgentProperty property;
  final String? agent;
  final bool isMobile;
  final bool isTablet;

  const PropertyRow({
    super.key,
    required this.property,
    this.agent,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double fontSize =
        isMobile
            ? 12
            : isTablet
            ? 14
            : 16;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    ref.refresh(agentUsernamesProvider);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => updatePropertyFormPage(property: property),
                      ),
                    );
                  },
                  child: Text(
                    'Property ID: ${property.propertyId}',
                    style: GoogleFonts.nunito(
                      fontSize: fontSize + 1,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            title: Text(
                              'Confirm Deletion',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete this property?',
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.nunito(),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: Text(
                                  'Delete',
                                  style: GoogleFonts.nunito(color: Colors.red),
                                ),
                                onPressed: () {
                                  ref
                                      .read(
                                        propertyDeleteNotifierProvider.notifier,
                                      )
                                      .deleteProperty(
                                        imageurl: property.images,
                                        whatsapp: property.whatsappNumber,
                                        propertyId: property.id,
                                        id: property.propertyId,
                                        ownerName: property.ownerName,
                                        phoneNumber: property.phoneNumber,
                                        deletedBy: property.agent.toString(),
                                      );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                    );
                  },

                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Property',
                ),
              ],
            ),

            Text(
              'Name: ${property.name}',
              style: GoogleFonts.nunito(fontSize: fontSize),
            ),
            SizedBox(height: 5),
            Text(
              'Agent: $agent',
              style: GoogleFonts.nunito(fontSize: fontSize),
            ),
            SizedBox(height: 5),
            Text(
              'Status: ${property.status}',
              style: GoogleFonts.nunito(
                fontSize: fontSize,
                color: property.status == 'Sold' ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Price: ${formatIndianCurrency(property.price)}',
              style: GoogleFonts.nunito(fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }

  String formatIndianCurrency(num price) {
    if (price >= 10000000) {
      return 'INR${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return 'INR${(price / 100000).toStringAsFixed(2)} Lakh';
    }
    return 'INR${price.toStringAsFixed(2)}';
  }
}
