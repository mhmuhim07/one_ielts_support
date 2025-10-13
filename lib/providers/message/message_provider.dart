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
  // Timer? _timer;
  final _limit = 15;
  int unseen = 0;

  @override
  Future<List<Message>> build(int chatId) async {
    _apiService = ApiService();
    final uri = await getUri();
    final messages = await fetchMessages(uri);
    return messages;
  }
  Future<List<Message>> fetchMessages(String uri) async {
    final response = await _apiService.getChatMessages(uri);
    return response.map((json) => Message.fromJson(json)).toList();
  }
  Future<String> getUri() async {
    final unread = await _apiService.getUnreadCount(chatId);
    int x = Math.max(Math.max(unread, _limit),unseen);
    final uri = '/api/support/studio/v1/chats/$chatId/messages/?page_size=$x';
    return uri;
  }
  int getUnseenCount() => unseen;

  Future<void> previousPage(int chatId) async {

    try {
      final unread = await _apiService.getUnreadCount(chatId);
      // print(unread);
      unseen += unread;
      if(unread > 0){
        String uri = _apiService.getNextChatMessagesPage();

        if(uri != ''){
          // print('uri : $uri');
          Uri parsed = Uri.parse(uri);
          Map<String, String> params = Map.from(parsed.queryParameters);
          params['page_size'] = '$unread'; // just replace the value
          String updatedUrl = parsed.replace(queryParameters: params).toString();
          // print(updatedUrl);
          await fetchMessages(updatedUrl);
        }
      }
      final uri = _apiService.getNextChatMessagesPage();
      if(uri != ''){
        Uri parsed = Uri.parse(uri);
        Map<String, String> params = Map.from(parsed.queryParameters);
        params['page_size'] = '15'; // just replace the value
        String updatedUrl = parsed.replace(queryParameters: params).toString();
        final messages = await fetchMessages(updatedUrl);
        final currentMessages = state.value ?? [];
        state = AsyncValue.data([...currentMessages, ...messages]);
      }else {
        state = AsyncValue.data(state.value ?? []);
      }
    } catch (e) {
      state = AsyncValue.data(state.value ?? []);
    }
  }

  Future<void> newMessage(int chatId) async {
    try {
      final uri = await getUri();
      final messages = await fetchMessages(uri);
      state = AsyncValue.data(messages);
      unseen = 0;
    } catch (e) {
      state = AsyncValue.data(state.value ?? []);
    }
  }

  void sendMessage(int chatId, {String? content, List<File>? images}) async {
    try {
      List<MultipartFile> files = [];
      if (images != null && images.isNotEmpty) {
        for (var file in images) {
          final multipart = await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          );
          files.add(multipart);
        }
      }
      // print('Prepared files: $files');
      final response = await _apiService.postChatMessage(
        chatId,
        content: content,
        files: files,
      );
      // print('Response: $response');
      try {
        final uri = await getUri();
        final messages = await fetchMessages(uri);
        state = AsyncValue.data(messages);
      } catch (e) {
        state = AsyncValue.data(state.value ?? []);
      }
    } catch (e, st) {
      // print('Error sending message: $e');
    }
  }
}