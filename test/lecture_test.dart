// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/academic_period.dart';
// import 'package:classroom_itats_mobile/models/lecture.dart';
// import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/lecture_repository.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   late LectureRepository lectureRepository;
//   late AcademicPeriodRepository academicPeriodRepository;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     academicPeriodRepository = AcademicPeriodRepository();
//     userRepository = UserRepository();
//     lectureRepository = LectureRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Lecture Student", () {
//     test("Login Student", () async {
//       var username = "06.2020.1.07351";
//       var password = "150300";

//       var token = await userRepository.login(username, password);

//       expect(token, isNotNull);

//       userRepository.presisteToken(token);
//       userRepository.saveRoleInfo("Mahasiswa");
//     });

//     test("Academic Periode Student", () async {
//       var academicPeriodes = await academicPeriodRepository.academicPeriod();

//       expect(academicPeriodes, isNotEmpty);
//       expect(academicPeriodes, isA<List<AcademicPeriod>>());

//       academicPeriodRepository.initActiveAcademicPeriod(academicPeriodes);
//     });

//     test("Lecture Student Without Responsi", () async {
//       var lectures = await lectureRepository.getStudentLecture(
//         await academicPeriodRepository.getActiveAcademicPeriod(),
//         "21064603",
//         "P2",
//       );

//       expect(lectures.data["data"], isNotEmpty);
//       expect(lectures, isA<Response>());

//       Map<String, dynamic> decodedData = lectures.data["data"];

//       var materialLectures = await lectureRepository.setMaterialLecture(
//           decodedData["material_lectures"] as List<dynamic>);

//       expect(materialLectures, isNotEmpty);
//       expect(materialLectures, isA<List<Lecture>>());

//       var responsiLectures = await lectureRepository.setResponsiLecture(
//           decodedData["responsi_lectures"] as List<dynamic>);

//       expect(responsiLectures, isEmpty);
//     });

//     test("Lecture Student With Responsi", () async {
//       await academicPeriodRepository.setAcademicPeriod("20201");

//       var lectures = await lectureRepository.getStudentLecture(
//           await academicPeriodRepository.getCurrentAcademicPeriod(),
//           "16001409",
//           "P6");

//       expect(lectures.data["data"], isNotEmpty);
//       expect(lectures, isA<Response>());

//       Map<String, dynamic> decodedData = lectures.data["data"];

//       var materialLectures = await lectureRepository.setMaterialLecture(
//           decodedData["material_lectures"] as List<dynamic>);

//       expect(materialLectures, isNotEmpty);
//       expect(materialLectures, isA<List<Lecture>>());

//       var responsiLectures = await lectureRepository.setResponsiLecture(
//           decodedData["responsi_lectures"] as List<dynamic>);

//       expect(responsiLectures, isNotEmpty);
//     });
//   });

//   group("Lecture Lecturer", () {
//     test("Login Lecture", () async {
//       var username = "173132";
//       var password = "rosetya*173132";

//       var token = await userRepository.login(username, password);

//       userRepository.presisteToken(token);
//       userRepository.saveRoleInfo("Dosen");
//     });

//     test("Academic Periode Lecturer", () async {
//       var academicPeriodes = await academicPeriodRepository.academicPeriod();

//       expect(academicPeriodes, isNotEmpty);
//       expect(academicPeriodes, isA<List<AcademicPeriod>>());

//       await academicPeriodRepository.initActiveAcademicPeriod(academicPeriodes);
//     });

//     test("Lecture Lecturer Without Responsi", () async {
//       var lectures = await lectureRepository.getLecture(
//         await academicPeriodRepository.getActiveAcademicPeriod(),
//         "21064603",
//         "P2",
//       );

//       expect(lectures, isNotEmpty);
//       expect(lectures, isA<List<List<Lecture>>>());
//       for (var lecture in lectures) {
//         expect(lecture.length, equals(1));
//       }
//     });

//     test("Lecture Lecturer With Responsi", () async {
//       await academicPeriodRepository.setAcademicPeriod("20202");

//       var lectures = await lectureRepository.getLecture(
//         await academicPeriodRepository.getCurrentAcademicPeriod(),
//         "16064304",
//         "P1",
//       );

//       expect(lectures, isNotEmpty);
//       expect(lectures, isA<List<List<Lecture>>>());
//       for (var lecture in lectures) {
//         if (lecture[0].weekID != 8 && lecture[0].weekID != 16) {
//           expect(lecture.length, equals(2));
//         } else {
//           expect(lecture.length, equals(1));
//         }
//       }
//     });
//   });
// }
