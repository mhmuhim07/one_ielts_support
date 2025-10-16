import 'package:flutter/material.dart';

class TopNotification {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 40,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlide(
            offset: const Offset(0, -1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: _NotificationCard(message: message),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Animate slide-in
    Future.delayed(const Duration(milliseconds: 50), () {
      overlayEntry.markNeedsBuild();
    });

    // Remove after duration
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}

class _NotificationCard extends StatelessWidget {
  final String message;
  const _NotificationCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
