import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:one_ielts_supports/data/service/api_service.dart';
import 'package:one_ielts_supports/model/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_provider.g.dart';

@riverpod
class ChatMessagesNotifier extends _$ChatMessagesNotifier {
  late final ApiService _apiService;
  Timer? _timer;

  @override
  Future<List<Message>> build(int chatId) async {
    _apiService = ApiService();

    final messages = await fetchMessages(chatId);
    _startPolling(chatId);

    ref.onDispose(() {
      _timer?.cancel();
    });
    return messages;
  }
  Future<List<Message>> fetchMessages(int chatId) async {
    final response = await _apiService.getChatMessages(chatId);
    return response.map((json) => Message.fromJson(json)).toList();
  }
  void sendMessage(int chatId, {String? content, List<File>? images}) async {
    try {
      final currentMessages = state.asData?.value ?? [];

      // Prepare files for FormData
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

      print('Prepared files: $files');

      // Send request using FormData
      final response = await _apiService.postChatMessage(
        chatId,
        content: content,
        files: files, // ✅ pass prepared multipart list
      );

      // Handle API response
      final newMessage = Message.fromJson(response);
      print('Response: $response');

      // Update state immediately
      state = AsyncValue.data([newMessage, ...currentMessages]);
    } catch (e, st) {
      print('Error sending message: $e');
    }
  }

  void _startPolling(int chatId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final updatedMessages = await fetchMessages(chatId);
        final currentMessages = state.asData?.value ?? [];
        if(updatedMessages != currentMessages) state = AsyncValue.data(updatedMessages);
      } catch (_) {}
    });
  }
}