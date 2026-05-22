import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Importamos la nueva pantalla principal que organiza las pestañas
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<Offset> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configuración de la animación de flotación sutil del robotito
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.03), 
    ).animate(CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut));

    // Temporizador de 3 segundos antes de entrar al sistema
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Navegación hacia la nueva estructura de pestañas (HomeScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Fondo con resplandor radial neón para estilo Synthwave
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ROBOTITO CARGA
                SlideTransition(
                  position: _floatingAnimation,
                  child: Image.asset(
                    'assets/images/robotito_carga2.png',
                    height: 250,
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                
                const SizedBox(height: 50),

                // Círculo de Carga Neón
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 2,
                  ),
                ),

                const SizedBox(height: 40),

                // TEXTO DE ESTADO CON ESTILO ORBITRON
                Text(
                  'ACCESO AUTORIZADO',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: theme.colorScheme.primary.withOpacity(0.7),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'SINCRONIZANDO RED NEURAL DE SENSORES...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}