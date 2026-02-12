import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late UserRepository userRepository;

  setUp(() async {
    userRepository = UserRepository();
    await dotenv.load(fileName: ".env");
  });

  group("Login Student", () {
    test("Login Success", () async {
      var username = "06.2020.1.07351";
      var password = "150300";

      var token = await userRepository.login(username, password);

      expect(token, isNotNull);
    });

    test("Login Failed", () async {
      var username = "000000";
      var password = "000000";
      expect(() async => await userRepository.login(username, password),
          throwsA(isA<DioException>()));
    });
  });

  group("Login Lecturer", () {
    test("Login Success", () async {
      var username = "173132";
      var password = "rosetya*173132";

      var token = await userRepository.login(username, password);

      expect(token, isNotNull);
    });

    test("Login Failed", () async {
      var username = "0000000";
      var password = "0000000";

      expect(() async => await userRepository.login(username, password),
          throwsA(isA<DioException>()));
    });
  });
}
