import 'package:flutter/material.dart';
class ChatDivider extends StatelessWidget {
  const ChatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 72.0),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: Colors.grey[300],
      ),
    );
  }
}
