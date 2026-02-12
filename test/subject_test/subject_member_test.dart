// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/academic_period.dart';
// import 'package:classroom_itats_mobile/models/subject_member.dart';
// import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/subject_member_repository.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   late SubjectMemberRepository subjectMemberRepository;
//   late AcademicPeriodRepository academicPeriodRepository;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     userRepository = UserRepository();
//     subjectMemberRepository = SubjectMemberRepository();
//     academicPeriodRepository = AcademicPeriodRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Subject Member Student", () {
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

//       await academicPeriodRepository.initActiveAcademicPeriod(academicPeriodes);
//     });

//     test("Subject Member Student", () async {
//       var subjectMembers = await subjectMemberRepository.getSubjectMember(
//         await academicPeriodRepository.getCurrentAcademicPeriod(),
//         "21064603",
//         "P2",
//         "06",
//       );

//       expect(subjectMembers, isNotEmpty);
//       expect(subjectMembers, isA<List<SubjectMember>>());
//       expect(subjectMembers[1].userId, equals("06.2020.1.07351"));
//     });
//   });

//   group("Subject Member Lecturer", () {
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

//     test("Subject Member Lecturer", () async {
//       var subjectMembers = await subjectMemberRepository.getSubjectMember(
//         await academicPeriodRepository.getCurrentAcademicPeriod(),
//         "21064603",
//         "P2",
//         "06",
//       );

//       expect(subjectMembers, isNotEmpty);
//       expect(subjectMembers, isA<List<SubjectMember>>());
//       expect(subjectMembers.first.userId, equals("173132"));
//     });
//   });
// }
