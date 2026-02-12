import 'dart:convert';
import 'dart:math';

import 'package:classroom_itats_mobile/models/percentage_score.dart';
import 'package:classroom_itats_mobile/models/student_score.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/views/lecturer/college_report/partials/subject_report_card.dart';
import 'package:classroom_itats_mobile/views/lecturer/home/partials/subject_card.dart';
import 'package:classroom_itats_mobile/views/student/home/partials/subject_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<List<Subject>> getSubjects() async {
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
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/$roleUrl/subjects",
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = jsonDecode(jsonEncode(response.data["data"])) as List;

    final subjects = decodedData.map((data) => Subject.fromJson(data)).toList();

    return subjects;
  }

  Future<List<Subject>> getSubjectsFiltered(
      String academicPeriod, String major) async {
    final value = await storage.read(key: "token");
    final role = await storage.read(key: "role");
    String roleUrl = "";

    if (role == "Mahasiswa") {
      roleUrl = "students";
    }
    if (role == "Dosen") {
      roleUrl = "lecturers";
    }

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/$roleUrl/subjects",
      data: major == ""
          ? {"period": academicPeriod}
          : {"period": academicPeriod, "major": major},
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final subjects = decodedData.map((data) => Subject.fromJson(data)).toList();

    return subjects;
  }

  Future<List<Subject>> getSubjectsFilter(
      String academicPeriod, String major) async {
    final value = await storage.read(key: "token");
    final role = await storage.read(key: "role");
    String roleUrl = "";

    if (role == "Mahasiswa") {
      roleUrl = "students";
    }
    if (role == "Dosen") {
      roleUrl = "lecturers";
    }

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/$roleUrl/subjects",
      data: major == ""
          ? {"period": academicPeriod}
          : {"period": academicPeriod, "major": major},
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final subjects = decodedData.map((data) => Subject.fromJson(data)).toList();

    return subjects;
  }

  Future<List<Widget>> subjectView(
      List<Subject> subjects, BuildContext context) async {
    List<Widget> data = List.empty(growable: true);
    final prefs = await SharedPreferences.getInstance();
    final role = await storage.read(key: "role");

    final img = prefs.getStringList("application_images");

    data.add(
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Text(
          "Anda Memiliki ${subjects.length} Mata Kuliah",
          softWrap: true,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    for (var subject in subjects) {
      if (role == "Mahasiswa") {
        data.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              StudentSubjectCard(
                imagePath:
                    "assets/application_images/${img![Random().nextInt(img.length - 1)]}.jpg",
                subject: subject,
                onTap: () {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) =>
                  //       StudentSubjectPage(subjectRepository: this),
                  // ));
                  // Navigator.of(context).pushReplacementNamed("/student/subject",
                  //     arguments: subject);R
                  Navigator.of(context)
                      .pushNamed("/student/subject", arguments: subject);
                },
              ),
            ],
          ),
        );
      }
      if (role == "Dosen") {
        data.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              LecturerSubjectCard(
                imagePath:
                    "assets/application_images/${img![Random().nextInt(img.length - 1)]}.jpg",
                subject: subject,
                onTap: () {
                  // Navigator.of(context).pushReplacementNamed(
                  //     "/lecturer/subject",
                  //     arguments: subject);
                  Navigator.of(context)
                      .pushNamed("/lecturer/subject", arguments: subject);
                },
              ),
            ],
          ),
        );
      }
      data.add(
        const Gap(12),
      );
    }

    return data;
  }

  Future<List<Widget>> subjectReportView(
      List<SubjectReport> subjects, BuildContext context) async {
    List<Widget> data = List.empty(growable: true);
    final prefs = await SharedPreferences.getInstance();

    final img = prefs.getStringList("application_images");

    data.add(
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: const Text(
          "Pelaporan Kuliah",
          softWrap: true,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    for (var subject in subjects) {
      data.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            LecturerSubjectReportCard(
              imagePath:
                  "assets/application_images/${img![Random().nextInt(img.length - 1)]}.jpg",
              subject: subject,
              onTap: () {
                // Navigator.of(context).pushReplacementNamed(
                //     "/lecturer/subject",
                //     arguments: subject);
                Navigator.of(context).pushNamed(
                    "/lecturer/college_report/detail",
                    arguments: subject);
              },
            ),
          ],
        ),
      );
      data.add(
        const Gap(12),
      );
    }

    return data;
  }

  Future<List<SubjectReport>> getSubjectReports() async {
    final value = await storage.read(key: "token");

    Response response = await _dio.get(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/subjects/reports",
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = jsonDecode(jsonEncode(response.data["data"])) as List;

    final subjects =
        decodedData.map((data) => SubjectReport.fromJson(data)).toList();

    return subjects;
  }

  Future<List<SubjectReport>> getSubjectReportsFiltered(
      String academicPeriod, String major) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/subjects/reports",
      data: major == ""
          ? {"period": academicPeriod}
          : {"period": academicPeriod, "major": major},
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final subjects =
        decodedData.map((data) => SubjectReport.fromJson(data)).toList();

    return subjects;
  }

  Future<List<StudentScore>> getStudentScore(
      String academicPeriodId, String subjectId, String subjectClass) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/studentScores",
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

    final decodedData = response.data["data"] as List;

    final studentScore =
        decodedData.map((data) => StudentScore.fromJson(data)).toList();

    return studentScore;
  }

  Future<PercentageScore> getPercentageScore(String activityMasterId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/percentages",
      data: {
        "master_activity_id": activityMasterId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"];

    final percentage = PercentageScore.fromJson(decodedData);

    return percentage;
  }
}
