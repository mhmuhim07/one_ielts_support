import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_ielts_supports/presentation/screen/chat/widget/chat_builder.dart';
import 'package:one_ielts_supports/providers/message/message_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String image;
  final String name;
  final bool isVip;
  final int chatId;
  const ChatScreen({
    super.key,
    required this.image,
    required this.name,
    required this.isVip,
    required this.chatId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        ref
            .read(chatMessagesProvider(widget.chatId).notifier)
            .previousPage(widget.chatId);
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;
    final message = _textController.text.trim();
    final image = List<File>.from(_selectedImages);

    ref
        .read(chatMessagesProvider(widget.chatId).notifier)
        .sendMessage(widget.chatId, content: message, images: image);
    _textController.clear();
    setState(() {
      _selectedImages.clear();
    });
  }

  final ImagePicker _picker = ImagePicker();
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatMessagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      decoration: BoxDecoration(color: scaffoldBackgroundColor),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Row(
              children: [
                Container(
                  padding: widget.isVip
                      ? const EdgeInsets.all(2.5)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isVip
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFFD700), // Gold
                              Color(0xFFFFA500),
                            ],
                          )
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.image != ''
                        ? NetworkImage(widget.image)
                        : null,
                    backgroundColor: Colors.pink,
                    child: widget.image.isEmpty
                        ? Text(
                            widget.name.isNotEmpty
                                ? widget.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: chatMessagesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      data: (chatMessages) {
                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true, // newest messages at the bottom
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: chatMessages.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading at the top when fetching previous messages
                            if (_isLoading && index == chatMessages.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final msg = chatMessages[index];
                            final isUser = msg.sender == 'user';
                            return ChatBuilder(msg: msg, isUser: isUser);
                          },
                        );
                      },
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                  ),
                  if (_selectedImages.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Image.file(
                                  _selectedImages[index],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: scaffoldBackgroundColor,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _pickImages,
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.pink,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            keyboardType: TextInputType
                                .multiline, // allows multiline input
                            textInputAction: TextInputAction
                                .newline, // pressing Enter adds new line
                            minLines: 1, // starts small
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.pink[300],
                          radius: 24,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              _sendMessage();
                              _scrollToBottom();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (ref
                      .read(chatMessagesProvider(widget.chatId).notifier)
                      .getUnseenCount() >
                  0)
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      ref
                          .read(chatMessagesProvider(widget.chatId).notifier)
                          .newMessage(widget.chatId);
                      _scrollToBottom();
                    },
                    child: const Icon(Icons.arrow_downward),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
