import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga>
    with SingleTickerProviderStateMixin {
  late AnimationController _controlador;
  late Animation<double> _animacionOpacidad;

  @override
  void initState() {
    super.initState();

    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );

    _animacionOpacidad = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controlador, curve: const Interval(0.0, 0.2, curve: Curves.easeIn)),
    );

    _controlador.forward();

    // 🔵 0% → 50%
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      await _controlador.animateTo(0.5,
          duration: const Duration(milliseconds: 1500), curve: Curves.easeOut);
    });

    // 🔵 50% → 100%
    Future.delayed(const Duration(seconds: 4), () async {
      if (!mounted) return;
      await _controlador.animateTo(1.0,
          duration: const Duration(milliseconds: 2000), curve: Curves.easeInOut);

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el tema actual para no repetir colores
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controlador,
        builder: (context, child) {
          return Stack(
            children: [
              // Fondo con resplandor radial corregido
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.05),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
              Center(
                child: Opacity(
                  opacity: _animacionOpacidad.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono con Neomorfismo / Resplandor
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.sensors,
                          color: theme.colorScheme.primary,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Título con fuente Orbitron para máximo estilo Sci-Fi
                      Text(
                        'SYNTH_MONITOR',
                        style: GoogleFonts.orbitron(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                              color: theme.colorScheme.primary.withOpacity(0.8),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Subtítulo con letra monoespaciada
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary, // Cambiado de terciario a secundario
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: theme.colorScheme.secondary, blurRadius: 4)
                              ]
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'INTERFAZ IoT NEURAL v4.02',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                      
                      // Barra de progreso y porcentaje
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'INICIANDO SISTEMA',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  '${(_controlador.value * 100).toInt()}%',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: _controlador.value,
                              backgroundColor: theme.colorScheme.surface,
                              color: theme.colorScheme.primary,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Datos técnicos inferiores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _infoChip(context, 'ESTADO RED', 'SEGURO'),
                          const SizedBox(width: 40),
                          _infoChip(context, 'LATENCIA', '4.2 MS'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

Widget _infoChip(BuildContext context, String etiqueta, String valor) {
  final theme = Theme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        etiqueta,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12, // Subimos el tamaño
          fontWeight: FontWeight.w800, // Más negrita
          color: theme.colorScheme.primary.withOpacity(0.6), // Cyan suave
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 4), // Un pequeño espacio
      Text(
        valor,
        style: GoogleFonts.orbitron( // Cambiamos a Orbitron para que se vea futurista
          fontSize: 16, // Más grande
          color: Colors.white, // Blanco puro para que resalte sobre el cyan
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
}