import 'package:bizkonec/features/auth/presentation/auth_screen.dart';
import 'package:bizkonec/features/home/presentation/home_screen.dart';
import 'package:bizkonec/features/my_vcard/presentation/my_vcard_screen.dart';
import 'package:bizkonec/features/pcards/presentation/add_pcard_screen.dart';
import 'package:bizkonec/features/pcards/presentation/pcards_screen.dart';
import 'package:bizkonec/features/profile/presentation/help_support_screen.dart';
import 'package:bizkonec/features/profile/presentation/profile_screen.dart';
import 'package:bizkonec/features/vcards/presentation/vcard_scanner_screen.dart';
import 'package:bizkonec/features/vcards/presentation/vcards_screen.dart';
import 'package:bizkonec/shared/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _myVCardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'myVCard');
final GlobalKey<NavigatorState> _pCardsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'pCards');
final GlobalKey<NavigatorState> _vCardsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'vCards');
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  // Force any external URL intent back to Home to avoid "No routes" errors
  redirect: (context, state) {
    final location = state.uri.toString();
    if (location.startsWith('http') || location.startsWith('https')) {
      debugPrint('Router: Intercepted external URL, redirecting to Home: $location');
      return '/';
    }
    return null;
  },
  // Handle unknown routes gracefully
  errorPageBuilder: (context, state) {
    debugPrint('Router Error: ${state.error}. Location: ${state.uri}');
    // Even if we hit the error page, immediately try to go home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/');
    });
    
    return NoTransitionPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text('Processing Digital Card...', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(state.uri.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/add-pcard',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final source = state.extra as ImageSource?;
        return AddPCardScreen(initialSource: source);
      },
    ),
    GoRoute(
      path: '/scan-vcard',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const VCardScannerScreen(),
    ),
    GoRoute(
      path: '/help-support',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const HelpSupportScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _myVCardNavigatorKey,
          routes: [
            GoRoute(
              path: '/my-vcard',
              builder: (context, state) => const MyVCardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _pCardsNavigatorKey,
          routes: [
            GoRoute(
              path: '/pcards',
              builder: (context, state) => const PCardsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _vCardsNavigatorKey,
          routes: [
            GoRoute(
              path: '/vcards',
              builder: (context, state) => const VCardsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
