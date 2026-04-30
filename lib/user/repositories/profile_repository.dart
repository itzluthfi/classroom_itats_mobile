import 'dart:io';

import 'package:classroom_itats_mobile/models/profile.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:classroom_itats_mobile/core/api_client.dart';

class ProfileRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  Future<Profile> getStudentProfile(String academicPeriod) async {
    final value = await storage.read(key: "token");

    Response response = await ApiClient.instance.dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/profile",
      data: {
        "academic_period_id": academicPeriod,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"];

    final profile = Profile.fromJson(decodedData);

    return profile;
  }

  Future<int> updateStudentProfile(String email, String phoneNumber,
      String filepath, String filename) async {
    final value = await storage.read(key: "token");

    var formData = FormData.fromMap({
      "email": email,
      "mobile": phoneNumber,
    });

    if (filepath != "" && filename != "") {
      formData = FormData.fromMap({
        "email": email,
        "mobile": phoneNumber,
        "foto": await MultipartFile.fromFile(filepath, filename: filename),
      });
    }

    // Gunakan Dio terpisah dengan SSL bypass untuk multipart upload ke web server
    final uploadDio = Dio();
    uploadDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        HttpClient client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
        return client;
      },
    );

    // Force HTTPS — hapus protocol dari WEB_URL jika ada, lalu tambahkan https://
    final rawWebUrl = dotenv.get("WEB_URL", fallback: "").replaceAll(RegExp(r'^https?://'), '').trim();
    final uploadUrl = "https://$rawWebUrl/api/students/profile/update";

    try {
      Response response = await uploadDio.post(
        uploadUrl,
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
          validateStatus: (status) => status != null && status < 500,
          headers: {
            "token": value,
            "Accept": "application/json",
          },
        ),
      );

      return response.statusCode ?? 0;
    } catch (e) {
      print("[UPDATE PROFILE] Exception: $e");
      return 0;
    }
  }

}
