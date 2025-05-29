import 'package:flutter/material.dart';

class FloatingPopupButtons extends StatelessWidget {
  final List<FloatingActionButton> buttons;
  final double bottomPadding;
  final double rightPadding;

  const FloatingPopupButtons({
    super.key,
    required this.buttons,
    this.bottomPadding = 100,
    this.rightPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottomPadding,
      right: rightPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: buttons
            .map((btn) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: btn,
                ))
            .toList(),
      ),
    );
  }
}
