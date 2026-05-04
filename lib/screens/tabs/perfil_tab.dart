import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  String nombre = '--';
  String correo = '--';
  String dni    = '--';
  String rol    = '--';
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          nombre  = doc['nombre']  ?? '--';
          correo  = doc['correo']  ?? user.email ?? '--';
          dni     = doc['dni']     ?? '--';
          rol     = doc['rol']     ?? '--';
          cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.colorPrimario),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar y nombre
          Center(
            child: Column(children: [
              const SizedBox(height: 10),
              Stack(children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.colorPrimario, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.colorPrimario.withOpacity(0.25),
                        blurRadius: 20, spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppTheme.colorSuperficieAlta,
                    child: Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : 'O',
                      style: GoogleFonts.orbitron(
                        fontSize: 36, fontWeight: FontWeight.w900,
                        color: AppTheme.colorPrimario,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4, right: 4,
                  child: Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(
                      color: AppTheme.colorTerciario,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Text(nombre.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 20, fontWeight: FontWeight.w900,
                  color: AppTheme.colorPrimario,
                  shadows: [Shadow(
                    color: AppTheme.colorPrimario.withOpacity(0.5), blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 4),
              Text('RED ESTABLE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9, color: AppTheme.colorTerciario,
                  letterSpacing: 2, fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.colorTerciario.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.colorTerciario.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.colorTerciario, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text('ESTADO: ACTIVO',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10, color: AppTheme.colorTerciario,
                      fontWeight: FontWeight.bold, letterSpacing: 1,
                    ),
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // Datos del operador
          _tituloSeccion('CONFIGURACIÓN DEL OPERADOR'),
          const SizedBox(height: 10),
          _tarjetaDatos([
            ['NOMBRE COMPLETO', nombre],
            ['CORREO ELECTRÓNICO', correo],
            ['DNI / IDENTIFICACIÓN', dni],
            ['ROL EN EL SISTEMA', rol.toUpperCase()],
          ]),

          const SizedBox(height: 20),

          // Info del sistema
          _tituloSeccion('INFORMACIÓN DEL SISTEMA'),
          const SizedBox(height: 10),
          _tarjetaDatos([
            ['PROYECTO', 'IoT-Ejemplo'],
            ['DISPOSITIVO', 'ESP32-C3 Super Mini'],
            ['BASE DE DATOS', 'Firebase Realtime DB'],
            ['VERSIÓN APP', 'v1.0.0'],
            ['UPTIME', '99.9%'],
          ]),

          const SizedBox(height: 24),

          // Log de acceso
          _tituloSeccion('REGISTRO DE ACCESO'),
          const SizedBox(height: 10),
          _tarjetaLog(),

          const SizedBox(height: 24),

          // Botón cerrar sesión
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.colorError.withOpacity(0.3)),
            ),
            child: TextButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, color: AppTheme.colorError, size: 18),
              label: Text('CERRAR SESIÓN',
                style: GoogleFonts.orbitron(
                  fontSize: 12, color: AppTheme.colorError,
                  fontWeight: FontWeight.w900, letterSpacing: 1.5,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppTheme.colorError.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _tarjetaDatos(List<List<String>> campos) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficieAlta,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: campos.asMap().entries.map((e) {
          final ultimo = e.key == campos.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(
                color: ultimo ? Colors.transparent : Colors.white.withOpacity(0.04),
              )),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.value[0],
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11, color: Colors.white38,
                  ),
                ),
                Flexible(
                  child: Text(e.value[1],
                    textAlign: TextAlign.right,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11, color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _tarjetaLog() {
    final logs = [
      {'icono': Icons.check_circle_outline, 'texto': 'Inicio de sesión exitoso',
       'sub': 'Firebase Auth', 'color': AppTheme.colorTerciario},
      {'icono': Icons.sync, 'texto': 'Sincronización Firebase',
       'sub': 'Realtime Database', 'color': AppTheme.colorPrimario},
      {'icono': Icons.sensors, 'texto': 'Datos ESP32 recibidos',
       'sub': 'esp32_1/lecturas', 'color': AppTheme.colorSecundario},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficieAlta,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: logs.asMap().entries.map((e) {
          final color = e.value['color'] as Color;
          final ultimo = e.key == logs.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(
                color: ultimo ? Colors.transparent : Colors.white.withOpacity(0.04),
              )),
            ),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.value['texto'] as String,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(e.value['sub'] as String,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9, color: Colors.white24,
                    ),
                  ),
                ],
              )),
              Icon(e.value['icono'] as IconData, color: color, size: 16),
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _tituloSeccion(String texto) {
    return Text(texto,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 10, fontWeight: FontWeight.bold,
        color: Colors.white38, letterSpacing: 1.5,
      ),
    );
  }
}