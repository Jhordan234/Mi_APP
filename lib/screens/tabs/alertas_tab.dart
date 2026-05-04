import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class AlertasTab extends StatelessWidget {
  final double temperatura, humedad, co2;

  const AlertasTab({super.key,
    required this.temperatura,
    required this.humedad,
    required this.co2,
  });

  @override
  Widget build(BuildContext context) {
    final alertas = _generarAlertas();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HISTORIAL DE ALERTAS',
            style: GoogleFonts.orbitron(
              fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text('MONITOREO EN TIEMPO REAL',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9, color: Colors.white24, letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),

          // Resumen
          Row(children: [
            _chipResumen(
              alertas.where((a) => a['nivel'] == 'CRÍTICO').length.toString(),
              'Críticos', AppTheme.colorError),
            const SizedBox(width: 10),
            _chipResumen(
              alertas.where((a) => a['nivel'] == 'ALERTA').length.toString(),
              'Alertas', AppTheme.colorSecundario),
            const SizedBox(width: 10),
            _chipResumen(
              alertas.where((a) => a['nivel'] == 'OK').length.toString(),
              'Nominales', AppTheme.colorTerciario),
          ]),
          const SizedBox(height: 20),

          if (alertas.where((a) => a['nivel'] != 'OK').isEmpty)
            _pantallaOK()
          else ...[
            Text('EVENTOS ACTIVOS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10, color: Colors.white38,
                fontWeight: FontWeight.bold, letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            ...alertas.where((a) => a['nivel'] != 'OK')
                .map(_tarjetaAlerta).toList(),
          ],

          const SizedBox(height: 20),
          Text('ESTADO GENERAL DE SENSORES',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10, color: Colors.white38,
              fontWeight: FontWeight.bold, letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          ...alertas.map(_filaEstado).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generarAlertas() {
    return [
      {
        'icono': Icons.thermostat,
        'titulo': 'TEMPERATURA',
        'sensor': 'DHT22',
        'valor': '${temperatura.toStringAsFixed(1)}°C',
        'umbral': 'Umbral: 35°C',
        'nivel': temperatura > 35 ? 'CRÍTICO' : 'OK',
        'color': temperatura > 35 ? AppTheme.colorError : AppTheme.colorTerciario,
      },
      {
        'icono': Icons.water_drop_outlined,
        'titulo': 'HUMEDAD',
        'sensor': 'DHT22',
        'valor': '${humedad.toStringAsFixed(1)}%',
        'umbral': 'Umbral: 80%',
        'nivel': humedad > 80 ? 'ALERTA' : 'OK',
        'color': humedad > 80 ? AppTheme.colorSecundario : AppTheme.colorTerciario,
      },
      {
        'icono': Icons.air,
        'titulo': 'CO₂',
        'sensor': 'DFRobot MG-811',
        'valor': '${co2.toStringAsFixed(0)} ppm',
        'umbral': 'Umbral: 1000 ppm',
        'nivel': co2 > 1500 ? 'CRÍTICO' : co2 > 1000 ? 'ALERTA' : 'OK',
        'color': co2 > 1500
            ? AppTheme.colorError
            : co2 > 1000
              ? AppTheme.colorSecundario
              : AppTheme.colorTerciario,
      },
    ];
  }

  Widget _tarjetaAlerta(Map<String, dynamic> alerta) {
    final color = alerta['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(alerta['icono'] as IconData, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alerta['titulo'] as String,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
            Text('${alerta['sensor']} — ${alerta['umbral']}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9, color: Colors.white38,
              ),
            ),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(alerta['valor'] as String,
            style: GoogleFonts.orbitron(
              fontSize: 16, fontWeight: FontWeight.w900, color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(alerta['nivel'] as String,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9, color: color, fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _filaEstado(Map<String, dynamic> alerta) {
    final color = alerta['color'] as Color;
    final esOk = alerta['nivel'] == 'OK';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficieAlta,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(children: [
        Icon(alerta['icono'] as IconData, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(alerta['titulo'] as String,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold,
          ),
        )),
        Text(alerta['valor'] as String,
          style: GoogleFonts.orbitron(fontSize: 12, color: color)),
        const SizedBox(width: 12),
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: esOk ? AppTheme.colorTerciario : color,
            shape: BoxShape.circle,
          ),
        ),
      ]),
    );
  }

  Widget _chipResumen(String numero, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.colorSuperficieAlta,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text(numero,
            style: GoogleFonts.orbitron(
              fontSize: 26, fontWeight: FontWeight.w900, color: color,
            ),
          ),
          Text(label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9, color: Colors.white38,
              fontWeight: FontWeight.bold, letterSpacing: 1,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _pantallaOK() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Icon(Icons.verified_user_outlined,
            color: AppTheme.colorTerciario, size: 64),
          const SizedBox(height: 16),
          Text('TODOS LOS SISTEMAS NOMINALES',
            style: GoogleFonts.orbitron(
              fontSize: 12, color: AppTheme.colorTerciario, letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text('Sin alertas activas en este momento',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10, color: Colors.white24,
            ),
          ),
        ]),
      ),
    );
  }
}