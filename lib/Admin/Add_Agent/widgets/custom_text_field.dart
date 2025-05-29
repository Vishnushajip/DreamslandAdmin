import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onChanged;
  final int maxLines;
  final bool isNumber;
  final bool obscureText;
  final IconData? icon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    this.icon,
    this.isNumber = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              boxShadow:
                  hasFocus
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                      : [],
            ),
            child: TextFormField(
              initialValue: value,
              maxLines: obscureText ? 1 : maxLines,
              obscureText: obscureText,
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              inputFormatters:
                  isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: icon != null ? Icon(icon) : null,
                hintText: label,
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade400, // Slight blue-grey tint
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade500, // Slightly stronger
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
