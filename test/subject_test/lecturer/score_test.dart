// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/academic_period.dart';
// import 'package:classroom_itats_mobile/models/student_score.dart';
// import 'package:classroom_itats_mobile/models/subject.dart';
// import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   late SubjectRepository subjectRepository;
//   late AcademicPeriodRepository academicPeriodRepository;
//   late Subject subject;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     userRepository = UserRepository();
//     subjectRepository = SubjectRepository();
//     academicPeriodRepository = AcademicPeriodRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Student Score", () {
//     test("Login Lecture", () async {
//       var username = "173132";
//       var password = "rosetya*173132";

//       var token = await userRepository.login(username, password);

//       userRepository.presisteToken(token);
//       userRepository.saveRoleInfo("Dosen");
//     });

//     test("Academic Periode Student", () async {
//       var academicPeriodes = await academicPeriodRepository.academicPeriod();

//       expect(academicPeriodes, isNotEmpty);
//       expect(academicPeriodes, isA<List<AcademicPeriod>>());

//       await academicPeriodRepository.initActiveAcademicPeriod(academicPeriodes);
//     });

//     test("Subject Lecturer", () async {
//       var subjects = await subjectRepository.getSubjects();

//       expect(subjects, isNotEmpty);
//       expect(subjects, isA<List<Subject>>());

//       subject = subjects[0];
//     });

//     test("Student Subject Score", () async {
//       var studentScores = await subjectRepository.getStudentScore(
//           subject.academicPeriodId, subject.subjectId, subject.subjectClass);

//       expect(studentScores, isNotEmpty);
//       expect(studentScores, isA<List<StudentScore>>());
//     });
//   });
// }
