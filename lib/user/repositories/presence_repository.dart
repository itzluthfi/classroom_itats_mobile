import 'package:classroom_itats_mobile/models/presence.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PresenceRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<Response> getPresence(
      String academicPeriodId, String subjectId, String subjectClass) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/presences",
      data: {
        "academic_period": academicPeriodId,
        "subject_id": subjectId,
        "class": subjectClass,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    return response;
  }

  Future<List<Presence>> setMaterialPresence(List<dynamic> response) async {
    final presences = response.map((data) => Presence.fromJson(data)).toList();

    return presences;
  }

  Future<List<List<Presence>>> setResponsiPresence(
      List<dynamic> response) async {
    List<List<Presence>> presences = List.empty(growable: true);
    for (var element in response) {
      presences.add(
          (element as List).map((data) => Presence.fromJson(data)).toList());
    }

    return presences;
  }

  Future<List<PresenceQuestion>> getPresenceQuestion(
      String academicPeriodId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/presences/questions",
      data: {
        "academic_period": academicPeriodId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final presenceQuestions =
        decodedData.map((data) => PresenceQuestion.fromJson(data)).toList();

    return presenceQuestions;
  }

  Future<int> setStudentPresence(Object studentPresence) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/presences/present",
      data: studentPresence,
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
        validateStatus: (status) {
          return status! == 201;
        },
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }
}
