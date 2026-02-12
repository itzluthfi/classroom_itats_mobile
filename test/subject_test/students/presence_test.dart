// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/academic_period.dart';
// import 'package:classroom_itats_mobile/models/lecture.dart';
// import 'package:classroom_itats_mobile/models/subject.dart';
// import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/lecture_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   late SubjectRepository subjectRepository;
//   late LectureRepository lectureRepository;
//   late AcademicPeriodRepository academicPeriodRepository;
//   late Subject subject;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     userRepository = UserRepository();
//     subjectRepository = SubjectRepository();
//     lectureRepository = LectureRepository();
//     academicPeriodRepository = AcademicPeriodRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Student Presence", () {
//     test("Login Lecture", () async {
//       var username = "06.2020.1.07351";
//       var password = "150300";

//       var token = await userRepository.login(username, password);

//       userRepository.presisteToken(token);
//       userRepository.saveRoleInfo("Mahasiswa");
//     });

//     test("Academic Periode Student", () async {
//       var academicPeriodes = await academicPeriodRepository.academicPeriod();

//       expect(academicPeriodes, isNotEmpty);
//       expect(academicPeriodes, isA<List<AcademicPeriod>>());

//       await academicPeriodRepository.initActiveAcademicPeriod(academicPeriodes);
//     });

//     test("Subject", () async {
//       var subjects = await subjectRepository.getSubjectsFiltered(
//           await academicPeriodRepository.getCurrentAcademicPeriod(), "");

//       expect(subjects, isNotEmpty);
//       expect(subjects, isA<List<Subject>>());

//       subject = subjects[0];
//     });

//     test("Student Presence Without Responsi", () async {
//       var studentPresences = await lectureRepository.getStudentLecture(
//           subject.academicPeriodId, subject.subjectId, subject.subjectClass);

//       expect(studentPresences, isNotNull);
//       expect(studentPresences, isA<Response<dynamic>>());

//       Map<String, dynamic> decodedData = studentPresences.data["data"];

//       expect(decodedData["material_lectures"] as List, isNotEmpty);
//       expect(decodedData["responsi_lectures"] as List, isEmpty);

//       var materialLectures = await lectureRepository
//           .setMaterialLecture(decodedData["material_lectures"] as List);

//       expect(materialLectures, isNotEmpty);
//       expect(materialLectures, isA<List<Lecture>>());
//     });

//     test("Subject", () async {
//       await academicPeriodRepository.setAcademicPeriod("20201");

//       var subjects = await subjectRepository.getSubjectsFiltered(
//           await academicPeriodRepository.getCurrentAcademicPeriod(), "");

//       expect(subjects, isNotEmpty);
//       expect(subjects, isA<List<Subject>>());

//       subject = subjects[2];
//     });

//     test("Student Presence With Responsi", () async {
//       var studentPresences = await lectureRepository.getStudentLecture(
//           subject.academicPeriodId, subject.subjectId, subject.subjectClass);

//       expect(studentPresences, isNotNull);
//       expect(studentPresences, isA<Response<dynamic>>());

//       Map<String, dynamic> decodedData = studentPresences.data["data"];

//       expect(decodedData["material_lectures"] as List, isNotEmpty);
//       expect(decodedData["responsi_lectures"] as List, isNotEmpty);

//       var materialLectures = await lectureRepository
//           .setMaterialLecture(decodedData["material_lectures"] as List);

//       expect(materialLectures, isNotEmpty);
//       expect(materialLectures, isA<List<Lecture>>());

//       var responsiLectures = await lectureRepository
//           .setResponsiLecture(decodedData["responsi_lectures"] as List);

//       expect(responsiLectures, isNotEmpty);
//       expect(responsiLectures, isA<List<List<Lecture>>>());
//     });
//   });
// }
