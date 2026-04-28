import 'package:classroom_itats_mobile/models/active_presence.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:classroom_itats_mobile/core/api_client.dart';

class PresensiRepository {
  final _dio = ApiClient.instance.dio;
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  Future<List<ActivePresence>> getActivePresences(String academicPeriod) async {
    final value = await storage.read(key: "token");
    final role = await storage.read(key: "role");
    String roleUrl = "";

    if (role == "Mahasiswa") {
      roleUrl = "students";
    } else if (role == "Dosen") {
      roleUrl = "lecturers";
    }

    try {
      Response response = await _dio.get(
        "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/$roleUrl/home/presences/active?period=$academicPeriod",
        options: Options(
          contentType: "application/json",
          headers: {"token": value},
        ),
      );

      final decodedData = response.data["data"] as List;
      final presences =
          decodedData.map((data) => ActivePresence.fromJson(data)).toList();
      return presences;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          return []; // Return empty list for 404
        }
        throw Exception("Failed to load active presences: ${e.message}");
      }
      throw Exception("An unexpected error occurred: $e");
    }
  }
}
