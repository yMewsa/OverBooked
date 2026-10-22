import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/bookshelf_provider.dart';
import 'providers/stats_provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_view.dart';
import 'views/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const OverbookedApp());
}

class OverbookedApp extends StatelessWidget {
  const OverbookedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookshelfProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: MaterialApp(
        title: 'Overbooked',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

/// Listens to authentication state and routes to the appropriate screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const MainShell();
        }
        return const LoginView();
      },
    );
  }
}
