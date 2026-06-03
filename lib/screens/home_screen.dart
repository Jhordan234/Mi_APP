import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/sensores_tab.dart';
import 'tabs/alertas_tab.dart';
import 'tabs/perfil_tab.dart';
import '../theme/app_theme.dart';

// ============================================================
//  Modelo de datos en tiempo real
//  ValueNotifier → solo reconstruye los widgets que lo escuchan
//  NO reconstruye toda la pantalla
// ============================================================
class DatosTiempoReal {
  final double temp, hum, co2, volt;
  final String ultimaLectura;

  const DatosTiempoReal({
    this.temp = 0,
    this.hum  = 0,
    this.co2  = 0,
    this.volt = 0,
    this.ultimaLectura = '--:--:--',
  });
}

// ============================================================
//  Buffer de tiempo real — 20 puntos por sensor
//  Se llena con cada dato nuevo que llega del nodo "actual"
//  Es independiente del historial de Firebase
//  → los sparklines de los cards lo usan para animarse en vivo
// ============================================================
const int kBufferSize = 20;

class BufferTiempoReal {
  final List<double> temp, hum, co2, volt;

  const BufferTiempoReal({
    this.temp = const [],
    this.hum  = const [],
    this.co2  = const [],
    this.volt = const [],
  });

  // Agrega un punto nuevo y descarta el más viejo si supera kBufferSize
  BufferTiempoReal agregar({
    required double t,
    required double h,
    required double c,
    required double v,
  }) {
    List<double> _push(List<double> lista, double valor) {
      final nueva = List<double>.from(lista)..add(valor);
      if (nueva.length > kBufferSize) nueva.removeAt(0);
      return List.unmodifiable(nueva);
    }

    return BufferTiempoReal(
      temp: _push(temp, t),
      hum:  _push(hum,  h),
      co2:  _push(co2,  c),
      volt: _push(volt, v),
    );
  }
}

class DatosHistorial {
  final List<double> histTemp, histHum, histCo2, histVolt;
  final List<String> histTime;

  const DatosHistorial({
    this.histTemp = const [],
    this.histHum  = const [],
    this.histCo2  = const [],
    this.histVolt = const [],
    this.histTime = const [],
  });
}

// ============================================================
//  HomeScreen
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ── ValueNotifiers — actualizan SOLO los widgets suscritos ──
  // Tiempo real: se actualiza cada 500ms (viene del ESP32)
  final _tiempoReal = ValueNotifier<DatosTiempoReal>(
    const DatosTiempoReal(),
  );

  // Buffer de tiempo real: 20 puntos para los sparklines de los cards
  final _buffer = ValueNotifier<BufferTiempoReal>(
    const BufferTiempoReal(),
  );

  // Historial: se actualiza cada vez que llega un dato nuevo
  // (mucho menos frecuente — solo cuando hay cambio notable o forzado)
  final _historial = ValueNotifier<DatosHistorial>(
    const DatosHistorial(),
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _iniciarEscuchaFirebase();
  }

  @override
  void dispose() {
    _tiempoReal.dispose();
    _buffer.dispose();
    _historial.dispose();
    super.dispose();
  }

  void _iniciarEscuchaFirebase() {
    final rootRef = FirebaseDatabase.instance
        .ref()
        .child('sensores/esp32_1');

    // ── TIEMPO REAL ─────────────────────────────────────────
    // onValue dispara INMEDIATAMENTE cuando Firebase cambia
    // No hay setState aquí — solo actualiza el ValueNotifier
    // → Solo los widgets con ValueListenableBuilder se redibujan
    rootRef.child('actual').onValue.listen((event) {
      final datos = event.snapshot.value as Map?;
      if (datos == null) return;

      final timestamp = datos['timestamp'] as String? ?? '';
      final hora = timestamp.contains('T')
          ? timestamp.split('T')[1].substring(0, 8)
          : '--:--:--';

      final t = double.tryParse(datos['temperatura'].toString()) ?? 0;
      final h = double.tryParse(datos['humedad'].toString())     ?? 0;
      final c = double.tryParse(datos['co2_ppm'].toString())     ?? 0;
      final v = double.tryParse(datos['voltaje_ampli'].toString()) ?? 0;

      // Actualizar valor actual — NO usa setState
      _tiempoReal.value = DatosTiempoReal(
        temp: t, hum: h, co2: c, volt: v,
        ultimaLectura: hora,
      );

      // Agregar al buffer de 20 puntos para los sparklines
      // Cada dato nuevo se suma al final, el más viejo se descarta
      _buffer.value = _buffer.value.agregar(t: t, h: h, c: c, v: v);
    });

    // ── HISTORIAL ────────────────────────────────────────────
    // Este stream es más lento (llegan pocos datos)
    // También usa ValueNotifier para no reconstruir la pantalla entera
    rootRef
        .child('lecturas')
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue
        .listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return;

      final List<double> tTemp = [], tHum = [], tCo2 = [], tVolt = [];
      final List<String> tTime = [];

      final Map<dynamic, dynamic> lecturas =
          snapshot.value as Map<dynamic, dynamic>;
      final keysOrdenadas = lecturas.keys.toList()..sort();

      for (final key in keysOrdenadas) {
        final item = lecturas[key] as Map?;
        if (item == null) continue;
        tTemp.add(double.tryParse(item['temperatura'].toString()) ?? 0);
        tHum.add(double.tryParse(item['humedad'].toString())      ?? 0);
        tCo2.add(double.tryParse(item['co2_ppm'].toString())      ?? 0);
        tVolt.add(double.tryParse(item['voltaje_ampli'].toString()) ?? 0);

        final ts = item['timestamp'] as String? ?? '00:00';
        tTime.add(ts.contains('T') ? ts.split('T')[1].substring(0, 5) : ts);
      }

      // Asignar al notifier — NO usa setState
      _historial.value = DatosHistorial(
        histTemp: List.unmodifiable(tTemp),
        histHum:  List.unmodifiable(tHum),
        histCo2:  List.unmodifiable(tCo2),
        histVolt: List.unmodifiable(tVolt),
        histTime: List.unmodifiable(tTime),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorFondo,

      // ── IndexedStack — mantiene todos los tabs vivos ────────
      // Ahora los tabs usan ValueListenableBuilder internamente
      // → NO se reconstruyen todos cuando llega un dato nuevo
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // TAB 0: DASHBOARD
          _DashboardWrapper(
            tiempoReal: _tiempoReal,
            historial:  _historial,
            buffer:     _buffer,
          ),

          // TAB 1: SENSORES
          _SensoresWrapper(
            tiempoReal: _tiempoReal,
            historial:  _historial,
          ),

          // TAB 2: ALERTAS
          _AlertasWrapper(tiempoReal: _tiempoReal),

          // TAB 3: PERFIL — nunca necesita datos del sensor
          const PerfilTab(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // setState aquí solo reconstruye el BottomNavigationBar
        // NO reconstruye los tabs (IndexedStack los preserva)
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.colorSuperficie,
        selectedItemColor: AppTheme.colorPrimario,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'DASHBOARD'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sensors), label: 'SENSORES'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'ALERTAS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'PERFIL'),
        ],
      ),
    );
  }
}

