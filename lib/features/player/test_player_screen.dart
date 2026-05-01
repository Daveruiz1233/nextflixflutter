import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nextflix/core/theme/app_colors.dart';

class TestPlayerScreen extends StatefulWidget {
  final String? initialUrl;
  const TestPlayerScreen({super.key, this.initialUrl});

  @override
  State<TestPlayerScreen> createState() => _TestPlayerScreenState();
}

class _TestPlayerScreenState extends State<TestPlayerScreen> {
  late final Player player;
  late final VideoController controller;
  final TextEditingController _urlController = TextEditingController();
  
  bool _isPlaying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePlay();
      });
    }

    // 1. Initialize Player
    player = Player();
    // 2. Initialize VideoController
    controller = VideoController(player);


    // Listen for errors
    player.stream.error.listen((error) {
      setState(() {
        _error = error.toString();
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _handlePlay() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isPlaying = true;
      _error = null;
    });

    try {
      debugPrint('🚀 Attempting to play: $url');
      // No headers, just the raw URL
      await player.open(Media(url));
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Direct HLS Test Player'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. URL Input
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'M3U8 / MP4 URL',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'https://example.com/master.m3u8',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () => _urlController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Play Button
            ElevatedButton.icon(
              onPressed: _handlePlay,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test Play (No Headers)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Player Surface
            if (_isPlaying || _error != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '❌ Error: $_error',
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Video(controller: controller),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // 4. Debug Info
            const Text(
              'Tips:\n• If it fails with "403 Forbidden", it means the server requires a Referer header.\n• If it fails with "Open failed", check if the URL is accessible in your browser.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
