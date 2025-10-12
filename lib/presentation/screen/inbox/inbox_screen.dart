import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_ielts_supports/presentation/screen/inbox/widget/chat_divider.dart';
import 'package:one_ielts_supports/presentation/screen/inbox/widget/inbox_list_tile.dart';
import 'package:one_ielts_supports/presentation/screen/profile/widget/profile.dart';
import 'package:one_ielts_supports/providers/inbox/inbox_provider.dart';
import '../chat/chat_screen.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref.read(inboxProvider.notifier).nextPage();
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    final inboxState = ref.watch(inboxProvider);
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/app/img-app-logo.png',
              height: 64,
              width: 64,
            ),
            const SizedBox(width: 10),
            const Text(
              'Support',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              openProfileSlide(context);
            },
          )
        ],
      ),
      body: inboxState.when(
        data: (inboxChats) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(inboxProvider.notifier).refresh();
          },
          child: ListView.separated(
            controller: _scrollController,
            itemCount: inboxChats.length,
            itemBuilder: (context, index) {
              final chat = inboxChats[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        image: chat.profilePic,
                        name: chat.name,
                        isVip: chat.isVip,
                        chatId: chat.id,
                      ),
                    ),
                  );
                },
                splashColor: Colors.grey[200],
                highlightColor: Colors.grey[200],
                child: InboxListTile(
                  image: chat.profilePic,
                  name: chat.name,
                  lastMessage: chat.lastMessage,
                  timestamp: chat.timestamp,
                  chatId: chat.id,
                  isVip: chat.isVip,
                ),
              );
            },
            separatorBuilder: (_, __) => const ChatDivider(),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Something went wrong: $error'),
        ),
      ),
    );
  }
}
