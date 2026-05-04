import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Fondos más oscuros para generar contraste (True Black)
  static const Color colorFondo = Color(0xFF08090A);
  static const Color colorSuperficie = Color(0xFF121417);

  // 2. Colores de acento con más saturación ("Glow")
  static const Color colorPrimario = Color(0xFF00F2FF); // Cian eléctrico
  static const Color colorPrimarioBrillante = Color(0xFF94FBFF);
  static const Color colorSecundario = Color(0xFFBD93F9);

  // 3. Textos con blanco puro o gris muy claro
  static const Color colorTexto = Color(0xFFFFFFFF);
  static const Color colorTextoSecundario = Color(
    0xFFADF9FF,
  ); // Un cian muy claro, casi blanco

  //4. lo que me dio claude
  static const Color colorTerciario = Color(0xFFE9FFBA);
  static const Color colorError = Color(0xFFFF716C);
  static const Color colorSuperficieAlta = Color(0xFF1E1F26);

  static ThemeData tema() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colorFondo,
      colorScheme: const ColorScheme.dark(
        primary: colorPrimario,
        onPrimary: Colors.black,
        secondary: colorSecundario,
        surface: colorSuperficie,
        error: Color(0xFFFF5555),
      ),

      // Optimizamos las fuentes para que se sientan "tech"
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          // Fuente más "Sci-Fi" para títulos grandes
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: colorPrimario,
          letterSpacing: 2.0,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: colorTexto,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(fontSize: 18, color: colorTexto),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          color: colorTextoSecundario,
        ),
        // Y en el textTheme, ajusta el bodyMedium o crea un estilo específico:
        labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 13, // Subimos de 10 a 13
          color: colorTextoSecundario.withOpacity(0.9),
          letterSpacing: 2,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
