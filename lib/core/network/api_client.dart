// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  const ApiException({this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient extends GetxService {
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )..interceptors.addAll([
        _AuthInterceptor(),
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: true,
        ),
      ]);
  }

  // ── REST ──────────────────────────────────────────────────────────────────

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res =
          await _dio.get<dynamic>(path, queryParameters: queryParameters);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    required Map<String, dynamic> data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.post<dynamic>(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    required Map<String, dynamic> data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.put<dynamic>(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete<dynamic>(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ── GraphQL ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> graphql({
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        AppConstants.productGraphql,
        data: {
          'query': query,
          if (variables != null) 'variables': variables,
        },
      );
      final body = res.data!;
      if (body.containsKey('errors')) {
        final err =
            (body['errors'] as List<dynamic>).first as Map<String, dynamic>;
        throw ApiException(
            message: err['message']?.toString() ?? 'GraphQL error');
      }
      return body['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ── Error mapping ─────────────────────────────────────────────────────────

  ApiException _mapError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      String msg = 'Request failed';
      if (data is Map<String, dynamic>) {
        msg = data['message']?.toString() ?? data['title']?.toString() ?? msg;
      }
      return ApiException(statusCode: e.response!.statusCode, message: msg);
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Connection timed out');
      case DioExceptionType.connectionError:
        return const ApiException(message: 'No internet connection');
      default:
        return ApiException(message: e.message ?? 'Unknown error');
    }
  }
}

// ── Auth interceptor (placeholder for token injection) ───────────────────────

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: inject Bearer token from secure storage
    // options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
