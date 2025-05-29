import 'package:dladmin/Admin/AddProperty/Providers/property_delete_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class admindelete extends ConsumerWidget {
  final String propertyId;
  final String ownerName;
  final String phoneNumber;
  final String deletedBy;
  final String id;
  final String whatsapp;
  final List<String> imageurl;

  const admindelete({
    super.key,
    required this.propertyId,
    required this.ownerName,
    required this.phoneNumber,
    required this.deletedBy,
    required this.id,
    required this.whatsapp,
    required this.imageurl,
  });

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              side: BorderSide.none, borderRadius: BorderRadius.circular(5)),
          title: Center(
            child: Text(
              'Confirm Deletion',
              style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          content: Text(
            'Are you sure you want to delete this property?',
            style: GoogleFonts.nunito(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 12),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    side: BorderSide(color: Colors.grey.withOpacity(0.6)),
                    foregroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.nunito(color: Colors.black),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete,
                      size: 18, color: Colors.redAccent),
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    side: BorderSide(color: Colors.red.withOpacity(0.6)),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  label: Text(
                    "Delete",
                    style: GoogleFonts.nunito(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (isConfirmed ?? false) {
      ref.read(propertyDeleteNotifierProvider.notifier).deleteProperty(
            imageurl: imageurl,
            propertyId: propertyId,
            ownerName: ownerName,
            phoneNumber: phoneNumber,
            deletedBy: deletedBy,
            id: id,
            whatsapp: whatsapp,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleteState = ref.watch(propertyDeleteNotifierProvider);

    final isLoading = deleteState[propertyId] ?? false;

    return IconButton(
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.delete, size: 18, color: Colors.redAccent),
      onPressed:
          isLoading ? null : () => _showDeleteConfirmationDialog(context, ref),
    );
  }
}
