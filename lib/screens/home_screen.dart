import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/sensores_tab.dart';
import 'tabs/alertas_tab.dart';
import 'tabs/perfil_tab.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // ─── ESTADOS COMPARTIDOS ───
  double temp = 0, hum = 0, co2 = 0, volt = 0;
  String ultimaLectura = '--:--:--';
  List<double> histTemp = [], histHum = [], histCo2 = [], histVolt = [];
  List<String> histTime = [];

  @override
  void initState() {
    super.initState();
    _iniciarEscuchaFirebase();
  }

  void _iniciarEscuchaFirebase() {
    final rootRef = FirebaseDatabase.instance.ref().child('sensores/esp32_1');

    // 1. TIEMPO REAL
    rootRef.child('actual').onValue.listen((event) {
      final datos = event.snapshot.value as Map?;
      if (datos != null) {
        setState(() {
          temp = double.tryParse(datos['temperatura'].toString()) ?? 0;
          hum  = double.tryParse(datos['humedad'].toString()) ?? 0;
          co2  = double.tryParse(datos['co2_ppm'].toString()) ?? 0;
          volt = double.tryParse(datos['voltaje'].toString()) ?? 0;
          
          // Actualizar última lectura
          final timestamp = datos['timestamp'] as String? ?? '';
          ultimaLectura = timestamp.contains('T') 
              ? timestamp.split('T')[1].substring(0, 8) 
              : '--:--:--';
        });
      }
    });

    // 2. HISTORIAL
    rootRef.child('lecturas')
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value != null) {
        List<double> tTemp = [], tHum = [], tCo2 = [], tVolt = [];
        List<String> tTime = [];

        final Map<dynamic, dynamic> lecturas = snapshot.value as Map;
        var keysOrdenadas = lecturas.keys.toList()..sort();

        for (var key in keysOrdenadas) {
          final item = lecturas[key];
          tTemp.add(double.tryParse(item['temperatura'].toString()) ?? 0);
          tHum.add(double.tryParse(item['humedad'].toString()) ?? 0);
          tCo2.add(double.tryParse(item['co2_ppm'].toString()) ?? 0);
          tVolt.add(double.tryParse(item['voltaje'].toString()) ?? 0);
          
          String ts = item['timestamp'] ?? "00:00";
          tTime.add(ts.contains('T') ? ts.split('T')[1].substring(0, 5) : ts);
        }

        setState(() {
          histTemp = tTemp;
          histHum = tHum;
          histCo2 = tCo2;
          histVolt = tVolt;
          histTime = tTime;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabs = [
      // TAB 0: DASHBOARD
      DashboardTab(
        tempActual: temp,
        humActual: hum,
        co2Actual: co2,
        voltActual: volt,
        histTemp: histTemp,
        histHum: histHum,
        histCo2: histCo2,
        histVolt: histVolt,
        histTime: histTime,
      ),
      
      // TAB 1: SENSORES
      SensoresTab(
        temperatura: temp,
        humedad: hum,
        co2: co2,
        voltaje: volt,
        ultimaLectura: ultimaLectura,
        histTemp: histTemp,
        histHum: histHum,
        histCo2: histCo2,
        histTime: histTime,
      ),
      
      // TAB 2: ALERTAS
      AlertasTab(
        temperatura: temp,
        humedad: hum,
        co2: co2,
      ),
      
      // TAB 3: PERFIL
      const PerfilTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.colorFondo,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.colorSuperficie,
        selectedItemColor: AppTheme.colorPrimario,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'DASHBOARD'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'SENSORES'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'ALERTAS'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PERFIL'),
        ],
      ),
    );
  }
}