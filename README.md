# Classroom ITATS Mobile

Project ini adalah aplikasi mobile untuk Classroom ITATS yang dibangun menggunakan Flutter.

## Prasyarat

- **Flutter SDK**: Versi >= 3.1.0 (Disarankan versi terbaru stabil, misal 3.10+ atau 3.13+)
- **Dart SDK**: Paket dalam Flutter
- **Android Studio / VS Code**: Dengan plugin Flutter dan Dart terinstall
- **Device/Emulator**: Android atau iOS

## Struktur Project

- `lib/`: Kode utama aplikasi Dart/Flutter.
  - `main.dart`: Entry point aplikasi.
  - `auth/`, `user/`, `views/`: Modul fitur aplikasi.
- `android/`: Konfigurasi native Android.
- `ios/`: Konfigurasi native iOS.

## Cara Setup

Ikuti langkah-langkah berikut untuk menjalankan project ini di local machine Anda.

### 1. Install Dependencies

Jalankan perintah berikut di terminal root project:

```bash
flutter pub get
```

### 2. Konfigurasi Environment Variable (.env)

Project ini membutuhkan file `.env` di root directory untuk konfigurasi API dan Firebase. Buat file bernama `.env` dan isi dengan template berikut (sesuaikan value dengan kredensial yang Anda miliki):

```env
# Konfigurasi API Server
API_PROTOCOL=https://
API_URL=classroom.itats.ac.id
API_BASEPATH=/api

# Konfigurasi Firebase (Dapatkan dari Firebase Console Project Settings)
# VAPID_KEY digunakan sebagai apiKey di konfigurasi manual
VAPID_KEY=your_firebase_api_key_or_vapid_key
ANDROID_APP_ID=your_android_app_id
SENDER_ID=your_messaging_sender_id
```

> **Catatan**:
>
> - `API_PROTOCOL`, `API_URL`, `API_BASEPATH` digunakan untuk menyusun endpoint request.
> - `VAPID_KEY`, `ANDROID_APP_ID`, `SENDER_ID` digunakan untuk inisialisasi Firebase secara manual di `main.dart`. Pastikan data ini sesuai dengan project Firebase Anda.

### 3. Konfigurasi Firebase Native

Selain konfigurasi `.env`, pastikan file konfigurasi native Firebase sudah tersedia di lokasi berikut:

- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

Jika belum ada, unduh dari Firebase Console dan letakkan di lokasi tersebut.

### 4. Konfigurasi Signing (Release Build)

Untuk keperluan build release (APK/AAB), project ini membutuhkan Keystore.
File berikut **SUDAH** saya pindahkan ke folder `android/` agar sesuai dengan konfigurasi Gradle:

- `android/key.properties`
- `android/upload-keystore.jks`

Pastikan kedua file ini selalu ada di folder `android/` jika Anda ingin melakukan build release.

### 5. Menjalankan Aplikasi

Pastikan device atau emulator sudah terhubung.

```bash
flutter run
```

Jika ada masalah sertifikat SSL (self-signed), aplikasi sudah memiliki `HttpOverrides` di `main.dart` untuk mengizinkan sertifikat yang tidak valid (bad certificate), namun ini hanya untuk development.

## Catatan Tambahan

- **Global HTTP Override**: Aplikasi menggunakan `MyHttpOverrides` global yang mengabaikan validasi SSL. Hati-hati untuk production.
- **Permissions**: Aplikasi akan meminta izin notifikasi dan penyimpanan saat pertama kali dijalankan.

---

Dibuat berdasarkan analisa codebase otomatis.
