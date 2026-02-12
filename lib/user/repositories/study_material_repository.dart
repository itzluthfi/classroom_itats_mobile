import 'package:classroom_itats_mobile/models/study_material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudyMaterialRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<List<StudyMaterial>> getStudyMaterial(String academicPeriodId,
      String subjectId, String subjectClass, int weekId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/materials",
      data: {
        "academic_period": academicPeriodId,
        "subject_id": subjectId,
        "class": subjectClass,
        "week_id": weekId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final studyMaterials =
        decodedData.map((data) => StudyMaterial.fromJson(data)).toList();

    return studyMaterials;
  }

  Future<List<StudyMaterial>> getLecturerMaterials() async {
    final value = await storage.read(key: "token");

    Response response = await _dio.get(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/materials",
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final studyMaterials =
        decodedData.map((data) => StudyMaterial.fromJson(data)).toList();

    return studyMaterials;
  }

  Future<List<StudyMaterial>> getSelectedMaterial(String lectureId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/colleges/materials",
      data: {"lecture_id": lectureId},
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List<dynamic>;

    final studyMaterials =
        decodedData.map((data) => StudyMaterial.fromJson(data)).toList();

    return studyMaterials;
  }
}
