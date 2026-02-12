// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/academic_period.dart';
// import 'package:classroom_itats_mobile/models/major.dart';
// import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/major_repository.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   late MajorRepository majorRepository;
//   late AcademicPeriodRepository academicPeriodRepository;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     majorRepository = MajorRepository();
//     userRepository = UserRepository();
//     academicPeriodRepository = AcademicPeriodRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Major Lecturer", () {
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

//     test("Major Lecturer from Active Academic Periode", () async {
//       var majors = await majorRepository.getLecturerMajors(
//           await academicPeriodRepository.getActiveAcademicPeriod());

//       expect(majors, isNotEmpty);
//       expect(majors, isA<List<Major>>());
//     });

//     test("Major Lecturer from Specific Academic Periode", () async {
//       var majors = await majorRepository.getLecturerMajors("20202");

//       expect(majors, isNotEmpty);
//       expect(majors, isA<List<Major>>());
//     });
//   });
// }
