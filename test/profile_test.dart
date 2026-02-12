// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/academic_period.dart';
// import 'package:classroom_itats_mobile/models/profile.dart';
// import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
// import 'package:classroom_itats_mobile/user/repositories/profile_repository.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   late AcademicPeriodRepository academicPeriodRepository;
//   late ProfileRepository profileRepository;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     academicPeriodRepository = AcademicPeriodRepository();
//     userRepository = UserRepository();
//     profileRepository = ProfileRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Active Academic Period Profile Student", () {
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

//     test("Profile Student in Active Academic Period", () async {
//       var profile = await profileRepository.getStudentProfile(
//           await academicPeriodRepository.getActiveAcademicPeriod());

//       expect(profile, isA<Profile>());
//       expect(profile.studentSubjectPresences, isNotEmpty);
//     });
//   });

//   group("Active Academic Period Profile Student", () {
//     test("Login Student", () async {
//       var username = "06.2020.1.07351";
//       var password = "150300";

//       var token = await userRepository.login(username, password);

//       expect(token, isNotNull);

//       userRepository.presisteToken(token);
//       userRepository.saveRoleInfo("Mahasiswa");
//     });

//     test("Specific Academic Periode Profile Student", () async {
//       var academicPeriodes = await academicPeriodRepository.academicPeriod();

//       expect(academicPeriodes, isNotEmpty);
//       expect(academicPeriodes, isA<List<AcademicPeriod>>());

//       await academicPeriodRepository.initActiveAcademicPeriod(academicPeriodes);
//     });

//     test("Profile Student in Specific Academic Period", () async {
//       await academicPeriodRepository.setAcademicPeriod("20212");

//       var profile = await profileRepository.getStudentProfile(
//           await academicPeriodRepository.getCurrentAcademicPeriod());

//       expect(profile, isA<Profile>());
//       expect(profile.studentSubjectPresences, isNotEmpty);
//     });
//   });
// }
