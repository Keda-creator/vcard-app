import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

// Mocking user profile for now
final vCardUrlProvider = Provider<String?>((ref) {
  return 'http://vcardpersonal.totalh.net/customer-login.php';
});

class MyVCardScreen extends ConsumerStatefulWidget {
  const MyVCardScreen({super.key});

  @override
  ConsumerState<MyVCardScreen> createState() => _MyVCardScreenState();
}

class _MyVCardScreenState extends ConsumerState<MyVCardScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _canGoBack = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final url = ref.read(vCardUrlProvider);
    if (url != null) {
      _initController(url);
    }
  }

  void _initController(String url) {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            final canBack = await _controller.canGoBack();
            if (mounted) {
              setState(() {
                _isLoading = false;
                _canGoBack = canBack;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.errorCode} - ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
                // Only show UI error for main page load failures, not sub-resource blocking (ORB)
                if (error.isForMainFrame ?? true) {
                  _errorMessage = 'Failed to load vCard: ${error.description}';
                }
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            
            // Allow anything on bizkonec.com or totalh.net to stay inside the WebView
            final isInternal = uri.host.contains('bizkonec.com') || uri.host.contains('totalh.net');

            // Handle actions that the WebView can't do natively
            final isVcf = uri.path.toLowerCase().endsWith('.vcf');
            final isSpecialScheme = uri.scheme != 'http' && uri.scheme != 'https';
            
            if (isVcf || isSpecialScheme || !isInternal) {
              debugPrint('WebView: Redirecting external/profile action to browser: $uri');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    // Platform-specific settings
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vCardUrl = ref.watch(vCardUrlProvider);

    if (vCardUrl == null) {
      return _buildEmptyState();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My vCard'),
        leading: _canGoBack 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  await _controller.goBack();
                }
              },
            )
          : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            _buildErrorState()
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.contact_page_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Your digital business card isn\'t ready yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Set Up My vCard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final url = ref.read(vCardUrlProvider);
                if (url != null) {
                  _controller.loadRequest(Uri.parse(url));
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
