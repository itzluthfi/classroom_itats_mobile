import 'package:classroom_itats_mobile/models/academic_period.dart';
import 'package:classroom_itats_mobile/core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcademicPeriodRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = ApiClient.instance.dio;

  Future<List<AcademicPeriod>> academicPeriod() async {
    final value = await storage.read(key: "token");
    final role = await storage.read(key: "role");
    String roleUrl = "";

    if (role == "Mahasiswa") {
      roleUrl = "students";
    }
    if (role == "Dosen") {
      roleUrl = "lecturers";
    }

    Response response = await _dio.get(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/$roleUrl/periodes",
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final academicPeriod =
        decodedData.map((data) => AcademicPeriod.fromJson(data)).toList();

    return academicPeriod;
  }

  Future<void> initActiveAcademicPeriod(
      List<AcademicPeriod> academicPeriodes) async {
    final prefs = await SharedPreferences.getInstance();

    String active = "";
    for (var academicPeriod in academicPeriodes) {
      if (academicPeriod.isActive == true) {
        active = academicPeriod.academicPeriodId;
      }
    }

    prefs.setString("active_academic_period", active);
    prefs.setString("current_academic_period", active);
  }

  Future<void> setAcademicPeriod(String academicPeriod) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("current_academic_period", academicPeriod);
  }

  Future<String> getCurrentAcademicPeriod() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("current_academic_period") ?? "";
  }

  Future<String> getActiveAcademicPeriod() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("active_academic_period") ?? "";
  }

  Future<bool> hasCurrentAcademicPeriod() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("current_academic_period") != null &&
        prefs.getString("current_academic_period") != "";
  }

  Future<bool> hasActiveAcademicPeriod() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("active_academic_period") != null &&
        prefs.getString("active_academic_period") != "";
  }
}
