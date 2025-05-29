import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> changePassword(BuildContext context, String agentId) async {
  final TextEditingController passwordController = TextEditingController();

  final bool? shouldChange = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Change Password',
        style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
            hintText: 'Enter New Password', hintStyle: GoogleFonts.nunito()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: GoogleFonts.nunito(),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Change', style: GoogleFonts.nunito(color: Colors.blue)),
        ),
      ],
    ),
  );

  if (shouldChange == true && passwordController.text.isNotEmpty) {
    try {
      await FirebaseFirestore.instance.collection('admin').doc(agentId).update({
        'Password': passwordController.text,
      });

      Fluttertoast.showToast(
        msg: "Password changed successfully.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to change password: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}

Future<void> showUsernamePassword(BuildContext context, String agentId) async {
  try {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('admin').doc(agentId).get();
    final agentData = docSnapshot.data();

    if (agentData == null ||
        !agentData.containsKey('Username') ||
        !agentData.containsKey('Password')) {
      Fluttertoast.showToast(
        msg: "No Username or Password found.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final String username = agentData['Username'] ?? 'No Username Found';
    final String password = agentData['Password'] ?? 'No Password Found';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Username & Password',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Username: $username',
                    style: GoogleFonts.nunito(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: username));
                    Fluttertoast.showToast(
                      msg: "Username copied to clipboard.",
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Password: $password',
                    style: GoogleFonts.nunito(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: password));
                    Fluttertoast.showToast(
                      msg: "Password copied to clipboard.",
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.nunito(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Failed to fetch data: $e",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