// ============================================================
//  Wrappers — cada uno escucha SOLO lo que necesita
//  ValueListenableBuilder reconstruye SOLO este widget
//  cuando cambia el notifier, no el resto de la pantalla
// ============================================================

class _DashboardWrapper extends StatelessWidget {
  final ValueNotifier<DatosTiempoReal>  tiempoReal;
  final ValueNotifier<DatosHistorial>   historial;
  final ValueNotifier<BufferTiempoReal> buffer;

  const _DashboardWrapper({
    required this.tiempoReal,
    required this.historial,
    required this.buffer,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DatosTiempoReal>(
      valueListenable: tiempoReal,
      builder: (_, tr, __) {
        return ValueListenableBuilder<DatosHistorial>(
          valueListenable: historial,
          builder: (_, hist, __) {
            return ValueListenableBuilder<BufferTiempoReal>(
              valueListenable: buffer,
              builder: (_, buf, __) {
                return DashboardTab(
                  tempActual: tr.temp,
                  humActual:  tr.hum,
                  co2Actual:  tr.co2,
                  voltActual: tr.volt,
                  histTemp:   hist.histTemp,
                  histHum:    hist.histHum,
                  histCo2:    hist.histCo2,
                  histVolt:   hist.histVolt,
                  histTime:   hist.histTime,
                  // Buffer para los sparklines de los cards
                  bufTemp:    buf.temp,
                  bufHum:     buf.hum,
                  bufCo2:     buf.co2,
                  bufVolt:    buf.volt,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SensoresWrapper extends StatelessWidget {
  final ValueNotifier<DatosTiempoReal> tiempoReal;
  final ValueNotifier<DatosHistorial>  historial;

  const _SensoresWrapper({
    required this.tiempoReal,
    required this.historial,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DatosTiempoReal>(
      valueListenable: tiempoReal,
      builder: (_, tr, __) {
        return ValueListenableBuilder<DatosHistorial>(
          valueListenable: historial,
          builder: (_, hist, __) {
            return SensoresTab(
              temperatura:    tr.temp,
              humedad:        tr.hum,
              co2:            tr.co2,
              voltaje:        tr.volt,
              ultimaLectura:  tr.ultimaLectura,
              histTemp:       hist.histTemp,
              histHum:        hist.histHum,
              histCo2:        hist.histCo2,
              histTime:       hist.histTime,
            );
          },
        );
      },
    );
  }
}

class _AlertasWrapper extends StatelessWidget {
  final ValueNotifier<DatosTiempoReal> tiempoReal;

  const _AlertasWrapper({required this.tiempoReal});

  @override
  Widget build(BuildContext context) {
    // Alertas solo necesita los valores actuales, no el historial
    return ValueListenableBuilder<DatosTiempoReal>(
      valueListenable: tiempoReal,
      builder: (_, tr, __) {
        return AlertasTab(
          temperatura: tr.temp,
          humedad:     tr.hum,
          co2:         tr.co2,
        );
      },
    );
  }
}