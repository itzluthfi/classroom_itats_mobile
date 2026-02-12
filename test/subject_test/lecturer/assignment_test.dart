// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/academic_period.dart';
// import 'package:classroom_itats_mobile/models/assignment.dart';
// import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/assignment_repository.dart';
// // import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   // late SubjectRepository subjectRepository;
//   late AcademicPeriodRepository academicPeriodRepository;
//   late AssignmentRepository assignmentRepository;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     userRepository = UserRepository();
//     // subjectRepository = SubjectRepository();
//     academicPeriodRepository = AcademicPeriodRepository();
//     assignmentRepository = AssignmentRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Created Assignment", () {
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

//     test("Get List Created Assignment", () async {
//       var assignments = await assignmentRepository.getLecturerCreatedAssignment(
//           await academicPeriodRepository.getCurrentAcademicPeriod());

//       expect(assignments, isNotEmpty);
//       expect(assignments, isA<List<Assignment>>());
//     });
//   });

//   // group("Create New Assignment", () async {});
// }
