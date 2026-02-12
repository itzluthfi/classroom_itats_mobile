// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/academic_period.dart';
// import 'package:classroom_itats_mobile/models/assignment.dart';
// import 'package:classroom_itats_mobile/models/subject.dart';
// import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/assignment_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   late SubjectRepository subjectRepository;
//   late AssignmentRepository assignmentRepository;
//   late AcademicPeriodRepository academicPeriodRepository;
//   late Subject subject;
//   late Assignment assignment;
//   // late StudentAssignmentSubmission studentAssignmentSubmission;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     userRepository = UserRepository();
//     subjectRepository = SubjectRepository();
//     assignmentRepository = AssignmentRepository();
//     academicPeriodRepository = AcademicPeriodRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Student Assignment", () {
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

//       subject = subjects.first;
//     });

//     test("Student Assignment", () async {
//       var assignments = await assignmentRepository.getStudyAssignment(
//         subject.activityMasterId,
//       );

//       expect(assignments, isNotEmpty);
//       expect(assignments, isA<List<Assignment>>());

//       assignment = assignments[0];
//     });

//     // test("Student Assignment Download", () async {
//     //   await assignmentRepository.downloadAssignmentFile(
//     //     assignment.fileLink,
//     //     assignment.fileName,
//     //   );
//     // });

//     test("Student Submitted Assignment", () async {
//       var studentSubmittedAssignment =
//           await assignmentRepository.getStudentSubmitedAssignment(
//         assignment.assignmentId,
//       );

//       expect(studentSubmittedAssignment, isNotNull);
//       expect(studentSubmittedAssignment, isA<StudentAssignmentSubmission>());

//       // studentAssignmentSubmission = studentSubmittedAssignment;
//     });

//     // test("Download Student Submitted Assignment", () async {
//     //   await assignmentRepository.downloadAssignmentFile(
//     //     studentAssignmentSubmission.assignmentLink,
//     //     studentAssignmentSubmission.assignmentFile,
//     //   );
//     // });
//   });
// }
