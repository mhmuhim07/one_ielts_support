import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_ielts_supports/providers/inbox/inbox_provider.dart';
import 'package:one_ielts_supports/utils/helper.dart';


class InboxListTile extends ConsumerWidget {
  final String image;
  final String name;
  final String lastMessage;
  final String timestamp;
  final int chatId;
  final bool isVip;
  const InboxListTile({super.key, required this.image, required this.name, required this.lastMessage, required this.timestamp,required this.chatId,this.isVip = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helper = Helper();
    final unreadCount = ref.watch(inboxProvider.notifier).state.value!.firstWhere((chat) => chat.id == chatId).unreadCount;
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(isVip ? 2.5 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isVip ? const LinearGradient(
            colors: [
              Color(0xFFFFD700), // Gold
              Color(0xFFFFA500),
            ],
          ) : null,
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundImage: image != '' ? NetworkImage(image) : null,
          backgroundColor: Colors.pink,
          child: image.isEmpty
              ? Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )
              : null,
        ),
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        helper.removeHtmlTags(lastMessage),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: unreadCount == 0 ?
      Text(
        helper.formateTimeStamp(timestamp),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ) :
      Column(
        children: [
          Text(
            helper.formateTimeStamp(timestamp),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          SizedBox(height: 4,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(12)
            ),
            child: Text(
              unreadCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}

