class Chat {
  final int id;
  final String name;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final String profilePic;
  final bool isOnline;
  final bool isVip;

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.profilePic,
    required this.isOnline,
    required this.isVip,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final lastMessage = json['last_message'] as Map<String, dynamic>?;

    String firstName = user['first_name'] ?? '';
    String lastName = user['last_name'] ?? '';
    String fullName = (firstName.isEmpty && lastName.isEmpty)
        ? user['username'] ?? 'User'
        : '$firstName $lastName';

    return Chat(
      id: json['id'] ?? 0,
      name: fullName,
      lastMessage: lastMessage?['content'] ?? '',
      timestamp: lastMessage?['created_at'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      profilePic: user['avatar'] ?? '',
      isOnline: false, // not provided
      isVip: user['is_vip'] ?? false,
    );
  }

  Chat copyWith({
    int? id,
    String? name,
    String? lastMessage,
    String? timestamp,
    int? unreadCount,
    String? profilePic,
    bool? isOnline,
    bool? isVip,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      profilePic: profilePic ?? this.profilePic,
      isOnline: isOnline ?? this.isOnline,
      isVip: isVip ?? this.isVip,
    );
  }
}
