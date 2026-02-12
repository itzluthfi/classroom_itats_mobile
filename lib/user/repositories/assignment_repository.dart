import 'dart:io';

import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/models/score_type.dart';
import 'package:classroom_itats_mobile/models/week.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AssignmentRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<List<Assignment>> getStudyAssignment(String masterActivityId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/materials/assignments",
      data: {
        "master_activity_id": masterActivityId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final assignments =
        decodedData.map((data) => Assignment.fromJson(data)).toList();

    return assignments;
  }

  Future<List<StudentAssignmentJoin>> getStudyAssignmentWeek(
      String masterActivityId, int weekId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/materials/assignments/detail",
      data: {"master_activity_id": masterActivityId, "week_id": weekId},
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final assignments = decodedData
        .map((data) => StudentAssignmentJoin.fromJson(data))
        .toList();

    return assignments;
  }

  Future<List<Assignment>> getLecturerCreatedAssignment(
      String academicPeriodId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/assignments",
      data: {
        "academic_period_id": academicPeriodId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final assignments =
        decodedData.map((data) => Assignment.fromJson(data)).toList();

    return assignments;
  }

  Future<StudentAssignmentSubmission?> getStudentSubmitedAssignment(
      int assignmentId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/materials/assignments/submited",
      data: {
        "assignment_id": assignmentId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"];

    if (decodedData["assignment_id"] == 0 &&
        decodedData["assignment_submission_id"] == 0 &&
        decodedData["student_id"] == "") {
      return null;
    }

    final studentAssignmentSubmission =
        StudentAssignmentSubmission.fromJson(decodedData);

    return studentAssignmentSubmission;
  }

  Future<List<StudentAssignmentScore>> getStudentAssignmentScore(
      String masterActivityId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/scores",
      data: {
        "master_activity_id": masterActivityId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final studentAssignmentScores = decodedData
        .map((data) => StudentAssignmentScore.fromJson(data))
        .toList();

    return studentAssignmentScores;
  }

  Future<List<Week>> getWeekAssignment() async {
    final value = await storage.read(key: "token");

    Response response = await _dio.get(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/assignments/weeks",
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final weekAssignment =
        decodedData.map((data) => Week.fromJson(data)).toList();

    return weekAssignment;
  }

  Future<List<ScoreType>> getScoreType() async {
    final value = await storage.read(key: "token");

    Response response = await _dio.get(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/assignments/scoreType",
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final scoreType =
        decodedData.map((data) => ScoreType.fromJson(data)).toList();

    return scoreType;
  }

  Future<int> downloadAssignmentFile(String fileLink, String fileName) async {
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
        fileLink,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! == 200;
            }),
      );

      File file = File("${downloadDir!.path}/$fileName");
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();

      return response.statusCode ?? 404;
    } catch (e) {
      return 500;
    }
  }

  Future<int> createAssignment(
    String activityMasterId,
    String weekId,
    String scoreType,
    String assignmentTitle,
    String assignmentDescription,
    String dueDate,
    String isShow,
    String filepath,
    String filename,
  ) async {
    final value = await storage.read(key: "token");

    var formData = FormData.fromMap({
      "master_kegiatan_id": activityMasterId,
      "weekid": weekId,
      "judul_tugas": assignmentTitle,
      "deskripsi": assignmentDescription,
      "batas_pengumpulan": dueDate,
      "jnilid": scoreType,
      "is_tampil": isShow,
    });

    if (filepath != "" && filename != "") {
      formData = FormData.fromMap({
        "master_kegiatan_id": activityMasterId,
        "weekid": weekId,
        "judul_tugas": assignmentTitle,
        "deskripsi": assignmentDescription,
        "batas_pengumpulan": dueDate,
        "jnilid": scoreType,
        "is_tampil": isShow,
        "file_tugas":
            await MultipartFile.fromFile(filepath, filename: filename),
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
      "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/api/lecturers/assignments/create",
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

  Future<int> submitAssignment(
    int assignmentId,
    String note,
    String filepath,
    String filename,
  ) async {
    final value = await storage.read(key: "token");

    var formData = FormData.fromMap({
      "id_tugas_kul": assignmentId,
      "note": note,
    });

    if (filepath != "" && filename != "") {
      formData = FormData.fromMap({
        "id_tugas_kul": assignmentId,
        "note": note,
        "file_tugas":
            await MultipartFile.fromFile(filepath, filename: filename),
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
      "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/api/students/assignments/submit",
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
