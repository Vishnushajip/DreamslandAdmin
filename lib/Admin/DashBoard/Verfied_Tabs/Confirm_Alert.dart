import 'dart:convert';
import 'package:dladmin/Admin/DashBoard/Verfied_Tabs/verfied_docs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ConfirmDialog extends StatefulWidget {
  final String title;
  final String status;
  final String content;
  final String response;
  final String buttonText;
  final Color buttonColor;
  final Color titlecolor;
  final Function(String remarks) onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.status,
    required this.response,
    required this.titlecolor,
    required this.content,
    required this.buttonText,
    required this.buttonColor,
    required this.onConfirm,
  });

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  final TextEditingController _remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      title: Center(
        child: Text(widget.title,
            style: GoogleFonts.montserrat(
                color: widget.titlecolor, fontSize: isMobile ? 15 : 20)),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 400,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(widget.content,
                  style: GoogleFonts.montserrat(
                      color: Colors.grey.shade700,
                      fontSize: isMobile ? 10 : 16)),
              const SizedBox(height: 10),
              TextField(
                controller: _remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter rejection remarks",
                  prefix: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      CupertinoIcons.pencil,
                      color: Color.fromARGB(255, 17, 70, 114),
                      size: 20,
                    ),
                  ),hintStyle: GoogleFonts.nunito(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:  BorderSide(
                      color: Colors.grey.shade500,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:  BorderSide(
                      color: Colors.grey.shade500,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:  BorderSide(
                      color: Colors.grey.shade500,
                      width: 0.5,
                    ),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                ),
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            widget.onConfirm(_remarksController.text.trim());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.response),
                backgroundColor: widget.buttonColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          child: Text(widget.buttonText,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

Future<void> updateRemarks(String propertyId, String remarks) async {
  final url = Uri.parse('https://api-fxz7qcfy4q-uc.a.run.app/updateRemarks');

  final response = await http.patch(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'propertyId': propertyId, 'remarks': remarks}),
  );

  if (response.statusCode != 200) {
    debugPrint("Failed to update remarks: ${response.body}");
  }
}

class DocumentHandler extends ConsumerWidget {
  const DocumentHandler({super.key});

  void handleAccept(BuildContext context, document, WidgetRef ref, status) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        status: "Verified By Admin",
        response: "Verified Successfully ✅",
        titlecolor: Colors.green,
        title: 'Confirm Property Verification',
        content:
            'Are you sure you want to mark this property as "Verified by Admin"?This action will approve the property for further processing',
        buttonText: 'Accept',
        buttonColor: Colors.green,
        onConfirm: (_) async {
          await ref
              .read(propertyProvider(status).notifier)
              .approveProperty(document.propertyId, ref);
        },
      ),
    );
  }

  void handleReject(BuildContext context, document, WidgetRef ref, status) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        status: "Rejected By Admin",
        response: "Rejected Successfully ❌",
        titlecolor: Colors.red,
        title: 'Confirm Rejection',
        content:
            'Are you sure you want to mark this property as "Rejected by Admin"?This action will Reject the property for further processing',
        buttonText: 'Reject',
        buttonColor: Colors.red,
        onConfirm: (remarks) async {
          await ref
              .read(propertyProvider(status).notifier)
              .rejectProperty(document.propertyId, ref);
          await updateRemarks(document.id, remarks);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
