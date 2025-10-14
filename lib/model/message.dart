enum MessageStatus { sent, delivered, seen, failed }

enum MessageType { text, image, mixed, system, typing }

class Message {
  final int id;
  final String sender;
  final String? message;
  final String timestamp;
  final MessageStatus status;
  final MessageType type;
  final List<String>? imageUrls;
  final String senderImgUrl;

  Message({
    required this.id,
    required this.sender,
    this.message,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.imageUrls,
    required this.senderImgUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final attachments = (json['attachments'] as List<dynamic>?) ?? [];
    final imageUrls = attachments
        .map((e) => e['file'] as String?)
        .where((url) => url != null && _isImageFile(url))
        .cast<String>()
        .toList();

    final content = json['content'] as String?;
    final hasText = content != null && content.trim().isNotEmpty;
    final hasImages = imageUrls.isNotEmpty;

    // Determine type
    MessageType type;
    if (hasText && hasImages) {
      type = MessageType.mixed;
    } else if (hasImages) {
      type = MessageType.image;
    } else {
      type = MessageType.text;
    }
    final sender = (json['sender'] as Map<String, dynamic>?) ?? {};
    return Message(
      id: json['id'] ?? 0,
      sender: json['sender_type'] ?? 'Unknown',
      message: content,
      timestamp: json['created_at'] ?? '',
      type: type,
      imageUrls: imageUrls,
      senderImgUrl: sender['avatar'],
    );
  }

  static bool _isImageFile(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }
}
