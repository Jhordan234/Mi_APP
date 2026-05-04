import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class SensoresTab extends StatelessWidget {
  final double temperatura, humedad, co2, voltaje;
  final String ultimaLectura;
  final List<double> histTemp, histHum, histCo2;
  final List<String> histTime;

  const SensoresTab({
    super.key,
    required this.temperatura,
    required this.humedad,
    required this.co2,
    required this.voltaje,
    required this.ultimaLectura,
    required this.histTemp,
    required this.histHum,
    required this.histCo2,
    required this.histTime,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESPECIFICACIONES IoT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: isSmallScreen ? 8 : 10,
              color: AppTheme.colorPrimario,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          FittedBox(
            child: Text(
              'MANUAL TÉCNICO',
              style: GoogleFonts.orbitron(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            'ÚLTIMA ACTUALIZACIÓN: $ultimaLectura',
            style: GoogleFonts.jetBrainsMono(
              fontSize: isSmallScreen ? 8 : 9,
              color: Colors.white24,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: isSmallScreen ? 14 : 20),

          // ✅ 1. DHT22 - TEMPERATURA
          _wikiSensor(
            titulo: 'DHT22 — AM2302',
            subtitulo: 'SENSOR DE TEMPERATURA',
            imagenAsset: 'assets/images/sensor_dht22.png',
            valorLabel: 'TEMPERATURA ACTUAL',
            valor: '${temperatura.toStringAsFixed(1)} °C',
            colorValor: AppTheme.colorPrimario,
            descripcion:
                'El DHT22 mide la temperatura ambiente con alta precisión. '
                'En el sistema de monitoreo, detecta cambios térmicos en el '
                'entorno del robot de carga, alertando si el ambiente supera '
                'los 35°C, lo cual puede afectar la electrónica del equipo.',
            specs: [
              ['Rango Temperatura', '-40°C a 80°C'],
              ['Precisión', '±0.5°C'],
              ['Voltaje', '3.3V — 5V'],
              ['Protocolo', 'Digital 1-Wire'],
              ['Pin GPIO', 'GPIO 2 (ESP32-C3)'],
            ],
            estado: temperatura > 35 ? 'ALERTA' : 'NOMINAL',
            colorEstado: temperatura > 35
                ? AppTheme.colorError
                : AppTheme.colorTerciario,
            progreso: (temperatura / 50).clamp(0, 1),
            isSmall: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 10 : 16),

          // ✅ 2. DHT22 - HUMEDAD
          _wikiSensor(
            titulo: 'DHT22 — AM2302',
            subtitulo: 'SENSOR DE HUMEDAD',
            imagenAsset: 'assets/images/sensor_dht22.png',
            valorLabel: 'HUMEDAD ACTUAL',
            valor: '${humedad.toStringAsFixed(1)} %',
            colorValor: AppTheme.colorSecundario,
            descripcion:
                'El mismo sensor DHT22 también mide la humedad relativa. '
                'Un ambiente húmedo puede provocar corrosión en los contactos '
                'eléctricos del robot de carga. El sistema alerta si la '
                'humedad supera el 80% RH.',
            specs: [
              ['Rango Humedad', '0% a 100% RH'],
              ['Precisión', '±2% a ±5% RH'],
              ['Voltaje', '3.3V — 5V'],
              ['Protocolo', 'Digital 1-Wire'],
              ['Pin GPIO', 'GPIO 2 (ESP32-C3)'],
            ],
            estado: humedad > 80 ? 'ELEVADA' : 'ÓPTIMO',
            colorEstado: humedad > 80
                ? AppTheme.colorSecundario
                : AppTheme.colorTerciario,
            progreso: (humedad / 100).clamp(0, 1),
            isSmall: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 10 : 16),

          // ✅ 3. DFRobot CO2 V1.2 — MG-811
          _wikiSensor(
            titulo: 'DFRobot CO2 V1.2',
            subtitulo: 'SENSOR DE CO₂ — MG-811',
            imagenAsset: 'assets/images/sensor_co2.png',
            valorLabel: 'CO₂ ACTUAL',
            valor: '${co2.toStringAsFixed(0)} ppm',
            colorValor: co2 > 1000
                ? AppTheme.colorError
                : const Color(0xFFAFEE00),
            descripcion:
                'El sensor MG-811 detecta la concentración de CO₂ en el aire. '
                'Niveles elevados de CO₂ (>1000 ppm) indican ventilación '
                'deficiente en el área de operación del robot, lo que puede '
                'afectar la salud del operador y la eficiencia del sistema. '
                'Requiere calibración de 48 horas al aire libre.',
            specs: [
              ['Rango', '0 ~ 5000 ppm'],
              ['Voltaje', '5V (obligatorio)'],
              ['Salida', 'Analógica (AOUT)'],
              ['Pin GPIO', 'GPIO 0 — ADC 12 bits'],
              ['Calentamiento', '48h calibración'],
              ['Modelo', 'SKU: SEN0159'],
            ],
            estado: co2 > 1500
                ? 'CRÍTICO'
                : co2 > 1000
                ? 'ELEVADO'
                : 'NORMAL',
            colorEstado: co2 > 1500
                ? AppTheme.colorError
                : co2 > 1000
                ? AppTheme.colorSecundario
                : AppTheme.colorTerciario,
            progreso: (co2 / 5000).clamp(0, 1),
            isSmall: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 10 : 16),

          // ✅ 4. HC-SR04 — SENSOR ULTRASÓNICO (NUEVO)
          _wikiSensor(
            titulo: 'HC-SR04',
            subtitulo: 'SENSOR ULTRASÓNICO DE DISTANCIA',
            imagenAsset: 'assets/images/sensor_ultrasonico.png',
            valorLabel: 'DISTANCIA',
            valor: '— cm',
            colorValor: AppTheme.colorTerciario,
            descripcion:
                'Sensor ultrasónico HC-SR04 para medición de distancia. '
                'Útil para detectar obstáculos o medir proximidad en el '
                'robot de carga. Rango: 2cm a 400cm con precisión de 3mm. '
                'Funciona emitiendo pulsos ultrasónicos y midiendo el tiempo '
                'de retorno del eco.',
            specs: [
              ['Modelo', 'HC-SR04'],
              ['Rango', '2cm — 400cm'],
              ['Precisión', '±3mm'],
              ['Voltaje', '5V'],
              ['Trigger', 'GPIO (configurable)'],
              ['Echo', 'GPIO (configurable)'],
              ['Ángulo', '15°'],
            ],
            estado: 'OPERATIVO',
            colorEstado: AppTheme.colorTerciario,
            progreso: 0.75,
            isSmall: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 10 : 16),

          // ✅ 5. LCD 16×2 I2C — PANTALLA
          _wikiSensor(
            titulo: 'LCD 16×2 I2C',
            subtitulo: 'PANTALLA DE VISUALIZACIÓN LOCAL',
            imagenAsset: 'assets/images/sensor_lcd.png',
            valorLabel: 'INTERFAZ LOCAL',
            valor: 'ACTIVA',
            colorValor: AppTheme.colorPrimario,
            descripcion:
                'Pantalla LCD 16×2 con interfaz I2C para visualizar datos '
                'en tiempo real sin necesidad de la app. Muestra temperatura, '
                'humedad y CO₂ directamente en el dispositivo IoT.',
            specs: [
              ['Modelo', 'LCD 1602 I2C'],
              ['Caracteres', '16×2 (32 total)'],
              ['Interfaz', 'I2C (SDA/SCL)'],
              ['Dirección', '0x27'],
              ['Voltaje', '5V'],
              ['Pines I2C', 'GPIO 21 (SDA), GPIO 20 (SCL)'],
            ],
            estado: 'CONECTADA',
            colorEstado: AppTheme.colorTerciario,
            progreso: 1.0,
            isSmall: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 10 : 16),

          // ✅ 6. ESP32-C3 SUPER MINI
          _wikiSensor(
            titulo: 'ESP32-C3 Super Mini',
            subtitulo: 'MICROCONTROLADOR PRINCIPAL',
            imagenAsset: 'assets/images/sensor_esp32.png',
            valorLabel: 'NÚCLEO DEL SISTEMA',
            valor: 'WiFi + BLE 5.0',
            colorValor: AppTheme.colorSecundario,
            descripcion:
                'El ESP32-C3 Super Mini es el cerebro del sistema IoT. '
                'Cuenta con WiFi 802.11b/g/n y Bluetooth 5.0 LE. '
                'Procesa las lecturas de todos los sensores y las envía '
                'a Firebase en tiempo real cada 2 segundos.',
            specs: [
              ['Chip', 'ESP32-C3FN4'],
              ['Procesador', 'RISC-V 32 bits'],
              ['Frecuencia', '160 MHz'],
              ['RAM', '400 KB SRAM'],
              ['Flash', '4 MB'],
              ['WiFi', '802.11 b/g/n'],
              ['Bluetooth', 'BLE 5.0'],
              ['ADC', '12 bits (6 canales)'],
            ],
            estado: 'OPERATIVO',
            colorEstado: AppTheme.colorTerciario,
            progreso: 0.9,
            isSmall: isSmallScreen,
          ),

          SizedBox(height: isSmallScreen ? 14 : 20),
          _tituloSeccion('HISTORIAL DE LECTURAS', isSmallScreen),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _tablaHistorial(isSmallScreen),
          SizedBox(height: isSmallScreen ? 14 : 20),
        ],
      ),
    );
  }

  Widget _wikiSensor({
    required String titulo,
    required String subtitulo,
    required String imagenAsset,
    required String valorLabel,
    required String valor,
    required Color colorValor,
    required String descripcion,
    required List<List<String>> specs,
    required String estado,
    required Color colorEstado,
    required double progreso,
    required bool isSmall,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficieAlta,
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        border: Border.all(color: colorValor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorValor.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con imagen y valor actual
          Container(
            padding: EdgeInsets.all(isSmall ? 10 : 16),
            decoration: BoxDecoration(
              color: colorValor.withOpacity(0.04),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isSmall ? 12 : 16),
              ),
              border: Border(
                bottom: BorderSide(color: colorValor.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                // Imagen del sensor
                Container(
                  width: isSmall ? 50 : 80,
                  height: isSmall ? 50 : 80,
                  decoration: BoxDecoration(
                    color: AppTheme.colorSuperficie,
                    borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
                    border: Border.all(color: colorValor.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: colorValor.withOpacity(0.15),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
                    child: Image.asset(
                      imagenAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.sensors,
                        color: colorValor,
                        size: isSmall ? 24 : 36,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmall ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitulo,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: isSmall ? 8 : 9,
                          color: colorValor.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        titulo,
                        style: GoogleFonts.orbitron(
                          fontSize: isSmall ? 12 : 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmall ? 6 : 8),
                      Text(
                        valorLabel,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: isSmall ? 8 : 9,
                          color: Colors.white24,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        valor,
                        style: GoogleFonts.orbitron(
                          fontSize: isSmall ? 16 : 22,
                          fontWeight: FontWeight.w900,
                          color: colorValor,
                          shadows: [
                            Shadow(
                              color: colorValor.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge estado
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 6 : 8,
                        vertical: isSmall ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorEstado.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colorEstado.withOpacity(0.3)),
                      ),
                      child: Text(
                        estado,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: isSmall ? 7 : 9,
                          color: colorEstado,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Barra de progreso
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 12 : 16,
              vertical: isSmall ? 8 : 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NIVEL',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isSmall ? 7 : 8,
                        color: Colors.white24,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${(progreso * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.orbitron(
                        fontSize: isSmall ? 9 : 10,
                        color: colorValor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmall ? 3 : 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progreso,
                    backgroundColor: colorValor.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(colorValor),
                    minHeight: isSmall ? 3 : 4,
                  ),
                ),
              ],
            ),
          ),

          // Descripción técnica
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
            child: Text(
              descripcion,
              style: GoogleFonts.spaceGrotesk(
                fontSize: isSmall ? 10 : 12,
                color: Colors.white54,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: isSmall ? 10 : 12),

          // Specs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
            child: Text(
              'ESPECIFICACIONES',
              style: GoogleFonts.spaceGrotesk(
                fontSize: isSmall ? 8 : 9,
                color: colorValor.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(height: isSmall ? 6 : 8),
          ...specs.asMap().entries.map((e) {
            final ultimo = e.key == specs.length - 1;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 12 : 16,
                vertical: isSmall ? 6 : 8,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ultimo
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      e.value[0],
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isSmall ? 10 : 11,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      e.value[1],
                      textAlign: TextAlign.right,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: isSmall ? 10 : 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: isSmall ? 10 : 12),
        ],
      ),
    );
  }

  Widget _tablaHistorial(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colorSuperficieAlta,
        borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
        border: Border.all(color: AppTheme.colorPrimario.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 8 : 12,
              vertical: isSmall ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: AppTheme.colorSuperficie,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isSmall ? 10 : 12),
              ),
            ),
            child: Row(
              children: ['HORA', 'TEMP', 'HUM', 'CO₂']
                  .map(
                    (h) => Expanded(
                      child: Text(
                        h,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: isSmall ? 7 : 9,
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          ...histTime.asMap().entries.map((e) {
            final i = e.key;
            final alerta = i < histCo2.length && histCo2[i] > 1000;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 8 : 12,
                vertical: isSmall ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: alerta
                    ? AppTheme.colorError.withOpacity(0.04)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.value,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: isSmall ? 9 : 10,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      i < histTemp.length
                          ? '${histTemp[i].toStringAsFixed(1)}°'
                          : '--',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: isSmall ? 9 : 10,
                        color: AppTheme.colorPrimario,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      i < histHum.length
                          ? '${histHum[i].toStringAsFixed(0)}%'
                          : '--',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: isSmall ? 9 : 10,
                        color: AppTheme.colorSecundario,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      i < histCo2.length ? histCo2[i].toStringAsFixed(0) : '--',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: isSmall ? 9 : 10,
                        color: alerta
                            ? AppTheme.colorError
                            : const Color(0xFFAFEE00),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _tituloSeccion(String texto, bool isSmall) {
    return Text(
      texto,
      style: GoogleFonts.spaceGrotesk(
        fontSize: isSmall ? 9 : 10,
        fontWeight: FontWeight.bold,
        color: Colors.white38,
        letterSpacing: 1.5,
      ),
    );
  }
}
