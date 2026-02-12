import 'package:classroom_itats_mobile/models/major.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MajorRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<List<Major>> getLecturerMajors(String period) async {
    final value = await storage.read(key: "token");
    List<Major> major;

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/majors",
      data: {"period": period},
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    major = decodedData.map((data) => Major.fromJson(data)).toList();

    major.add(Major(
        majorId: "",
        realMajorId: "",
        majorName: "Semua Jurusan",
        studyProgramName: ""));

    return major;
  }

  Future<void> setlecturerMajor(String major) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("lecturer_major", major);
  }

  Future<String> getlecturerMajor() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("lecturer_major") ?? "";
  }
}
