import 'package:classroom_itats_mobile/models/study_achievement.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudyAchievementRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<List<StudyAchievement>> getStudyAchievement(
      String academicPeriodId, String subjectId, String subjectClass) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/materials/achievements",
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

    final decodedData = response.data["data"] as List;

    final studyAchievements =
        decodedData.map((data) => StudyAchievement.fromJson(data)).toList();

    return studyAchievements;
  }
}
