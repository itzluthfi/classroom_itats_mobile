// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/academic_period.dart';
// import 'package:classroom_itats_mobile/models/study_achievement.dart';
// import 'package:classroom_itats_mobile/models/study_material.dart';
// import 'package:classroom_itats_mobile/models/subject.dart';
// import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
// // import 'package:classroom_itats_mobile/user/repositories/lecture_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/study_achievement_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/study_material_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   late SubjectRepository subjectRepository;
//   late StudyAchievementRepository studyAchievementRepository;
//   late StudyMaterialRepository studyMaterialRepository;
//   late AcademicPeriodRepository academicPeriodRepository;
//   // late LectureRepository lectureRepository;
//   late Subject subject;
//   // late StudyMaterial studyMaterial;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     userRepository = UserRepository();
//     subjectRepository = SubjectRepository();
//     studyAchievementRepository = StudyAchievementRepository();
//     studyMaterialRepository = StudyMaterialRepository();
//     academicPeriodRepository = AcademicPeriodRepository();
//     // lectureRepository = LectureRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Student Material", () {
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

//     test("Student Material", () async {
//       var studentMaterials =
//           await studyAchievementRepository.getStudyAchievement(
//               subject.academicPeriodId,
//               subject.subjectId,
//               subject.subjectClass);

//       expect(studentMaterials, isNotEmpty);
//       expect(studentMaterials, isA<List<StudyAchievement>>());
//     });

//     test("Student Study Material", () async {
//       var studentStudyMaterials =
//           await studyMaterialRepository.getStudyMaterial(
//               subject.academicPeriodId,
//               subject.subjectId,
//               subject.subjectClass,
//               1);

//       expect(studentStudyMaterials, isNotEmpty);
//       expect(studentStudyMaterials, isA<List<StudyMaterial>>());

//       // studyMaterial = studentStudyMaterials.first;
//     });

//     // test("Download Student Study Material", () async {
//     //   await lectureRepository.downloadMaterialFile(studyMaterial.materialLink);
//     // });
//   });
// }
