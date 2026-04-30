import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Singleton Dio client dengan HMAC signature interceptor.
///
/// Setiap request otomatis mendapat header:
///   X-Timestamp : unix timestamp saat ini (detik)
///   X-Signature : HMAC-SHA256 dari "<METHOD>\n<PATH>\n<TIMESTAMP>\n<BODY>"
///
/// Cara pakai di repository:
///   final _dio = ApiClient.instance;
class ApiClient {
  ApiClient._();
  static final ApiClient _inst = ApiClient._();
  static ApiClient get instance => _inst;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  late final Dio _dio = _buildDio();

  Dio _buildDio() {
    final dio = Dio();
    
    // Tambahkan User-Agent layaknya browser asli agar lolos dari blokir Firewall (LiteSpeed/Cloudflare)
    dio.options.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    
    dio.interceptors.add(_HmacInterceptor(_storage));
    return dio;
  }

  /// Gunakan seperti Dio biasa.
  Dio get dio => _dio;
}

/// Interceptor yang menghitung HMAC-SHA256 dan menyisipkan header keamanan.
class _HmacInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  _HmacInterceptor(this._storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Timestamp sekarang (detik)
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    // 2. Serialisasi body ke string
    String bodyStr = '';
    final data = options.data;
    if (data != null) {
      if (data is Map || data is List) {
        bodyStr = jsonEncode(data);
      } else {
        bodyStr = data.toString();
      }
    }

    // 3. Susun payload yang sama dengan server Go
    final method = options.method.toUpperCase();
    final path = Uri.parse(options.path).path; // hanya path, tanpa query
    final payload = '$method\n$path\n$timestamp\n$bodyStr';

    // 4. Ambil secret key dari .env
    final secret = dotenv.get('API_SECRET_KEY', fallback: '');
    final key = utf8.encode(secret);
    final msg = utf8.encode(payload);
    final signature =
        Hmac(sha256, key).convert(msg).toString(); // hex string

    // 5. Sisipkan header
    options.headers['X-Timestamp'] = timestamp;
    options.headers['X-Signature'] = signature;

    // 6. Sertakan JWT token jika ada
    final token = await _storage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      options.headers['token'] = token;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Tangani 401 Unauthorized secara terpusat
    if (err.response?.statusCode == 401) {
      // Bisa tambahkan logout otomatis di sini jika diperlukan
    }
    handler.next(err);
  }
}
