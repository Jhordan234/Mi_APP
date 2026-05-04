import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';

class DashboardTab extends StatelessWidget {
  final double tempActual, humActual, co2Actual, voltActual;
  final List<double> histTemp, histHum, histCo2, histVolt;
  final List<String> histTime;

  const DashboardTab({super.key,
    required this.tempActual, required this.humActual,
    required this.co2Actual, required this.voltActual,
    required this.histTemp, required this.histHum,
    required this.histCo2, required this.histVolt,
    required this.histTime,
  });

  // Cálculos del historial
  double get _maxTemp => histTemp.isEmpty ? 0 : histTemp.reduce((a, b) => a > b ? a : b);
  double get _minTemp => histTemp.isEmpty ? 0 : histTemp.reduce((a, b) => a < b ? a : b);
  double get _maxHum  => histHum.isEmpty  ? 0 : histHum.reduce((a, b) => a > b ? a : b);
  double get _minHum  => histHum.isEmpty  ? 0 : histHum.reduce((a, b) => a < b ? a : b);
  double get _maxCo2  => histCo2.isEmpty  ? 0 : histCo2.reduce((a, b) => a > b ? a : b);
  double get _minCo2  => histCo2.isEmpty  ? 0 : histCo2.reduce((a, b) => a < b ? a : b);
  double get _promTemp => histTemp.isEmpty ? 0 : histTemp.reduce((a, b) => a + b) / histTemp.length;
  double get _promHum  => histHum.isEmpty  ? 0 : histHum.reduce((a, b) => a + b) / histHum.length;
  double get _promCo2  => histCo2.isEmpty  ? 0 : histCo2.reduce((a, b) => a + b) / histCo2.length;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _encabezado(isSmallScreen),
          SizedBox(height: isSmallScreen ? 10 : 16),
          _indicadoresTiempoReal(isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 20),
          _titulo('ANÁLISIS DE PICOS — SESIÓN ACTUAL', isSmallScreen),
          SizedBox(height: isSmallScreen ? 6 : 10),
          _tarjetaPicos(isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 20),
          _titulo('MULTI-LÍNEA — TEMP vs HUM', isSmallScreen),
          SizedBox(height: isSmallScreen ? 6 : 8),
          _graficaMultiLinea(isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 20),
          _titulo('COMPARATIVA — HUM vs CO₂', isSmallScreen),
          SizedBox(height: isSmallScreen ? 6 : 8),
          _graficaBarrasComparativa(isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 20),
          _titulo('FLUCTUACIÓN — CO₂ PPM', isSmallScreen),
          SizedBox(height: isSmallScreen ? 6 : 8),
          _graficaLinea(histCo2, AppTheme.colorError, alto: isSmallScreen ? 140 : 170),
          SizedBox(height: isSmallScreen ? 12 : 20),
          _titulo('OSCILACIÓN — VOLTAJE V', isSmallScreen),
          SizedBox(height: isSmallScreen ? 6 : 8),
          _graficaLinea(histVolt, AppTheme.colorTerciario, alto: isSmallScreen ? 140 : 170),
          SizedBox(height: isSmallScreen ? 12 : 20),
        ],
      ),
    );
  }

  // ✅ ENCABEZADO RESPONSIVE
  Widget _encabezado(bool compact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ANÁLISIS COMPARATIVO',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: compact ? 8 : 10,
                  color: AppTheme.colorPrimario,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('CLUSTER_ALPHA',
                  style: GoogleFonts.orbitron(
                    fontSize: compact ? 18 : 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: compact ? 6 : 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _badge('EN VIVO', AppTheme.colorPrimario, compact),
            SizedBox(width: compact ? 2 : 4),
            _badge('ESTABLE', AppTheme.colorTerciario, compact),
          ],
        ),
      ],
    );
  }

  Widget _badge(String texto, Color color, bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(texto,
        style: GoogleFonts.spaceGrotesk(
          fontSize: compact ? 7 : 8,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ✅ INDICADORES TIEMPO REAL RESPONSIVE
  Widget _indicadoresTiempoReal(bool compact) {
    final items = [
      {'label': 'TEMP', 'valor': '${tempActual.toStringAsFixed(1)}°C', 'color': AppTheme.colorPrimario, 'icon': Icons.thermostat},
      {'label': 'HUM',  'valor': '${humActual.toStringAsFixed(0)}%',   'color': AppTheme.colorSecundario, 'icon': Icons.water_drop},
      {'label': 'CO₂',  'valor': '${co2Actual.toStringAsFixed(0)}',    'color': AppTheme.colorError, 'icon': Icons.co2},
      {'label': 'VOLT', 'valor': '${voltActual.toStringAsFixed(2)}V',  'color': AppTheme.colorTerciario, 'icon': Icons.bolt},
    ];

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.colorSuperficieAlta, AppTheme.colorSuperficie],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.online_prediction, color: AppTheme.colorPrimario, size: compact ? 10 : 14),
              SizedBox(width: compact ? 4 : 6),
              Text('MONITOREO EN VIVO',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: compact ? 7 : 9,
                  color: AppTheme.colorPrimario,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _badge('2s', AppTheme.colorPrimario, compact),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          Row(
            children: items.map((item) {
              final color = item['color'] as Color;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
                  padding: EdgeInsets.symmetric(
                    vertical: compact ? 8 : 12,
                    horizontal: compact ? 2 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(compact ? 8 : 12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(item['icon'] as IconData, color: color, size: compact ? 12 : 16),
                      SizedBox(height: compact ? 4 : 6),
                      FittedBox(
                        child: Text(item['label'] as String,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: compact ? 6 : 8,
                            color: color.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 2 : 4),
                      FittedBox(
                        child: Text(item['valor'] as String,
                          style: GoogleFonts.orbitron(
                            fontSize: compact ? 10 : 13,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ✅ TARJETA PICOS RESPONSIVE
  Widget _tarjetaPicos(bool compact) {
    final sensores = [
      {
        'nombre': 'TEMPERATURA',
        'color': AppTheme.colorPrimario,
        'actual': '${tempActual.toStringAsFixed(1)}°C',
        'max': '${_maxTemp.toStringAsFixed(1)}°C',
        'min': '${_minTemp.toStringAsFixed(1)}°C',
        'prom': '${_promTemp.toStringAsFixed(1)}°C',
      },
      {
        'nombre': 'HUMEDAD',
        'color': AppTheme.colorSecundario,
        'actual': '${humActual.toStringAsFixed(0)}%',
        'max': '${_maxHum.toStringAsFixed(1)}%',
        'min': '${_minHum.toStringAsFixed(1)}%',
        'prom': '${_promHum.toStringAsFixed(1)}%',
      },
      {
        'nombre': 'CO₂',
        'color': AppTheme.colorError,
        'actual': '${co2Actual.toStringAsFixed(0)}',
        'max': '${_maxCo2.toStringAsFixed(0)} ppm',
        'min': '${_minCo2.toStringAsFixed(0)} ppm',
        'prom': '${_promCo2.toStringAsFixed(0)} ppm',
      },
    ];

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficieAlta,
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: sensores.map((s) {
          final color = s['color'] as Color;
          return Padding(
            padding: EdgeInsets.only(bottom: compact ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + valor actual
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s['nombre'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: compact ? 9 : 10,
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 6 : 8,
                        vertical: compact ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: color, size: compact ? 5 : 6),
                          SizedBox(width: compact ? 2 : 4),
                          Text('AHORA ${s['actual']}',
                            style: GoogleFonts.orbitron(
                              fontSize: compact ? 7 : 9,
                              color: color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 6 : 8),
                // Métricas MÁX/MÍN/PROM
                Row(children: [
                  Expanded(child: _indicadorPico('MÁX', s['max'] as String, color, Icons.arrow_upward, compact)),
                  SizedBox(width: compact ? 4 : 6),
                  Expanded(child: _indicadorPico('MÍN', s['min'] as String, color.withOpacity(0.5), Icons.arrow_downward, compact)),
                  SizedBox(width: compact ? 4 : 6),
                  Expanded(child: _indicadorPico('PROM', s['prom'] as String, Colors.white38, Icons.remove, compact)),
                ]),
                SizedBox(height: compact ? 6 : 10),
                Divider(color: Colors.white.withOpacity(0.04), height: 1),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _indicadorPico(String etiqueta, String valor, Color color, IconData icono, bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: compact ? 6 : 8,
        horizontal: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: color, size: compact ? 8 : 10),
          SizedBox(width: compact ? 2 : 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(etiqueta,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: compact ? 6 : 7,
                    color: Colors.white24,
                    letterSpacing: 0.5,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(valor,
                    style: GoogleFonts.orbitron(
                      fontSize: compact ? 8 : 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _graficaMultiLinea(bool compact) {
    if (histTemp.isEmpty || histHum.isEmpty) return _sinDatos(compact);

    final maxVal = [
      histTemp.reduce((a, b) => a > b ? a : b),
      histHum.reduce((a, b) => a > b ? a : b),
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      height: compact ? 150 : 200,
      padding: EdgeInsets.fromLTRB(4, compact ? 8 : 12, compact ? 8 : 12, 8),
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficie,
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _leyenda('Temp.', AppTheme.colorPrimario, compact),
            SizedBox(width: compact ? 8 : 12),
            _leyenda('Hum.', AppTheme.colorSecundario, compact),
          ]),
          SizedBox(height: compact ? 4 : 8),
          Expanded(
            child: LineChart(LineChartData(
              maxY: maxVal * 1.2,
              minY: 0,
              gridData: FlGridData(
                show: true, drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: Colors.white.withOpacity(0.04), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: compact ? 22 : 28,
                  getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: compact ? 7 : 8,
                      color: Colors.white24,
                    )),
                )),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, interval: 2,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= histTime.length) return const SizedBox();
                    return Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(histTime[i],
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: compact ? 6 : 7,
                          color: Colors.white24,
                        )),
                    );
                  },
                )),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: histTemp.asMap().entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                  isCurved: true,
                  color: AppTheme.colorPrimario,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true, color: AppTheme.colorPrimario.withOpacity(0.05)),
                ),
                LineChartBarData(
                  spots: histHum.asMap().entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                  isCurved: true,
                  color: AppTheme.colorSecundario,
                  barWidth: 2,
                  dashArray: [5, 3],
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true, color: AppTheme.colorSecundario.withOpacity(0.05)),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _leyenda(String texto, Color color, bool compact) {
    return Row(children: [
      Container(width: compact ? 10 : 14, height: 2, color: color),
      SizedBox(width: compact ? 2 : 4),
      Text(texto,
        style: GoogleFonts.spaceGrotesk(
          fontSize: compact ? 7 : 8,
          color: Colors.white38,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]);
  }

  Widget _graficaBarrasComparativa(bool compact) {
    if (histHum.isEmpty || histCo2.isEmpty) return _sinDatos(compact);

    final co2Max = histCo2.reduce((a, b) => a > b ? a : b);
    final co2Norm = histCo2.map((v) => (v / (co2Max == 0 ? 1 : co2Max)) * 100).toList();

    return Container(
      height: compact ? 150 : 200,
      padding: EdgeInsets.fromLTRB(4, compact ? 8 : 12, compact ? 8 : 12, 8),
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficie,
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _leyendaBar('Hum. %', AppTheme.colorSecundario, compact),
            SizedBox(width: compact ? 8 : 12),
            _leyendaBar('CO₂', AppTheme.colorError, compact),
          ]),
          SizedBox(height: compact ? 4 : 8),
          Expanded(
            child: BarChart(BarChartData(
              maxY: 110,
              gridData: FlGridData(
                show: true, drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: Colors.white.withOpacity(0.04), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: compact ? 22 : 28,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: compact ? 7 : 8,
                      color: Colors.white24,
                    )),
                )),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= histTime.length) return const SizedBox();
                    return Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(histTime[i],
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: compact ? 6 : 7,
                          color: Colors.white24,
                        )),
                    );
                  },
                )),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                histHum.length > co2Norm.length ? co2Norm.length : histHum.length,
                (i) => BarChartGroupData(
                  x: i,
                  barsSpace: 2,
                  barRods: [
                    BarChartRodData(
                      toY: histHum[i],
                      color: AppTheme.colorSecundario.withOpacity(0.8),
                      width: compact ? 4 : 6,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    BarChartRodData(
                      toY: co2Norm[i],
                      color: AppTheme.colorError.withOpacity(0.8),
                      width: compact ? 4 : 6,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _leyendaBar(String texto, Color color, bool compact) {
    return Row(children: [
      Container(
        width: compact ? 8 : 10,
        height: compact ? 8 : 10,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      SizedBox(width: compact ? 2 : 4),
      Text(texto,
        style: GoogleFonts.spaceGrotesk(
          fontSize: compact ? 7 : 8,
          color: Colors.white38,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]);
  }

  Widget _graficaLinea(List<double> datos, Color color, {double alto = 170}) {
    if (datos.isEmpty) return _sinDatos(alto < 160);

    return Container(
      height: alto,
      padding: const EdgeInsets.fromLTRB(4, 12, 12, 8),
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: LineChart(LineChartData(
        gridData: FlGridData(
          show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.white.withOpacity(0.04), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 32,
            getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
              style: GoogleFonts.jetBrainsMono(fontSize: 8, color: Colors.white24)),
          )),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, interval: 2,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= histTime.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(histTime[i],
                  style: GoogleFonts.jetBrainsMono(fontSize: 7, color: Colors.white24)),
              );
            },
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: datos.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: FlDotData(show: true,
              getDotPainter: (_, __, ___, ____) =>
                  FlDotCirclePainter(radius: 2.5, color: color, strokeWidth: 0)),
            belowBarData: BarAreaData(show: true, color: color.withOpacity(0.07)),
          ),
        ],
      )),
    );
  }

  Widget _titulo(String texto, bool compact) {
    return Text(texto,
      style: GoogleFonts.spaceGrotesk(
        fontSize: compact ? 9 : 10,
        fontWeight: FontWeight.bold,
        color: Colors.white38,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _sinDatos(bool compact) {
    return Container(
      height: compact ? 80 : 100,
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficie,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text('Esperando datos...',
          style: GoogleFonts.jetBrainsMono(
            fontSize: compact ? 10 : 11,
            color: Colors.white24,
          ),
        ),
      ),
    );
  }
}