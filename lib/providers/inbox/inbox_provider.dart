import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:one_ielts_supports/data/service/api_service.dart';
import 'package:one_ielts_supports/model/chat.dart';

final inboxProvider = AsyncNotifierProvider<InboxNotifier, List<Chat>>(
  InboxNotifier.new,
);
final inboxNotificationProvider = StateProvider<bool>((ref) => false);

class InboxNotifier extends AsyncNotifier<List<Chat>> {
  late final ApiService _apiService;
  final _mainInboxPage = "/api/support/studio/v1/chats/?page_size=15";
  String? _nextInboxPage;
  Timer? _timer;

  @override
  Future<List<Chat>> build() async {
    _apiService = ApiService();
    final chats = await _fetchChats(_mainInboxPage, false);
    _nextInboxPage = _apiService.getNextInboxPage();
    _startPulling();
    ref.onDispose(() {
      _timer?.cancel();
    });
    return chats;
  }

  bool showNotification = false;
  _startPulling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final chat = await _apiService.getInboxChats(
        "/api/support/studio/v1/chats/?page_size=1",
      );
      if (chat.isNotEmpty) {
        final unseenCount = chat[0]['unread_count'] as int;
        showNotification = unseenCount > 0;
        ref.read(inboxNotificationProvider.notifier).state = showNotification;
      }
    });
  }

  bool isLoadingMoreData = false;
  bool isFirstLoad = true;

  Future<List<Chat>> _fetchChats(String uri, bool keep) async {
    if (isFirstLoad == false) {
      if (isLoadingMoreData || _nextInboxPage == null) return [];
    } else {
      isFirstLoad = false;
    }
    isLoadingMoreData = true;
    try {
      final data = await _apiService.getInboxChats(uri);
      _nextInboxPage = _apiService.getNextInboxPage();
      debugPrint("_nextInboxPage: $_nextInboxPage");
      final chats = data.map((json) => Chat.fromJson(json)).toList();
      final currentChats = state.value ?? [];
      state = keep
          ? AsyncValue.data([...currentChats, ...chats])
          : AsyncValue.data(chats);
      return chats;
    } catch (e, st) {
      // print(e);
      state = AsyncValue.error(e, st);
      return [];
    } finally {
      isLoadingMoreData = false;
    }
  }

  Future<void> nextPage() async {
    if (_nextInboxPage != null) {
      await _fetchChats(_nextInboxPage!, true);
    }
  }

  Future<void> refresh() async {
    isFirstLoad = true;
    _fetchChats(_mainInboxPage, false);
    isFirstLoad = false;
  }

  Future<void> updateState(int chatId) async {
    try {
      final lastChat = await _apiService.getInboxChat(chatId);
      final updatedChat = Chat.fromJson(lastChat);
      final currentChats = List<Chat>.from(state.value ?? []);
      final index = currentChats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        if (currentChats[index] != updatedChat) {
          currentChats.removeAt(index);
          currentChats.insert(0, updatedChat);
          state = AsyncValue.data([...currentChats]);
        }
      }
    } catch (e) {
      debugPrint("updateState failed: $e");
    }
  }
}
