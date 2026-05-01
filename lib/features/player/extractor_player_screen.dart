import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:nextflix/core/theme/app_colors.dart';

class ExtractorPlayerScreen extends StatefulWidget {
  final String? initialUrl;
  const ExtractorPlayerScreen({super.key, this.initialUrl});

  @override
  State<ExtractorPlayerScreen> createState() => _ExtractorPlayerScreenState();
}

class _ExtractorPlayerScreenState extends State<ExtractorPlayerScreen> {
  InAppWebViewController? webViewController;
  WebViewEnvironment? webViewEnvironment;
  
  // Use a Set for faster O(1) lookup to prevent UI lag with many resources
  final Set<String> _extractedLinksSet = {};
  final List<String> extractedLinks = [];
  
  bool _isLoading = true;
  bool _isEnvLoading = true;
  String? _errorMessage;
  
  // Throttling timer to batch setState calls
  Timer? _batchTimer;
  final List<String> _pendingLinks = [];

  @override
  void initState() {
    super.initState();
    _initWebViewEnvironment();
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    super.dispose();
  }

  Future<void> _initWebViewEnvironment() async {
    try {
      if (Platform.isWindows) {
        final availableVersion = await WebViewEnvironment.getAvailableVersion();
        if (availableVersion == null) {
          setState(() {
            _errorMessage = 'WebView2 Runtime not found. Please install it to use the player.';
            _isEnvLoading = false;
          });
          return;
        }

        final appSupportDir = await getApplicationSupportDirectory();
        final userDataFolder = p.join(appSupportDir.path, 'nextflix_webview_data');
        
        webViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(userDataFolder: userDataFolder)
        );
      }
      
      if (mounted) {
        setState(() {
          _isEnvLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error initializing WebView environment: $e';
          _isEnvLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEnvLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Link Extractor (Optimized)'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _extractedLinksSet.clear();
                extractedLinks.clear();
              });
              webViewController?.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. WebView Surface (Embedded Player)
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                InAppWebView(
                  webViewEnvironment: webViewEnvironment,
                  initialUrlRequest: URLRequest(
                    url: WebUri(widget.initialUrl ?? 'https://vidsrc-embed.ru/embed/movie?tmdb=385687'),
                  ),
                  initialSettings: InAppWebViewSettings(
                    // CRITICAL: Removed useShouldInterceptRequest as it can cause deadlocks/hangs on Windows
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                    // Mobile-specific optimization
                    allowsInlineMediaPlayback: true,
                    useOnDownloadStart: true,
                    // Prevent ads from opening new windows/tabs on your 2GB emulator
                    supportMultipleWindows: false,
                    javaScriptCanOpenWindowsAutomatically: false,
                    // Use a modern, clean User Agent
                    userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
                  ),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onCreateWindow: (controller, createWindowAction) async {
                    // Block all pop-ups to save RAM on the emulator
                    debugPrint('🚫 Blocked an attempted ad pop-up');
                    return false; 
                  },
                  onLoadStart: (controller, url) {
                    setState(() => _isLoading = true);
                  },
                  onLoadStop: (controller, url) {
                    setState(() => _isLoading = false);
                  },
                  onLoadResource: (controller, resource) {
                    final url = resource.url.toString();
                    _handleResource(url);
                  },
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ],
            ),
          ),

          // 2. Extracted Links Panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Extracted Links (${extractedLinks.length})',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (extractedLinks.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() {
                      _extractedLinksSet.clear();
                      extractedLinks.clear();
                    }),
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),
          
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: extractedLinks.isEmpty
                  ? const Center(
                      child: Text(
                        'Interact with the player above to trigger link extraction.\nM3U8/MPD links will appear here and in terminal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white30, fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: extractedLinks.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (context, index) {
                        final url = extractedLinks[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace'),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_circle_fill, size: 24, color: AppColors.primary),
                                onPressed: () {
                                  context.push('/player', extra: {'url': url});
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18, color: Colors.white54),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: url));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                                  );
                                },
                              ),
                            ],
                          ),

                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleResource(String url) {
    // 1. Efficient string filtering
    final bool isStreamLink = url.contains('.m3u8') || 
                              url.contains('.mpd') || 
                              url.contains('master.m3u8') || 
                              url.contains('index.m3u8');
    
    if (isStreamLink) {
      // 2. O(1) duplicate check to prevent UI saturation
      if (!_extractedLinksSet.contains(url)) {
        _extractedLinksSet.add(url);
        
        // Log to terminal (doesn't block UI)
        debugPrint('🎯 EXTRACTED: $url');
        
        // 3. Batch setState updates to prevent "Not Responding" hangs
        _pendingLinks.add(url);
        _scheduleBatchUpdate();
      }
    }
  }

  void _scheduleBatchUpdate() {
    if (_batchTimer?.isActive ?? false) return;
    
    _batchTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _pendingLinks.isNotEmpty) {
        setState(() {
          extractedLinks.addAll(_pendingLinks);
          _pendingLinks.clear();
        });
      }
    });
  }
}
