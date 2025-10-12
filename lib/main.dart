import 'package:flutter/material.dart';
import 'package:one_ielts_supports/presentation/screen/auth/login_screen.dart';
import 'package:one_ielts_supports/presentation/screen/inbox/inbox_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/service/local_storage.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> _getInitialRoute() async {
    final tokens = await TokenStorage.getTokens();
    return tokens['accessToken'] == null ? '/login' : '/inbox';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getInitialRoute(),
      builder: (context, AsyncSnapshot<String?> snapshot) {
        if (!snapshot.hasData) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MaterialApp(
          title: 'One Ielts Supports',
          debugShowCheckedModeBanner: false,
          initialRoute: snapshot.data,
          routes: {
            '/login': (context) => LoginScreen(),
            '/inbox': (context) => InboxScreen(),
          },
        );
      },
    );
  }
}
