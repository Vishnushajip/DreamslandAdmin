import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';

class ReusableDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final String? initialValue;
  final Function(String?)? onChanged;
  final String? errorText;
  final bool isRequired;
  final EdgeInsetsGeometry? padding;
  final double? dropdownWidth;
  final double? dropdownHeight;

  const ReusableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.isRequired = false,
    this.padding,
    this.dropdownWidth,
    this.dropdownHeight,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: errorText != null ? Colors.red : Colors.grey.shade300,
        width: 1.5,
      ),
    );

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (isRequired)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '*',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          DropdownButtonFormField2<String>(
            isExpanded: true,
            value: value ?? initialValue,
            hint: Text(
              hint,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade900,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
              ),
              errorBorder: border.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: border.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              errorText: errorText,
              errorStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red,
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              elevation: 4,
              maxHeight: 200,
              width: 300,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            iconStyleData: IconStyleData(
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              iconEnabledColor: Colors.grey.shade600,
              iconSize: 24,
            ),
            buttonStyleData: ButtonStyleData(
              height: dropdownHeight ?? 48,
              width: dropdownWidth ?? double.infinity,
              padding: const EdgeInsets.only(right: 8),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                FocusScope.of(context).unfocus();
              }
            },
          ),
        ],
      ),
    );
  }
}
