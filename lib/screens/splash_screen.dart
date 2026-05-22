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
  late Animation<double> _floatingAnim;

  @override
  void initState() {
    super.initState();

    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );

    _animacionOpacidad = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controlador,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // Animación flotante de la imagen (loop separado)
    _floatingAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controlador, curve: Curves.easeInOut),
    );

    _controlador.forward();

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      await _controlador.animateTo(0.5,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOut);
    });

    Future.delayed(const Duration(seconds: 4), () async {
      if (!mounted) return;
      await _controlador.animateTo(1.0,
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeInOut);

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
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controlador,
        builder: (context, child) {
          return Stack(
            children: [
              // ── Fondo radial ──────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.08),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),

              // ── Contenido centrado ────────────────────────────────────────
              Center(
                child: Opacity(
                  opacity: _animacionOpacidad.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // ── IMAGEN con flotación ──────────────────────────────
                      Transform.translate(
                        offset: Offset(0, _floatingAnim.value),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                                blurRadius: 50,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/robotito_carga.png',
                            height: 220,
                            width: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.sensors,
                              color: theme.colorScheme.primary,
                              size: 80,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── TÍTULO: CENTRAL (grande) ──────────────────────────
                      Text(
                        'CENTRAL',
                        style: GoogleFonts.orbitron(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          letterSpacing: 8,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: theme.colorScheme.primary.withOpacity(0.8),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),

                      // ── SUBTÍTULO: DE MONITOREO (pequeño) ────────────────
                      Text(
                        'DE MONITOREO',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                          letterSpacing: 6,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              color: theme.colorScheme.primary.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Dot + subtag ──────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.secondary,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'INTERFAZ IoT NEURAL v4.02',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.6),
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // ── Barra de progreso ─────────────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'INICIANDO SISTEMA',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  '${(_controlador.value * 100).toInt()}%',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: _controlador.value,
                              backgroundColor: theme.colorScheme.surface,
                              color: theme.colorScheme.primary,
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Info chips inferiores ─────────────────────────────
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
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary.withOpacity(0.6),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}