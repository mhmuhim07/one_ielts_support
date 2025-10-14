import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:one_ielts_supports/data/service/local_storage.dart';
import 'package:one_ielts_supports/navigation_service.dart';

class ApiClient {
  late final Dio _dio;
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://staging.proxisprep.com',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'organization-domain': 'test.portal.oneielts.com',
          'app-locale': 'en-GB',
          'app-os': 'Linux x86_64',
          'app-package-name': 'test.portal.oneielts.com',
          'app-platform': 'web',
          'app-version': '2.4.0',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final tokens = await TokenStorage.getTokens();
          if (tokens['accessToken'] != null) {
            options.headers['Authorization'] =
                'Bearer ${tokens['accessToken']}';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final tokens = await TokenStorage.getTokens();
              e.requestOptions.headers['Authorization'] =
                  'Bearer ${tokens['accessToken']}';
              final cloneRequest = await _dio.fetch(e.requestOptions);
              return handler.resolve(cloneRequest);
            } else {
              await TokenStorage.clearTokens();
            }
          }
          handler.next(e);
        },
      ),
    );
  }
  Dio get client => _dio;
  Future<bool> _refreshToken() async {
    final tokens = await TokenStorage.getTokens();
    final refreshToken = tokens['refreshToken'];
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/api/identity/v1/token-refresh/',
        data: {'refresh_token': refreshToken},
      );
      final newAccess = response.data['access_token'];
      final newRefresh = response.data['refresh_token'] ?? refreshToken;

      await TokenStorage.saveTokens(newAccess, newRefresh);
      return true;
    } catch (e) {
      await TokenStorage.clearTokens();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
      return false;
    }
  }
}
