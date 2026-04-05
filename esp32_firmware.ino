/*
 * ============================================================
 *  SignSpeak Glove — ESP32 BLE Firmware
 *  Hardware: ESP32 + 5x Flex Sensors + MPU6050 + OLED (SSD1306)
 * ============================================================
 *  BLE Service UUID : 4fafc201-1fb5-459e-8fcc-c5c9c331914b
 *  Characteristic   : beb5483e-36e1-4688-b7f5-ea07361b26a8
 *  Sends: gesture ID string e.g. "05\n" when a gesture is recognized
 * ============================================================
 */

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Wire.h>
#include <MPU6050.h>
#include <Adafruit_SSD1306.h>

// ─── OLED ────────────────────────────────────────────────────
#define SCREEN_WIDTH  128
#define SCREEN_HEIGHT  32
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// ─── MPU6050 ─────────────────────────────────────────────────
MPU6050 mpu;

// ─── Flex Sensor Pins (ADC) ──────────────────────────────────
// Thumb, Index, Middle, Ring, Pinky
const int FLEX_PINS[5] = {34, 35, 32, 33, 25};

// ─── BLE UUIDs ───────────────────────────────────────────────
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer*         pServer         = nullptr;
BLECharacteristic* pCharacteristic = nullptr;
bool               deviceConnected = false;

// ─── BLE Callbacks ───────────────────────────────────────────
class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    deviceConnected = true;
    Serial.println("[BLE] Phone connected");
  }
  void onDisconnect(BLEServer* pServer) override {
    deviceConnected = false;
    Serial.println("[BLE] Phone disconnected — restarting advertising");
    BLEDevice::startAdvertising();
  }
};

// ─── Gesture Thresholds ──────────────────────────────────────
// Calibrate these by printing raw flex values in Serial Monitor
// Values are ADC counts (0–4095). Higher = more bent.
struct GestureThreshold {
  int id;
  int flexMin[5];   // Each finger: minimum bend to trigger
  int flexMax[5];   // Each finger: maximum bend
  // -1 means "don't care"
};

// 5 fingers: [Thumb, Index, Middle, Ring, Pinky]
// -1 = don't care for that finger
const int DC = -1;

// Extend / adjust these thresholds after calibration
const GestureThreshold GESTURES[] = {
  // ID  Thumb       Index       Middle      Ring        Pinky
  {  1, {500,1500}, {500,1500}, {500,1500}, {500,1500}, {500,1500} },  // All open = Hello
  {  2, {2000,4095},{2000,4095},{2000,4095},{2000,4095},{2000,4095}},   // All closed = Thank You
  {  3, {500,1500}, {2000,4095},{2000,4095},{2000,4095},{500,1500}  },  // Thumbs up = Yes
  {  4, {500,1500}, {500,1500}, {2000,4095},{2000,4095},{2000,4095} },  // Peace = No
  {  5, {500,1500}, {2000,4095},{2000,4095},{2000,4095},{2000,4095} },  // Intro gesture
  {  7, {2000,4095},{500,1500}, {500,1500}, {2000,4095},{2000,4095} },  // Help
  {  8, {500,1500}, {2000,4095},{2000,4095},{2000,4095},{2000,4095} },  // Water
  { 19, {2000,4095},{2000,4095},{2000,4095},{2000,4095},{2000,4095} },  // Emergency (fist)
};
const int NUM_GESTURES = sizeof(GESTURES) / sizeof(GESTURES[0]);

// ─── State ───────────────────────────────────────────────────
int   lastGestureId      = -1;
unsigned long lastSendMs = 0;
const unsigned long DEBOUNCE_MS = 1500; // Send same gesture max once per 1.5s

// ─── Setup ───────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);

  // OLED
  Wire.begin(21, 22);
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("[OLED] Not found — check wiring");
  }
  showOled("SignSpeak", "Booting...");

  // MPU6050
  mpu.initialize();
  if (!mpu.testConnection()) {
    Serial.println("[MPU] Connection failed");
    showOled("MPU6050", "FAIL - check I2C");
    delay(2000);
  }

  // Flex pins
  for (int i = 0; i < 5; i++) {
    pinMode(FLEX_PINS[i], INPUT);
  }

  // BLE
  BLEDevice::init("SignGlove_01");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  BLEService* pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  pCharacteristic->addDescriptor(new BLE2902());
  pService->start();

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  BLEDevice::startAdvertising();

  Serial.println("[BLE] Advertising as 'SignGlove_01'");
  showOled("SignGlove_01", "Waiting for phone");
}

// ─── Loop ────────────────────────────────────────────────────
void loop() {
  // Read flex sensors
  int flex[5];
  for (int i = 0; i < 5; i++) {
    flex[i] = analogRead(FLEX_PINS[i]);
  }

  // Debug: print raw values
  if (millis() % 500 < 20) {
    Serial.printf("Flex: T=%d I=%d M=%d R=%d P=%d\n",
      flex[0], flex[1], flex[2], flex[3], flex[4]);
  }

  // Classify gesture
  int detectedId = -1;
  for (int g = 0; g < NUM_GESTURES; g++) {
    bool match = true;
    for (int f = 0; f < 5; f++) {
      int lo = GESTURES[g].flexMin[f];
      int hi = GESTURES[g].flexMax[f];
      if (lo == DC) continue; // Don't care
      if (flex[f] < lo || flex[f] > hi) {
        match = false;
        break;
      }
    }
    if (match) {
      detectedId = GESTURES[g].id;
      break;
    }
  }

  // Send if new gesture or debounce expired
  unsigned long now = millis();
  if (detectedId != -1 && deviceConnected) {
    bool isNew    = (detectedId != lastGestureId);
    bool debounceOk = (now - lastSendMs > DEBOUNCE_MS);

    if (isNew || debounceOk) {
      char buf[4];
      snprintf(buf, sizeof(buf), "%02d", detectedId);
      pCharacteristic->setValue((uint8_t*)buf, strlen(buf));
      pCharacteristic->notify();

      Serial.printf("[BLE] Sent gesture ID: %s\n", buf);

      // OLED feedback
      char oledLine[20];
      snprintf(oledLine, sizeof(oledLine), "Gesture #%02d", detectedId);
      showOled("Sending...", oledLine);

      lastGestureId = detectedId;
      lastSendMs    = now;
    }
  } else if (detectedId == -1 && lastGestureId != -1) {
    lastGestureId = -1; // Reset when hand is neutral
  }

  if (!deviceConnected) {
    showOled("SignGlove_01", "No phone linked");
  }

  delay(50); // 20Hz sampling
}

// ─── OLED Helper ─────────────────────────────────────────────
void showOled(const char* line1, const char* line2) {
  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);
  display.setCursor(0, 4);
  display.println(line1);
  display.setTextSize(1);
  display.setCursor(0, 18);
  display.println(line2);
  display.display();
}
