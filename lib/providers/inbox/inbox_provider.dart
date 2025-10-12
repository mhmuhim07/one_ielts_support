import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_ielts_supports/data/service/api_service.dart';
import 'package:one_ielts_supports/model/chat.dart';

final inboxProvider = AsyncNotifierProvider<InboxNotifier, List<Chat>>(
  InboxNotifier.new,
);

class InboxNotifier extends AsyncNotifier<List<Chat>> {
  late final ApiService _apiService;
  Timer? _timer;
  String _currentInboxPage = "/api/support/studio/v1/chats/";
  String? _nextInboxPage;
  String? _previousInboxPage;
  @override
  Future<List<Chat>> build() async {
    _apiService = ApiService();

    final chats = await _fetchChats(_currentInboxPage);
    _nextInboxPage = _apiService.getNextInboxPage();
    _previousInboxPage = _apiService.getPreviousInboxPage();
    _startPolling();

    ref.onDispose(() {
      _timer?.cancel();
    });

    return chats;
  }

  Future<List<Chat>> _fetchChats(String uri) async {
    try {
      final data = await _apiService.getInboxChats(uri);
      _nextInboxPage = _apiService.getNextInboxPage();
      _previousInboxPage = _apiService.getPreviousInboxPage();
      _currentInboxPage = uri;
      final chats = data.map((json) => Chat.fromJson(json)).toList();
      state = AsyncValue.data(chats);
      return chats;
    } catch (e,st) {
      // print(e);
      state = AsyncValue.error(e,st);
      return [];
    }
  }

  Future<void> nextPage() async {
    if(_nextInboxPage != null){
       _fetchChats(_nextInboxPage!);
    }
  }
  Future<void> previousPage() async {
    if(_previousInboxPage != null){
      _fetchChats(_previousInboxPage!);
    }
  }
  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final data = await _fetchChats(_currentInboxPage);
        final updatedChats = (data as List)
            .map((json) => Chat.fromJson(json))
            .toList();

        final currentChats = state.value ?? [];
        if (updatedChats.length != currentChats.length) {
          state = AsyncValue.data(updatedChats);
        }
      } catch (_) {
        // Ignore polling errors
      }
    });
  }
  String getNextPage() => _nextInboxPage ?? '';
  String getPreviousPage() => _previousInboxPage ?? '';
}
