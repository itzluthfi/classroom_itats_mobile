import 'package:classroom_itats_mobile/models/user.dart';
import 'package:classroom_itats_mobile/services/encyription_service.dart';
import 'package:dio/dio.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();
  final EncryptionService encryptionService = EncryptionService();

  Future<bool> hasToken() async {
    var value = await storage.read(key: "token");
    return value != null;
  }

  Future<String> getToken() async {
    final value = await storage.read(key: "token");
    return value ?? '';
  }

  Future<String> getFbt() async {
    final value = await storage.read(key: "client-token");
    return value ?? '';
  }

  Future<User> decodeTokenToUser(String token) async {
    final data = JWT.decode(token);
    final Map<String, dynamic> payload = data.payload;

    return User.fromJson(payload);
  }

  Future<void> setWidgetState(String key, bool state) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(key, state);
  }

  Future<bool> getWidgetState(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(key) ?? false;
  }

  Future<void> presisteToken(String token) async {
    await storage.write(key: "token", value: token);
  }

  Future<void> deleteToken() async {
    storage.delete(key: "token");
  }

  Future<void> deleteTempData() async {
    final prefs = await SharedPreferences.getInstance();
    storage.delete(key: "role");
    prefs.remove("current_academic_period");
    prefs.remove("active_academic_period");
    prefs.remove("lecturer_major");
  }

  Future<Response> login(String name, String pass) async {
    var hashedPass = await encryptionService.makeNewHash(pass);

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/login",
      data: {
        "name": name,
        "pass": hashedPass,
      },
      options: Options(
        contentType: "application/json",
        validateStatus: (code) {
          return code! <= 500;
        },
      ),
    );

    return response;
  }

  Future<int> storeLoginUser(String fbt) async {
    var token = await storage.read(key: "token");

    Response response = await _dio.put(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/login/info",
      data: {
        "mobile_token": fbt,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": token},
      ),
    );

    return response.statusCode ?? 400;
  }

  Future<int> logout() async {
    var token = await storage.read(key: "token");

    Response response = await _dio.put(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/logout",
      options: Options(
        contentType: "application/json",
        headers: {"token": token},
      ),
    );

    return response.statusCode ?? 400;
  }

  Future<void> saveLoginInfo(String name, String pass) async {
    storage.write(key: "name", value: name);
    storage.write(key: "pass", value: pass);
  }

  Future<void> saveRoleInfo(String role) async {
    storage.write(key: "role", value: role);
  }

  Future<String> getRole() async {
    final value = await storage.read(key: "role");
    return value ?? "";
  }
}
