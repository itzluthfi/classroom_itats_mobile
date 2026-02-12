import 'dart:io';

import 'package:classroom_itats_mobile/models/profile.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<Profile> getStudentProfile(String academicPeriod) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
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

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        HttpClient client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
        return client;
      },
    );

    Response response = await _dio.post(
      "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/api/students/profile/update",
      data: formData,
      options: Options(
        contentType: "application/x-www-form-urlencoded",
        headers: {
          "token": value,
        },
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }
}
