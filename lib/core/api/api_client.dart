import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../storage/secure_storage.dart';
import 'dart:io' show Platform;

class ApiClient {
  late final Dio dio;
  final SecureStorageService storage;

  ApiClient({required this.storage}) {
    final baseUrl = Platform.isIOS ? ApiConfig.iosBaseUrl : ApiConfig.baseUrl;

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        final tenantSlug = await storage.getTenantSlug();
        if (tenantSlug != null) {
          options.headers['X-Tenant-Slug'] = tenantSlug;
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await storage.clearAll();
          // Token expired — app should redirect to login
        }
        handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      dio.put(path, data: data);

  Future<Response> delete(String path) =>
      dio.delete(path);
}
