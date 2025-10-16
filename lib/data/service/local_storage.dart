import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'accessToken': prefs.getString(_accessTokenKey),
      'refreshToken': prefs.getString(_refreshTokenKey),
    };
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}

class UserInfoStorage {
  static const _email = 'email';
  static const _firstName = 'firstName';
  static const _lastName = 'lastName';
  static const _avatar = 'avatar';

  static Future<void> saveUserInfo(
    String email,
    String firstName,
    String lastName,
    String avatar,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_email, email);
    await prefs.setString(_firstName, firstName);
    await prefs.setString(_lastName, lastName);
    await prefs.setString(_avatar, avatar);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_email),
      'firstName': prefs.getString(_firstName),
      'lastName': prefs.getString(_lastName),
      'avatar': prefs.getString(_avatar),
    };
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_email);
    await prefs.remove(_firstName);
    await prefs.remove(_lastName);
    await prefs.remove(_avatar);
  }
}
