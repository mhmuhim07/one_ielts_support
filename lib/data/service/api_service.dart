import 'package:dio/dio.dart';
import 'package:one_ielts_supports/data/api_client.dart';
import 'package:one_ielts_supports/data/service/local_storage.dart';

class ApiService {
  final ApiClient _api = ApiClient();
  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.client.post(
        '/api/identity/v1/login/',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];

        await TokenStorage.saveTokens(accessToken, refreshToken);
        return true;
      } else {
        // print('Login failed: ${response.statusCode} ${response.data}');
        return false;
      }
    } on DioException catch (_) {
      // print('DioException: ${e.response?.statusCode} ${e.response?.data}');
      return false;
    } catch (_) {
      // print('Unexpected error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final tokens = await TokenStorage.getTokens();
    final accessToken = tokens['accessToken'];
    if (accessToken != null) {
      try {
        await _api.client.post(
          '/api/identity/v1/logout/',
          options: Options(headers: _myHeader(accessToken: accessToken)),
        );
      } catch (_) {
        // print('Logout API error: $e');
      } finally {
        await TokenStorage.clearTokens();
        await UserInfoStorage.clearUserInfo();
        // print("Logout Success");
      }
    }
  }

  // Fetch me_user info API
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];
      if (accessToken == null) return null;

      final response = await _api.client.get(
        '/api/identity/v1/me/',
        options: Options(headers: _myHeader(accessToken: accessToken)),
      );
      // print('Response Code: ${response.statusCode}');
      // print('Response Data: ${response.data}');
      if (response.statusCode == 401) {
        return null;
      }
      return response.data;
    } on DioException catch (_) {
      return null;
    }
  }

  String? _nextInboxUri;
  Future<List<Map<String, dynamic>>> getInboxChats(String uri) async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];
      if (accessToken == null) return [];

      final response = await _api.client.get(
        uri,
        options: Options(headers: _myHeader(accessToken: accessToken)),
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>;
        _nextInboxUri = response.data['next'];
        // print(results);
        return results.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  String? getNextInboxPage() => _nextInboxUri;
  // Fetch chat messages by chatId
  Future<int> getUnreadCount(int chatId) async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];
      if (accessToken == null) return 0;
      final response = await _api.client.get(
        '/api/support/studio/v1/chats/$chatId/',
        options: Options(headers: _myHeader(accessToken: accessToken)),
      );
      if (response.statusCode == 200) {
        return response.data['unread_count'];
      } else {
        return 0;
      }
    } on DioException catch (_) {
      return 0;
    }
  }

  String? _nextChatMessagesUri;
  String getNextChatMessagesPage() => _nextChatMessagesUri ?? '';
  Future<List<Map<String, dynamic>>> getChatMessages(String uri) async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];
      if (accessToken == null) return [];
      final response = await _api.client.get(
        // '/api/support/studio/v1/chats/$chatId/messages/?page_size=100',
        uri,
        options: Options(headers: _myHeader(accessToken: accessToken)),
      );
      if (response.statusCode == 200) {
        _nextChatMessagesUri = response.data['next'];
        final results = response.data['results'] as List<dynamic>;
        return results.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> postChatMessage(
    int chatId, {
    String? content,
    List<MultipartFile>? files,
  }) async {
    try {
      final tokens = await TokenStorage.getTokens();
      final accessToken = tokens['accessToken'];
      if (accessToken == null) return {};

      final formData = FormData.fromMap({
        'content': content ?? '',
        'files': files ?? [],
      });

      final response = await _api.client.post(
        '/api/support/studio/v1/chats/$chatId/messages/',
        data: formData,
        options: Options(headers: _myHeader(accessToken: accessToken)),
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        return {};
      }
    } on DioException catch (_) {
      // print('Dio error: ${e.message}');
      return {};
    }
  }
}

Map<String, dynamic> _myHeader({required String accessToken}) {
  return {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'organization-domain': 'test.portal.oneielts.com',
    'app-locale': 'en-GB',
    'app-os': 'Linux x86_64',
    'app-package-name': 'test.portal.oneielts.com',
    'app-platform': 'web',
    'app-version': '2.4.0',
    'Authorization': 'Bearer $accessToken',
  };
}
