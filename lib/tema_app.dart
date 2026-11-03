import 'package:flutter/material.dart';

class TemaApp {
  TemaApp._();

  static const Color preto = Color(0xFF000000);
  static const Color superficie = Color(0xFF0D0D0D);
  static const Color verde = Color(0xFF00FF66);

  static ThemeData get escuro {
    const esquema = ColorScheme.dark(
      primary: verde,
      onPrimary: preto,
      secondary: verde,
      onSecondary: preto,
      surface: superficie,
      onSurface: Colors.white,
      error: Color(0xFFFF5252),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: esquema,
      scaffoldBackgroundColor: preto,
      appBarTheme: const AppBarTheme(
        backgroundColor: preto,
        foregroundColor: verde,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x3300FF66)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: verde,
          foregroundColor: preto,
          disabledBackgroundColor: const Color(0xFF1A1A1A),
          disabledForegroundColor: Colors.white38,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: verde,
          side: const BorderSide(color: verde),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: verde),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: verde,
        foregroundColor: preto,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: superficie,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: superficie),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: verde),
    );
  }
}
