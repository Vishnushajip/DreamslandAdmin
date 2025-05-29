import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LabeledFieldWrapper extends StatelessWidget {
  final String label;
  final Widget field;

  const LabeledFieldWrapper({
    super.key,
    required this.label,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(),
                ),
                const SizedBox(height: 6),
                field,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(),
                    ),
                  ),
                ),
                Expanded(child: field),
              ],
            ),
    );
  }
}
