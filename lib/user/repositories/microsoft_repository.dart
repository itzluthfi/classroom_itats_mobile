import 'package:classroom_itats_mobile/core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MicrosoftRepository {
  final _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = ApiClient.instance.dio;

  String get _base =>
      '${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/lecturers/microsoft';

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'token');
    return {'token': token ?? ''};
  }

  /// Ambil URL OAuth Microsoft dari backend
  Future<Map<String, dynamic>> getAuthUrl() async {
    final response = await _dio.get(
      '$_base/auth-url',
      options: Options(headers: await _authHeaders()),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Kirim auth code ke backend — backend tukar ke token dan simpan
  Future<void> handleCallback(String authCode) async {
    await _dio.post(
      '$_base/callback',
      data: {'code': authCode},
      options: Options(
        contentType: 'application/json',
        headers: await _authHeaders(),
      ),
    );
  }

  /// Buat meeting MS Teams, kembalikan join URL
  Future<String> createMeeting({
    required String subject,
    required String startTime, // ISO 8601 e.g. "2024-05-01T09:00:00Z"
    required String endTime,
  }) async {
    final response = await _dio.post(
      '$_base/create-meeting',
      data: {
        'subject': subject,
        'start_time': startTime,
        'end_time': endTime,
      },
      options: Options(
        contentType: 'application/json',
        headers: await _authHeaders(),
      ),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return data['join_url'] as String;
  }

  /// Cek apakah dosen sudah menghubungkan akun Microsoft
  Future<bool> checkLinkedStatus() async {
    try {
      final response = await _dio.get(
        '$_base/status',
        options: Options(headers: await _authHeaders()),
      );
      return response.data['data']['is_linked'] == true;
    } catch (_) {
      return false;
    }
  }
}
