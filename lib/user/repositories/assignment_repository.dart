import 'dart:io';

import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/models/score_type.dart';
import 'package:classroom_itats_mobile/models/week.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class AssignmentRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<List<Assignment>> getActiveAssignments(String period) async {
    final value = await storage.read(key: "token");

    String url =
        "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/home/assignments/active";
    if (period.isNotEmpty) {
      url += "?period=$period";
    }

    Response response = await _dio.get(
      url,
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

  Future<List<Assignment>> getStudyAssignment(
    String academicPeriod,
    String subjectId,
    String subjectClass,
  ) async {
    final value = await storage.read(key: "token");

    print("DEBUG getStudyAssignment: academicPeriod=$academicPeriod, subjectId=$subjectId, class=$subjectClass");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/materials/assignments",
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

    print("DEBUG getStudyAssignment: status = ${response.statusCode}");

    final decodedData = response.data["data"] as List;
    final assignments =
        decodedData.map((data) => Assignment.fromJson(data)).toList();

    print("DEBUG getStudyAssignment: parsed ${assignments.length} assignments");

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
    String academicPeriod,
    String subjectId,
    String subjectClass,
  ) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/students/subjects/scores",
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

  /// Mengunduh file menggunakan Android DownloadManager (via MethodChannel)
  /// sehingga file tersimpan di folder Download bawaan device (/storage/emulated/0/Download/).
  /// Tidak memerlukan permission WRITE_EXTERNAL_STORAGE apapun.
  /// Mengembalikan nama file jika berhasil antri download, null jika gagal.
  Future<String?> downloadAssignmentFile(String fileLink, String fileName) async {
    // === NORMALISASI URL ===
    final String fullUrl;
    if (fileLink.startsWith('http://') || fileLink.startsWith('https://')) {
      fullUrl = fileLink;
    } else {
      final webHost = dotenv
          .get('WEB_URL', fallback: '')
          .replaceAll(RegExp(r'^https?://'), '')
          .replaceAll('"', '')
          .trim();
      fullUrl = 'https://$webHost/storage/$fileLink';
    }

    print("[DOWNLOAD] URL asli  : $fileLink");
    print("[DOWNLOAD] URL final : $fullUrl");
    print("[DOWNLOAD] File name : $fileName");

    try {
      if (Platform.isAndroid) {
        // Gunakan Android DownloadManager → menyimpan langsung ke /storage/emulated/0/Download/
        // tanpa permission apapun.
        const channel = MethodChannel('com.itats.classroom/download');
        final downloadId = await channel.invokeMethod<String>('downloadFile', {
          'url': fullUrl,
          'fileName': fileName,
          'title': fileName,
        });
        print("[DOWNLOAD] DownloadManager ID: $downloadId");
        // downloadId non-null = berhasil di-queue oleh sistem
        return downloadId != null ? fileName : null;
      } else {
        // iOS / Desktop: fallback ke Dio + app documents directory
        final docsDir = await getApplicationDocumentsDirectory();
        _dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          },
        );
        final response = await _dio.get(
          fullUrl,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (s) => s != null && s >= 200 && s < 300,
          ),
        );
        final file = File('${docsDir.path}/$fileName');
        final raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();
        print("[DOWNLOAD] Berhasil (iOS)! Disimpan di: ${file.path}");
        return file.path;
      }
    } catch (e) {
      print("[DOWNLOAD] Exception: $e");
      print("[DOWNLOAD] URL: $fullUrl");
      return null;
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



    // Force HTTPS — WEB_URL harus tanpa protocol, kita hardcode https://
    final webUrl = dotenv.get("WEB_URL").replaceAll(RegExp(r'^https?://'), '');
    final submitUrl = "https://$webUrl/api/students/assignments/submit";

    try {
      Response response = await _dio.post(
        submitUrl,
        data: formData,
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            "token": value,
            "Accept": "application/json",
            "User-Agent": "ClassroomItatsMobileApp/1.0",
          },
        ),
      );

      print("======== API SUBMIT RESPONSE ========");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");
      print("=====================================");

      final decodedData = response.statusCode ?? 0;
      return decodedData;
    } catch (e) {
      if (e is DioException) {
        print("======== API SUBMIT ERROR ========");
        print("Status Code: ${e.response?.statusCode}");
        print("Response Data: ${e.response?.data}");
        print("Type: ${e.type}");
        print("Message: ${e.message}");
        print("Error: ${e.error}");
        print("================================");
      } else {
        print("Error submitting assignment: $e");
      }
      return 0; // Kembalikan 0 sebagai tanda gagal (akan diproses di BLoC).
    }
  }
}