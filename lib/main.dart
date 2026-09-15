import 'package:bizkonec/core/routing/app_router.dart';
import 'package:bizkonec/core/theme/app_theme.dart';
import 'package:bizkonec/features/auth/domain/auth_repository.dart';
import 'package:bizkonec/features/auth/data/mock_auth_repository.dart';
import 'package:bizkonec/features/pcards/domain/pcard_repository.dart';
import 'package:bizkonec/features/pcards/data/local_pcard_repository.dart';
import 'package:bizkonec/features/vcards/domain/vcard_repository.dart';
import 'package:bizkonec/features/vcards/data/local_vcard_repository.dart';
import 'package:bizkonec/features/vcards/presentation/widgets/vcard_preview_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        pCardRepositoryProvider.overrideWithValue(LocalPCardRepository()),
        vCardRepositoryProvider.overrideWithValue(LocalVCardRepository()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    
    // Listen for incoming links while the app is running
    _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Deep Link Received: $uri');
      _handleIncomingUrl(uri.toString());
    });

    // Check for link that launched the app
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint('Initial Link Received: $uri');
        _handleIncomingUrl(uri.toString());
      }
    });
  }

  void _handleIncomingUrl(String url) async {
    final cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http')) return;
    
    debugPrint('Handling Scanned URL: $cleanUrl');
    
    // Give the app/router a moment to settle if it was just launched
    await Future.delayed(const Duration(milliseconds: 600));
    
    final navContext = rootNavigatorKey.currentContext;
    if (navContext != null && navContext.mounted) {
      // Clear any existing overlays or routes that aren't the main scaffold
      try {
        final navigator = Navigator.of(navContext);
        if (navigator.canPop()) {
          navigator.popUntil((route) => route.isFirst);
        }
      } catch (e) {
        debugPrint('Nav Reset Error: $e');
      }
      
      if (!navContext.mounted) return;

      showModalBottomSheet(
        context: navContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => VCardPreviewSheet(url: cleanUrl, source: 'nfc_intent'),
      );
    } else if (mounted) {
      debugPrint('Context not ready for URL: $cleanUrl, retrying...');
      // Retry once if context wasn't ready
      await Future.delayed(const Duration(milliseconds: 800));
      _handleIncomingUrl(cleanUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BizKonec',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
