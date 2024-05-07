#include <ESP8266WiFi.h>
#include <PubSubClient.h>

#define WIFI_SSID       "EMLI-TEAM-16"
#define WIFI_PASSWORD   "emliemli"
#define MQTT_SERVER     "10.0.0.10"
#define MQTT_SERVERPORT 1883
#define MQTT_TOPIC      "/trigger/external"

#define GPIO_PULLUP_PIN 4
#define DEBOUNCE_TIME   100

WiFiClient espClient;
PubSubClient mqtt(espClient);

void mqtt_connect() {
  while (!mqtt.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (mqtt.connect("ESP8266Client")) {
      Serial.println("Broker connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(mqtt.state());
      Serial.println(" ");
      delay(3000);
    }
  }
}

void print_wifi_status() {
  Serial.println(" ");
  Serial.print(" WiFi connected: ");
  Serial.print(WiFi.SSID());
  Serial.print(" ");
  Serial.print(WiFi.localIP());
  Serial.print(" RSSI: ");
  Serial.print(WiFi.RSSI());
  Serial.println(" dBm");
}

void setup() {
  Serial.begin(115200);
  Serial.print("Boot");
  
  pinMode(GPIO_PULLUP_PIN, INPUT_PULLUP);

  WiFi.persistent(false);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  if (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect to WiFi...");
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }
  }
  
  print_wifi_status();

  mqtt.setServer(MQTT_SERVER, MQTT_SERVERPORT);
  mqtt_connect();
}

void publish_data() {
  Serial.println("Sending trigger");
  if (WiFi.status() == WL_CONNECTED && mqtt.connected()) {
    if (mqtt.publish(MQTT_TOPIC, "1")) {
      Serial.println("MQTT ok");
    } else {
      Serial.print("MQTT failed");
      mqtt_connect();
    }
  } else {
    Serial.println("Not connected to MQTT");
    mqtt_connect();
  }
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Wi-Fi disconnected. Reconnecting...");
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }
    Serial.println("WiFi reconnected");
    print_wifi_status();
    mqtt_connect();
  }

  if  (!mqtt.connected() && WiFi.status()) {
    Serial.println("Mosquitto broker disconnected. Reconnecting..."); 
    mqtt_connect();
  }

  if (digitalRead(GPIO_PULLUP_PIN) == LOW) {
    Serial.println("Button Pressed!");
    publish_data();
    delay(2000);
  }
}
