import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_ielts_supports/data/service/api_service.dart';
import 'package:one_ielts_supports/data/service/local_storage.dart';
import 'package:one_ielts_supports/providers/inbox/inbox_provider.dart';
import 'package:one_ielts_supports/providers/message/message_provider.dart';

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<String?>>(AuthNotifier.new);
class AuthNotifier extends Notifier<AsyncValue<String?>> {
  final ApiService _authApiService = ApiService();
  @override
  AsyncValue<String?> build() {
    _loadTokens();
    return const AsyncValue.loading();
  }
  Future<void> _loadTokens() async {
    try {
      final tokens = await TokenStorage.getTokens();
      if (tokens['accessToken'] != null) {
        state = AsyncValue.data(tokens['accessToken']);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st){
      state = AsyncValue.error(e, st);
    }
  }
  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final success = await _authApiService.login(email, password);
      // print('Login Success: $success');
      if (success) {
        final tokens = await TokenStorage.getTokens();
        state = AsyncValue.data(tokens['accessToken']);
        await _fetchAndStoreUserInfo();
        return true;
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
  Future<void> logout() async {
    await _authApiService.logout();
    ref.invalidate(authProvider);
    ref.invalidate(inboxProvider);
    ref.invalidate(chatMessagesProvider);
  }

  Future<void> _fetchAndStoreUserInfo() async {
    final useInfo = await _authApiService.getUserInfo();
    if (useInfo != null) {
      await UserInfoStorage.saveUserInfo(
        useInfo['email'],
        useInfo['first_name'],
        useInfo['last_name'],
        useInfo['avatar'],
      );
    }
  }
}
