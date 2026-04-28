import 'package:classroom_itats_mobile/models/notification_item.dart';
import 'package:classroom_itats_mobile/core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = ApiClient.instance.dio;

  String get _base =>
      '${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/notifications';

  Future<Options> _authOptions() async {
    final token = await storage.read(key: 'token');
    return Options(
      contentType: 'application/json',
      headers: {'token': token},
    );
  }

  Future<List<NotificationItem>> getNotifications({int limit = 50}) async {
    final response = await _dio.get(
      '$_base?limit=$limit',
      options: await _authOptions(),
    );
    final list = response.data['data'] as List;
    return list.map((e) => NotificationItem.fromJson(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(
      '$_base/unread-count',
      options: await _authOptions(),
    );
    return (response.data['data']['count'] as num).toInt();
  }

  Future<void> markOneRead(int id) async {
    await _dio.patch(
      '$_base/$id/read',
      options: await _authOptions(),
    );
  }

  Future<void> markAllRead() async {
    await _dio.patch(
      '$_base/read-all',
      options: await _authOptions(),
    );
  }
}
