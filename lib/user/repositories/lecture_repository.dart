import 'dart:io';

import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/week.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LectureRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<List<Lecture>> getLectureWeeks(
      String academicPeriod, String subjectId, String subjectClass) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/materials/weeks",
      data: {
        "academic_period": academicPeriod,
        "subject_id": subjectId,
        "class": subjectClass,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List<dynamic>;

    var lectures = decodedData.map((data) => Lecture.fromJson(data)).toList();

    return lectures;
  }

  Future<List<List<Lecture>>> getLecture(
      String academicPeriodId, String subjectId, String subjectClass) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/subjects/lectures",
      data: {
        "academic_period_id": academicPeriodId,
        "subject_id": subjectId,
        "subject_class": subjectClass,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List<dynamic>;

    List<List<Lecture>> lectures = List.empty(growable: true);

    for (var element in decodedData) {
      if (element is List<dynamic>) {
        var lecture = element.map((data) => Lecture.fromJson(data)).toList();
        lectures.add(lecture);
      }
    }

    return lectures;
  }

  Future<Response> getStudentLecture(
      String academicPeriodId, String subjectId, String subjectClass) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/lectures",
      data: {
        "academic_period_id": academicPeriodId,
        "subject_id": subjectId,
        "subject_class": subjectClass,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    return response;
  }

  Future<List<Lecture>> setMaterialLecture(List<dynamic> response) async {
    final presences = response.map((data) => Lecture.fromJson(data)).toList();

    return presences;
  }

  Future<List<List<Lecture>>> setResponsiLecture(List<dynamic> response) async {
    List<List<Lecture>> presences = List.empty(growable: true);
    for (var element in response) {
      presences.add(
          (element as List).map((data) => Lecture.fromJson(data)).toList());
    }

    return presences;
  }

  Future<int> downloadMaterialFile(String fileLink) async {
    Directory? downloadDir;

    if (Platform.isAndroid) {
      downloadDir = Directory("/storage/emulated/0/Download");
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

    try {
      Response response = await _dio.get(
        "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/storage/$fileLink",
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! == 200;
            }),
      );

      List<String> filename = fileLink.split('/');
      File file = File("${downloadDir!.path}/${filename.last}");

      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();

      return response.statusCode ?? 404;
    } catch (e) {
      return 500;
    }
  }

  Future<Map<String, dynamic>?> getLectureRps(String mkId, String weekId) async {
    try {
      final value = await storage.read(key: "token");
      Response response = await _dio.get(
        "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/colleges/rps?mkid=$mkId&weekid=$weekId",
        options: Options(
          contentType: "application/json",
          headers: {"token": value},
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data["data"] as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Week>> getTeamWeeks(String academicPeriodId, String mkId, String subjectClass) async {
    try {
      final value = await storage.read(key: "token");
      Response response = await _dio.post(
        "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/colleges/team-weeks",
        data: {
          "academic_period_id": academicPeriodId,
          "mkid": mkId,
          "kelas": subjectClass,
        },
        options: Options(
          contentType: "application/json",
          headers: {"token": value},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final decodedData = response.data["data"] as List;
        return decodedData.map((data) => Week.fromJson(data)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<Lecture>> getLectureReport(String subjectId, String subjectClass,
      String hourId, String collegeType) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/colleges/reports",
      data: {
        "mkID": subjectId,
        "class": subjectClass,
        "hourID": hourId,
        "collegeType": collegeType
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List<dynamic>;

    List<Lecture> lectures =
        decodedData.map((data) => Lecture.fromJson(data)).toList();

    return lectures;
  }

  Future<Lecture> getDetailLectureReport(String lectureId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/colleges/reports/detail",
      data: {
        "kulid": lectureId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as dynamic;

    Lecture lecture = Lecture.fromJson(decodedData);

    return lecture;
  }

  Future<int> storeLectureReport(
    String academicPeriodId,
    String subjectId,
    String majorId,
    String lecturerId,
    String subjectClass,
    String lectureSchedule,
    String lectureType,
    int subjectCredit,
    String hourId,
    List<Map<String, String>> material,
    String entryTime,
    int approvalStatus,
    int weekId,
    int timeRealization,
    String materialRealization,
    String presenceLimit,
    int collegeType,
  ) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/colleges/reports/store",
      data: {
        "lecture": {
          "lecture_id": "",
          "lecturer_id": "",
          "major_id": majorId,
          "subject_id": subjectId,
          "subject_class": subjectClass,
          "hour_id": hourId,
          "lecture_type": lectureType,
          "time_realization": timeRealization,
          "week_id": weekId,
          "subject_credit": subjectCredit,
          "academic_period_id": academicPeriodId,
          "lecture_schedule": lectureSchedule,
          "approval_status": approvalStatus,
          "entry_time": entryTime,
          "material_realization": materialRealization,
          "presence_limit": presenceLimit,
          "college_type": collegeType
        },
        "material": material,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }

  Future<int> editLectureReport(
    String lectureId,
    String academicPeriodId,
    String subjectId,
    String majorId,
    String lecturerId,
    String subjectClass,
    String lectureSchedule,
    String lectureType,
    int subjectCredit,
    String hourId,
    List<Map<String, String>> material,
    String entryTime,
    int approvalStatus,
    int weekId,
    int timeRealization,
    String materialRealization,
    String presenceLimit,
    int collegeType,
  ) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.put(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/colleges/reports/edit",
      data: {
        "lecture": {
          "lecture_id": lectureId,
          "lecturer_id": lecturerId,
          "major_id": majorId,
          "subject_id": subjectId,
          "subject_class": subjectClass,
          "hour_id": hourId,
          "lecture_type": lectureType,
          "time_realization": timeRealization,
          "week_id": weekId,
          "subject_credit": subjectCredit,
          "academic_period_id": academicPeriodId,
          "lecture_schedule": lectureSchedule,
          "approval_status": approvalStatus,
          "entry_time": entryTime,
          "material_realization": materialRealization,
          "presence_limit": presenceLimit,
          "college_type": collegeType
        },
        "material": material,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }

  Future<int> deleteLectureReport(
    String lectureId,
  ) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.delete(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/colleges/reports/delete",
      data: {
        "lecture_id": lectureId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }
}
