import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/storage/session_store.dart';
import 'routes.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registration_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/sightings/presentation/sighting_detail_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  Future<bool> _isLogged(BuildContext context) async {
    final store = context.read<SessionStore>();
    return store.isAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLogged(context),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snap.hasError) {
          return MaterialApp(
            home: Scaffold(body: Center(child: Text('Errore init: ${snap.error}'))),
          );
        }

        final logged = snap.data ?? false;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: logged ? const HomeShell() : const LoginScreen(),
          routes: {
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.register: (_) => const RegistrationScreen(),
            AppRoutes.home: (_) => const HomeShell(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.sightingDetail) {
              final id = settings.arguments as int;
              return MaterialPageRoute(
                builder: (_) => SightingDetailScreen(sightingId: id),
              );
            }
            return null;
          },
          onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );
  }
}
