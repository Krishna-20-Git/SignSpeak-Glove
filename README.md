# SignSpeak — Multilingual Sign Language to Speech Glove

A B.Tech assistive technology project that converts hand gestures into spoken speech in 4 languages using a smart glove.

## Demo
> Tap a gesture ? App speaks instantly in English, Hindi, Tamil or Bengali

## Hardware
| Component | Purpose |
|-----------|---------|
| ESP32 Dev Module | Main microcontroller + BLE |
| 4x Flex Sensors | Finger bend detection |
| MPU6050 | Hand orientation (gyro + accelerometer) |
| Power Bank| power supply |
| ESD Anti-static Glove | Base glove |
| 5x 10kO Resistors | Voltage dividers for flex sensors |

## App Features
- 4 languages — English, Hindi, Tamil, Bengali
- 20 gesture mappings per language
- BLE auto-connect to glove
- Male / Female voice selection
- Speech history log
- Gesture dictionary
- Cyberpunk animated UI
- Presentation mode

## Tech Stack
- Flutter 3.41 (Android)
- ESP32 Arduino (BLE GATT server)
- flutter_tts (Text to Speech)
- flutter_blue_plus (Bluetooth LE)
- Provider (State management)

## How It Works
1. Glove detects finger bend via flex sensors (ADC)
2. ESP32 classifies gesture ? sends 2-digit ID over BLE
3. Flutter app receives ID ? looks up phrase in JSON
4. flutter_tts speaks the phrase in selected language

## Setup
```bash
flutter pub get
flutter run
```
Flash `esp32_firmware.ino` to ESP32 using Arduino IDE.

## Languages
| Code | Language | Sample |
|------|----------|--------|
| EN | English | "Hello" |
| HI | Hindi | "Namaste" |
| TA | Tamil | "Vanakkam" |
| BN | Bengali | "Nomoshkaar" |

---
*Built with Flutter + ESP32 + BLE for assistive communication*
