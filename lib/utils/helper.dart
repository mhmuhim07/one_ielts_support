import 'package:intl/intl.dart';

class Helper {
  String removeHtmlTags(String htmlText) {
    if (htmlText.isEmpty) return '';
    String text = htmlText.replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    text = text.trim().replaceAll(RegExp(r'\n+'), '\n');
    return text;
  }


  String formateTimeStamp(String timestamp){
    if (timestamp.isEmpty) return '';

    DateTime? date;
    try {
      date = DateTime.parse(timestamp).toLocal();
    } catch (_) {
      return timestamp;
    }

    final now = DateTime.now();
    final diff = now.difference(date);
    if(diff.inMinutes < 1) {
      return 'Now';
    } else if(diff.inMinutes < 60){
      return '${diff.inMinutes} minutes ago';
    } else if(diff.inHours <= 12){
      return '${diff.inHours} hours ago';
    }else if (diff.inDays == 0) {
      return DateFormat('hh:mm a').format(date);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      return DateFormat('dd MMM').format(date);
    } else if (diff.inDays > 365) {
      final years = (diff.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}

