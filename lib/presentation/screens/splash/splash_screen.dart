import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Pantalla de arranque que restaura la sesión mientras carga.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/kylora_banner.png',
              width: 260,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}