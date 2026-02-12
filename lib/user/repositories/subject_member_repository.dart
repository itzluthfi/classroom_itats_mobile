import 'package:classroom_itats_mobile/models/subject_member.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SubjectMemberRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<List<SubjectMember>> getSubjectMember(String academicPeriodId,
      String subjectId, String subjectClass, String majorId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/subjects/members",
      data: {
        "academic_period": academicPeriodId,
        "subject_id": subjectId,
        "class": subjectClass,
        "major_id": majorId
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final subjectMembers =
        decodedData.map((data) => SubjectMember.fromJson(data)).toList();

    return subjectMembers;
  }
}
