import 'dart:io';

import 'package:classroom_itats_mobile/models/forum.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ForumRepository {
  final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _dio = Dio();

  Future<List<Announcement>> forum(String masterActivityId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/subjects/forums",
      data: {
        "master_activity_id": masterActivityId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
      ),
    );

    final decodedData = response.data["data"] as List;

    final forums =
        decodedData.map((data) => Announcement.fromJson(data)).toList();

    return forums;
  }

  Future<int> createForum(String activityMasterId, String forumContent,
      String createdAt, String updatedAt) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/subjects/forums/store",
      data: {
        "activity_master_id": activityMasterId,
        "post_content": forumContent,
        "created_at": createdAt,
        "updated_at": updatedAt,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
        validateStatus: (status) {
          return status! == 201;
        },
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }

  Future<int> updateForum(int announcementId, String activityMasterId,
      String forumContent, String createdAt, String updatedAt) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.put(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/subjects/forums/update",
      data: {
        "announcement_id": announcementId,
        "activity_master_id": activityMasterId,
        "post_content": forumContent,
        "created_at": createdAt,
        "updated_at": updatedAt,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
        validateStatus: (status) {
          return status! == 200;
        },
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }

  Future<int> deleteForum(int announcementId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.delete(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/subjects/forums/delete",
      data: {
        "announcement_id": announcementId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
        validateStatus: (status) {
          return status! == 200;
        },
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }

  Future<int> createForumComment(int announcementId, String commentContent,
      String createdAt, String updatedAt) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.post(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/subjects/forums/comments/store",
      data: {
        "announcement_id": announcementId,
        "comment_content": commentContent,
        "created_at": createdAt,
        "updated_at": updatedAt,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
        validateStatus: (status) {
          return status! == 201;
        },
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }

  Future<int> updateForumComment(int commentId, int announcementId,
      String commentContent, String updatedAt) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.put(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/subjects/forums/comments/update",
      data: {
        "comment_id": commentId,
        "announcement_id": announcementId,
        "comment_content": commentContent,
        "updated_at": updatedAt,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
        validateStatus: (status) {
          return status! == 200;
        },
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }

  Future<int> deleteForumComment(int commentId) async {
    final value = await storage.read(key: "token");

    Response response = await _dio.delete(
      "${dotenv.get("API_PROTOCOL")}${dotenv.get("API_URL")}${dotenv.get("API_BASEPATH")}/subjects/forums/comments/delete",
      data: {
        "comment_id": commentId,
      },
      options: Options(
        contentType: "application/json",
        headers: {"token": value},
        validateStatus: (status) {
          return status! == 200;
        },
      ),
    );

    final decodedData = response.statusCode ?? 0;

    return decodedData;
  }

  Future<Response> storeForumFile(
    String filepath,
    String filename,
  ) async {
    final value = await storage.read(key: "token");

    var formData = FormData.fromMap({
      "file_forum": await MultipartFile.fromFile(filepath, filename: filename),
    });

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        HttpClient client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
        return client;
      },
    );

    Response response = await _dio.post(
      "${dotenv.get("WEB_PROTOCOL")}${dotenv.get("WEB_URL")}/api/forum/file/store",
      data: formData,
      options: Options(
        contentType: "application/x-www-form-urlencoded",
        headers: {
          "token": value,
        },
      ),
    );

    return response;
  }
}
