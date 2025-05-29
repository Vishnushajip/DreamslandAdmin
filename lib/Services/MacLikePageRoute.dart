import 'package:flutter/material.dart';

class MacLikePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  MacLikePageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            final scaleTween = Tween<double>(begin: 0.6, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOutBack));
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOutCubic));

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              alignment: Alignment.bottomRight,
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}
