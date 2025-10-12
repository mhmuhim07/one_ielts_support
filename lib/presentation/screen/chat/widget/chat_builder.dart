import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:one_ielts_supports/model/message.dart';
import 'package:one_ielts_supports/utils/helper.dart';

class ChatBuilder extends StatelessWidget {
  final Message msg;
  final bool isUser;

  const ChatBuilder({super.key, required this.msg, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final helper = Helper();

    Widget messageContent() {
      switch (msg.type) {
        case MessageType.text:
          return _showHtml(msg.message,isUser);

        case MessageType.image:
          if (msg.imageUrls == null || msg.imageUrls!.isEmpty) {
            return const Text("Image not available",
                style: TextStyle(color: Colors.red));
          }
          return _buildImages(msg.imageUrls!, context);

        case MessageType.mixed:
          return Column(
            crossAxisAlignment:
            isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (msg.message != null && msg.message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _showHtml(msg.message,isUser),
                ),
              if (msg.imageUrls != null && msg.imageUrls!.isNotEmpty)
                _buildImages(msg.imageUrls!, context),
            ],
          );

        default:
          return _showHtml(msg.message,isUser);
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Chat bubble
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            padding: msg.type == MessageType.text
                ? const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                : const EdgeInsets.all(4),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isUser ? Colors.pink[300] : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isUser ? Radius.zero : const Radius.circular(12),
                bottomRight: isUser ? const Radius.circular(12) : Radius.zero,
              ),
            ),
            child: messageContent(),
          ),

          // Timestamp aligned with bubble side
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
              isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Text(
                  helper.formateTimeStamp(msg.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages(List<String> urls, BuildContext context) {
    if (urls.length == 1) {
      return GestureDetector(
        onTap: () => _showImagePreview(context, urls.first),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            urls.first,
            width: MediaQuery.of(context).size.width * 0.6,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    // Multiple images grid
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: urls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showImagePreview(context, urls[index]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              urls[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  /// Shows image in fullscreen with zoom
  void _showImagePreview(BuildContext context, String imageUrl) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _showHtml(String? message, bool isUser) {
  return IntrinsicWidth(
    child: Align(
      alignment: Alignment.centerLeft,
      child: Html(
        data: message ?? '',
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(14),
            color: isUser ? Colors.white : Colors.black87,
            textAlign: TextAlign.start,
            whiteSpace: WhiteSpace.normal,
            display: Display.block,
          ),
          "p": Style(margin: Margins.zero),
        },
      ),
    ),
  );
}

