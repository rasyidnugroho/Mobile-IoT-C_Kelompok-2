#include <Arduino.h>

#include <Adafruit_Sensor.h> // Library pendukung sensor DHT11
#include <DHT.h> // Library Sensor DHT11
#include <ESP8266WiFi.h> // Library untuk menggunakan WiFi NodeMCU
#include <FirebaseESP8266.h> // Library untuk menghubungkan ke Firebase
#include <addons/RTDBHelper.h> // Library untuk mengelola Database
#include <NTPClient.h> // Library Network Time Protocol untuk membuat timestamp
#include <WiFiUdp.h>
#include <WiFiClientSecure.h>


// Konfigurasi Jaringan
WiFiClient client;

const char* ssid = "Cahyo_Home"; // WiFi 1
const char* pass = "cahyo1234";


// Konfigurasi SpreadSheet trigger
const char* sheetHost = "script.google.com";


// Konfigurasi Firebase
#define DATABASE_URL "mobile-iot-c-default-rtdb.asia-southeast1.firebasedatabase.app" // URL Database Firebase
FirebaseData fbdo; // Firebase Data Object
FirebaseAuth auth; // Autentikasi ke Firebase
FirebaseConfig config; // Konfigurasi koneksi ke Firebase


// Sensor DHT
#define DHTPIN D1 // Pin Signal DHT pada NodeMCU
#define DHTTYPE DHT11 // Tipe sensor DHT
DHT sensorDHT(DHTPIN, DHTTYPE); // Objek DHT


// Variabel timestamp
WiFiUDP ntpUDP;
NTPClient time_client(ntpUDP, "pool.ntp.org");


// Variabel umum
unsigned long lastTime = 0;
unsigned long timerDelay = 10000;
int updateSequence = 0;



void setup() {
  Serial.begin(9600);

  // Melakukan koneksi ke jaringan
  WiFi.begin(ssid, pass);
  Serial.print("Menghubungkan ke jaringan ");
  while(WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Terhubung ke  : ");
  Serial.println(WiFi.SSID());
  Serial.print("IP Address    : ");
  Serial.println(WiFi.localIP());

  // Menjalankan Sensor DHT
  sensorDHT.begin();

  // Koneksi ke Firebase
  config.database_url = DATABASE_URL;
  config.signer.test_mode = true;
  Firebase.reconnectWiFi(true);
  Firebase.begin(&config, &auth);

  // Inisialisasi NTPClient untuk memperoleh waktu
  time_client.begin();
  time_client.setTimeOffset(25200); // Offset GMT +7 Jakarta = 25200 detik
}




void loop() {
  time_client.update();

  // Variabel nilai kelembaban dan Suhu
  float kelembaban = sensorDHT.readHumidity();
  float suhu = sensorDHT.readTemperature();


  if ((millis() - lastTime) > timerDelay)
  {
    // Membuat TimeStamp
    time_t epochTime = time_client.getEpochTime();
    String formattedTime = time_client.getFormattedTime();
    struct tm *ptm = gmtime ((time_t *)&epochTime);
    int monthDay = ptm->tm_mday;
    int currentMonth = ptm->tm_mon+1;
    int currentYear = ptm->tm_year+1900;

    String timestamp = String(currentYear) + "-" + String(currentMonth) + "-" + String(monthDay) + " " + formattedTime;


    Serial.println(timestamp);
    Serial.print("Update Data ke - ");
    Serial.println(++updateSequence);

    // Mencetak nilai Kelembaban pada Serial
    Serial.print("    Kelembaban  : ");
    Serial.print(kelembaban);
    Serial.println(" %");

    // Mencetak nilai Suhu pada Serial
    Serial.print("    Suhu        : ");
    Serial.print(suhu);
    Serial.println(" Celcius");
    Serial.println();

    // Jika terhubung ke jaringan
    if(WiFi.status() == WL_CONNECTED)
    {
      if (Firebase.setString(fbdo, "/data/sensor/updated_at", timestamp)){
        Serial.println("    Firebase - updated_at : BERHASIL UPDATE DATA");
        if (Firebase.setInt(fbdo, "/data/sensor/kelembaban", kelembaban))
        {
          Serial.println("             - kelembaban : BERHASIL UPDATE DATA");
          if (Firebase.setFloat(fbdo, "/data/sensor/suhu", suhu))
          {
            Serial.println("             - suhu       : BERHASIL UPDATE DATA");
            WiFiClientSecure secureClient;
            const int httpPort = 443;
            secureClient.setInsecure();
            if (!secureClient.connect(sheetHost, httpPort)) { //works!
              Serial.println("\n\nKoneksi ke SpreadSheet gagal !!!\n\n");
              return;
            }
            String url = "/macros/s/AKfycbyoOHUYBoFOZEeDbWkeFcuEJyp4h2Nssnhpk5qliugwz5M3SC1Y5QeAsD6kcXP2VGuRTg/exec?trigger=true";
            secureClient.print(String("GET ") + url + " HTTP/1.1\r\n"+"Host: " + sheetHost + "\r\n" + "Connection: close\r\n\r\n");
          } else
          {
            Serial.print("             - suhu       : GAGAL UPDATE DATA");
            Serial.println(fbdo.errorReason().c_str());
            Serial.println("\n\n");
          }
        } else
        {
          Serial.print("             - kelembaban : GAGAL UPDATE DATA");
          Serial.println(fbdo.errorReason().c_str());
          Serial.println("\n\n");
        }
      } else
      {
        Serial.print("    Firebase - updated_at : GAGAL UPDATE DATA");
        Serial.println(fbdo.errorReason().c_str());
        Serial.println("\n\n");
      }


    }
    else
    {
      // Jika terputus dari jaringan
      Serial.print("Koneksi Jaringan Terputus!!!\n");
      Serial.print("Mencoba menghubungkan kembali...");
      while(WiFi.status() != WL_CONNECTED)
      {
        Serial.print(".");
        delay(1000);
      }
      Serial.println();
      Serial.print("Terhubung ke  : ");
      Serial.println(WiFi.SSID());
      Serial.print("IP Address    : ");
      Serial.println(WiFi.localIP());
    }
    lastTime = millis();
  }
}