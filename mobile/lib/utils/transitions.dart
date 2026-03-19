import 'package:flutter/material.dart';

/// A slide-up + fade page route transition (250ms, easeInOut).
///
/// Used across the app for detail screen navigation.
Route<T> slideUpRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.1), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
