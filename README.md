# 🤖 Mi IoT — Robot Cargo OS

[![Flutter](https://img.shields.io/badge/Flutter-3.29-02569B?logo=flutter)](https://flutter.dev)
[![ESP32](https://img.shields.io/badge/ESP32-C3%20Super%20Mini-E7352C?logo=espressif)](https://www.espressif.com)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime%20Database-FFCA28?logo=firebase)](https://firebase.google.com)

**Sistema de monitoreo ambiental IoT en tiempo real para robot de carga.**

---

## 📋 Tabla de Contenidos

- [📡 Descripción General](#-descripción-general)
- [🔧 Hardware](#-hardware)
- [📱 Aplicación Flutter](#-aplicación-flutter)
- [☁️ Firebase](#-firebase)
- [🚀 Instalación](#-instalación)
- [📂 Estructura del Proyecto](#-estructura-del-proyecto)
- [🔒 Seguridad](#-seguridad)
- [📊 Arquitectura del Sistema](#-arquitectura-del-sistema)
- [🛠️ Tecnologías](#-tecnologías)
- [📝 Licencia](#-licencia)

---

## 📡 Descripción General

**Mi IoT** es un sistema completo de monitoreo ambiental diseñado para robots de carga industrial. Combina hardware ESP32 con sensores de precisión y una aplicación móvil Flutter para visualización en tiempo real.

### ✨ Características Principales

- 🌡️ **Monitoreo en tiempo real** de temperatura, humedad y CO₂
- 📊 **Gráficas históricas** con análisis de tendencias
- 🚨 **Sistema de alertas** configurables por umbrales
- 💤 **Deep Sleep inteligente** con sensor ultrasónico de presencia
- 📱 **App Android/iOS** con Firebase Auth
- 📊 **Dashboard móvil** con métricas en tiempo real

---

## 🔧 Hardware

| Componente | Modelo | Especificación | GPIO |
|------------|--------|----------------|------|
| 🔲 Microcontrolador | ESP32-C3 Super Mini | RISC-V 160MHz, WiFi 6, BLE 5.0 | — |
| 🌡️ Sensor Temp/Hum | DHT22 (AM2302) | ±0.5°C, ±2% RH, Digital 1-Wire | GPIO 2 |
| ☁️ Sensor CO₂ | DFRobot CO2 V1.2 (MG-811) | 0-5000 ppm, Salida Analógica | GPIO 0 (ADC) |
| 📏 Sensor Distancia | HC-SR04 | 2cm-400cm, ±3mm, Ultrasónico | Configurable |
| 📺 Pantalla | LCD 16×2 I2C | Interfaz I2C (0x27) | SDA 21, SCL 20 |

### 🔌 Diagrama de Conexiones
ESP32-C3 Super Mini
├── GPIO 2 → DHT22 (DATA)
├── GPIO 0 → MG-811 (AOUT)
├── GPIO 4 → HC-SR04 (TRIG)
├── GPIO 5 → HC-SR04 (ECHO)
├── GPIO 21 → LCD I2C (SDA)
├── GPIO 20 → LCD I2C (SCL)
├── 5V → MG-811, HC-SR04, LCD
├── 3.3V → DHT22
└── GND → Todos los sensores

text

---

## 📱 Aplicación Flutter

### 📊 Pestañas del Dashboard

| Pestaña | Descripción | Datos |
|---------|-------------|-------|
| 📊 **Dashboard** | Análisis comparativo + gráficas | Tiempo real + Histórico |
| 📖 **Sensores** | Wiki técnica con especificaciones | Manual de referencia |
| 🚨 **Alertas** | Monitoreo de umbrales críticos | Temperatura, Humedad, CO₂ |
| 👤 **Perfil** | Gestión de usuario | Firebase Auth + Firestore |

### 🎨 Capturas de Pantalla
┌─────────────────────────────────┐
│ ROBOT CARGO OS │
│ SISTEMA DE MONITOREO ACTIVO │
│ │
│ 🔴 MONITOREO EN VIVO │
│ TEMP: 26.9°C HUM: 47% │
│ CO₂: 1049 VOLT: 0.82V │
│ │
│ ANÁLISIS DE PICOS │
│ TEMPERATURA │
│ ↑ MAX 26.9°C ↓ MIN 24.5°C │
│ │
│ 📈 GRÁFICAS EN TIEMPO REAL │
└─────────────────────────────────┘

text

---

## ☁️ Firebase

### 🔗 Estructura de la Base de Datos
sensores/
└── esp32_1/
├── actual/ ← PUT cada 2 segundos
│ ├── temperatura: 26.5
│ ├── humedad: 45.0
│ ├── co2: 1049
│ ├── voltaje: 0.82
│ └── timestamp: "2026-05-04T15:48:00"
│
└── lecturas/ ← POST cada 2 min o cambio
├── [push_id_1]
│ ├── temperatura: 26.5
│ ├── humedad: 45.0
│ ├── co2: 1049
│ ├── motivo: "forzado"
│ └── timestamp: "2026-05-04T15:48:00"
└── [push_id_2] ...

text

### 🔐 Reglas de Seguridad

```json
{
  "rules": {
    "sensores": {
      "esp32_1": {
        "actual": {
          ".read": "auth != null",
          ".write": true
        },
        "lecturas": {
          ".read": "auth != null",
          ".write": true,
          ".indexOn": "timestamp"
        }
      }
    }
  }
}
🚀 Instalación
📋 Prerrequisitos
Flutter SDK (3.29+)

Android Studio o VS Code

Firebase CLI

Cuenta de Firebase

📦 Clonar el Repositorio
bash
git clone https://github.com/Jhordan234/mi_iot.git
cd mi_iot
🔧 Configurar Firebase
Crea un proyecto en Firebase Console

Añade Firebase a tu proyecto Flutter:

bash
flutterfire configure
Coloca google-services.json en android/app/

📱 Instalar Dependencias
bash
flutter pub get
▶️ Ejecutar la App
bash
# Modo debug
flutter run

# Modo release (APK)
flutter build apk --release
🔌 Configurar ESP32
Abre el código del ESP32 en Arduino IDE

Configura las credenciales WiFi:

cpp
const char* ssid = "TU_WIFI";
const char* password = "TU_CONTRASEÑA";
Configura la URL de Firebase con tu proyecto

Sube el código al ESP32-C3

📂 Estructura del Proyecto
text
mi_iot/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── screens/
│   │   ├── home_screen.dart         # Navegación principal
│   │   └── auth_screen.dart         # Login/registro
│   ├── tabs/
│   │   ├── dashboard_tab.dart       # Dashboard principal
│   │   ├── sensores_tab.dart        # Wiki técnica
│   │   ├── alertas_tab.dart         # Sistema de alertas
│   │   └── perfil_tab.dart          # Perfil de usuario
│   └── theme/
│       └── app_theme.dart           # Tema oscuro personalizado
├── assets/
│   ├── icono_app.png                # Icono de la aplicación
│   └── images/
│       ├── sensor_dht22.png
│       ├── sensor_co2.png
│       ├── sensor_ultrasonico.png
│       ├── sensor_lcd.png
│       └── sensor_esp32.png
├── android/                         # Configuración Android
├── ios/                             # Configuración iOS
├── pubspec.yaml                     # Dependencias
└── README.md                        # Este archivo
🔒 Seguridad
❌ No se suben a GitHub
google-services.json — Credenciales Firebase

GoogleService-Info.plist — Credenciales iOS

firebase.json — Configuración Firebase

.firebaserc — Alias de proyecto

*.jks — Keystore Android

key.properties — Claves de firma

✅ Protección de Datos
Firebase Auth para autenticación de usuarios

Reglas de seguridad por nodo

Deep Sleep con memoria RTC encriptada

Conexión HTTPS para todas las comunicaciones

📊 Arquitectura del Sistema
text
┌─────────────────┐     WiFi/HTTPS     ┌──────────────────┐
│   ESP32-C3       │ ─────────────────► │   Firebase       │
│   Super Mini     │                    │   Realtime DB    │
│                  │                    │                  │
│ • DHT22          │  PUT /actual       │ • /actual        │
│ • MG-811         │  (cada 2s)         │ • /lecturas      │
│ • HC-SR04        │                    │                  │
│ • LCD 16×2       │  POST /lecturas    │ • Firestore      │
│                  │  (cada 2min)       │   (usuarios)     │
└─────────────────┘                    └──────────────────┘
                                                │
                                                │ HTTPS
                                                ▼
                                       ┌──────────────────┐
                                       │   App Flutter    │
                                       │   "Mi IoT"       │
                                       │                  │
                                       │ • Dashboard      │
                                       │ • Sensores       │
                                       │ • Alertas        │
                                       │ • Perfil         │
                                       └──────────────────┘
🛠️ Tecnologías
Categoría	Tecnología	Versión
📱 Frontend	Flutter	3.29+
🎨 Lenguaje	Dart	3.9+
☁️ Backend	Firebase Realtime DB	—
🔐 Auth	Firebase Auth	—
📊 Gráficas	fl_chart	0.68+
🎨 Fuentes	Google Fonts	6.3+
🔲 Hardware	ESP32-C3	—
🔌 Protocolo	WiFi 802.11 b/g/n	—
📝 Licencia
© 2026 Mi IoT. Todos los derechos reservados.

🙏 Agradecimientos
Flutter — Framework de UI

Firebase — Backend como servicio

Espressif — Fabricante del ESP32

🚀 Desarrollado para Robot Cargo OS — Sistema de Monitoreo Activo