import 'dart:async';
import 'dart:io';
import 'dart:math' as Math;
import 'package:dio/dio.dart';
import 'package:one_ielts_supports/data/service/api_service.dart';
import 'package:one_ielts_supports/model/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_provider.g.dart';

@riverpod
class ChatMessagesNotifier extends _$ChatMessagesNotifier {
  late final ApiService _apiService;
  Timer? _timer;
  final int _limit = 15;

  int unseen = 0;
  bool _atBottom = true;
  int? _lastUnseen;
  @override
  Future<List<Message>> build(int chatId) async {
    _apiService = ApiService();
    final uri = await _getUri();
    final messages = await _fetchMessages(uri);

    _startAutoPull(chatId);

    ref.onDispose(() {
      _timer?.cancel();
    });

    return messages;
  }

  bool get isAtBottom => _atBottom;

  void setAtBottom(bool value) async {
    if (_atBottom != value) {
      _atBottom = value;
      if (unseen > 0 && _atBottom) {
        await newMessage(chatId);
      } else {
        state = AsyncValue.data([...?state.value]);
      }
    }
  }

  Future<List<Message>> _fetchMessages(String uri) async {
    final response = await _apiService.getChatMessages(uri);
    return response.map((json) => Message.fromJson(json)).toList();
  }

  Future<String> _getUri() async {
    final unread = await _apiService.getUnreadCount(chatId);
    int x = Math.max(Math.max(unread, _limit), unseen);
    return '/api/support/studio/v1/chats/$chatId/messages/?page_size=$x';
  }

  void _startAutoPull(int chatId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      int unreadCount = await _apiService.getUnreadCount(chatId);
      if (unreadCount > 0) {
        print("AtBottom is $_atBottom");
        print("Unseen is $unreadCount");
        if (_atBottom) {
          await newMessage(chatId);
          unseen = 0;
          _lastUnseen = 0;
        } else {
          await _normalize(chatId);
          state = AsyncValue.data([...?state.value]);
        }
      }
    });
  }

  Future<void> _normalize(int chatId) async {
    final unread = await _apiService.getUnreadCount(chatId);
    // print("Unread is from normalize $unread");
    if (unread > 0) {
      String uri = _apiService.getNextChatMessagesPage();
      if (uri != '') {
        unseen += unread;
        Uri parsed = Uri.parse(uri);
        Map<String, String> params = Map.from(parsed.queryParameters);
        params['page_size'] = '$unread';
        String updatedUrl = parsed.replace(queryParameters: params).toString();
        await _fetchMessages(updatedUrl);
      } else {
        if (unread != _lastUnseen) {
          unseen += unread - (_lastUnseen != null ? _lastUnseen! : 0);
          _lastUnseen = unread;
        }
      }
    }
  }

  int getUnseenCount() => unseen;

  Future<void> previousPage(int chatId) async {
    try {
      await _normalize(chatId);
      final uri = _apiService.getNextChatMessagesPage();
      if (uri != '') {
        Uri parsed = Uri.parse(uri);
        Map<String, String> params = Map.from(parsed.queryParameters);
        params['page_size'] = '15';
        String updatedUrl = parsed.replace(queryParameters: params).toString();
        final messages = await _fetchMessages(updatedUrl);
        final currentMessages = state.value ?? [];
        state = AsyncValue.data([...currentMessages, ...messages]);
      }
    } catch (e) {
      state = AsyncValue.data(state.value ?? []);
    }
  }

  Future<void> newMessage(int chatId) async {
    try {
      final uri = await _getUri();
      final messages = await _fetchMessages(uri);
      unseen = 0;
      _lastUnseen = 0;
      state = AsyncValue.data(messages);
    } catch (e) {
      state = AsyncValue.data(state.value ?? []);
    }
  }

  void sendMessage(int chatId, {String? content, List<File>? images}) async {
    try {
      List<MultipartFile> files = [];
      if (images != null && images.isNotEmpty) {
        for (var file in images) {
          files.add(
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          );
        }
      }
      await _apiService.postChatMessage(chatId, content: content, files: files);
      // Refresh messages after sending
      final uri = await _getUri();
      final messages = await _fetchMessages(uri);
      state = AsyncValue.data(messages);
    } catch (e) {
      state = AsyncValue.data(state.value ?? []);
    }
  }

  void clearUnseen() {
    unseen = 0;
    state = AsyncValue.data([...?state.value]);
  }
}
