// import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
// import 'package:classroom_itats_mobile/models/forum.dart';
// import 'package:classroom_itats_mobile/user/repositories/forum_repository.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late UserRepository userRepository;
//   late ForumRepository forumRepository;
//   SharedPreferences.setMockInitialValues({});
//   FlutterSecureStorage.setMockInitialValues({});

//   setUp(() async {
//     userRepository = UserRepository();
//     forumRepository = ForumRepository();
//     await dotenv.load(fileName: ".env");
//   });

//   group("Forum Student", () {
//     test("Login Student", () async {
//       var username = "06.2020.1.07351";
//       var password = "150300";

//       var token = await userRepository.login(username, password);

//       expect(token, isNotNull);

//       userRepository.presisteToken(token);
//       userRepository.saveRoleInfo("Mahasiswa");
//     });

//     test("Forum Student", () async {
//       var forums = await forumRepository.forum(
//         "04dd0b72-45c7-4dae-ad72-45e62f22823e",
//       );

//       expect(forums, isNotEmpty);
//       expect(forums, isA<List<Announcement>>());
//     });

//     test("Empty Forum Student", () async {
//       var forums =
//           await forumRepository.forum("9ff73038-7a9d-6da2-fd8b-6c90fc3218a4");

//       expect(forums, isEmpty);
//       expect(forums, isA<List<Announcement>>());
//     });
//   });

//   group("Forum Lecturer", () {
//     test("Login Lecture", () async {
//       var username = "173132";
//       var password = "rosetya*173132";

//       var token = await userRepository.login(username, password);

//       userRepository.presisteToken(token);
//       userRepository.saveRoleInfo("Dosen");
//     });

//     test("Forum Lecturer", () async {
//       var forums =
//           await forumRepository.forum("04dd0b72-45c7-4dae-ad72-45e62f22823e");

//       expect(forums, isNotEmpty);
//       expect(forums, isA<List<Announcement>>());
//     });

//     test("Empty Forum Lecturer", () async {
//       var forums = await forumRepository.forum(
//         "7fb1a807-a8b6-553f-66ee-be2b1041e1eb",
//       );

//       expect(forums, isEmpty);
//       expect(forums, isA<List<Announcement>>());
//     });
//   });
// }
