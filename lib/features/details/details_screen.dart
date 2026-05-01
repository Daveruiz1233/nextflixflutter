import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextflix/core/models/media.dart';
import 'package:nextflix/core/theme/app_colors.dart';
import 'package:nextflix/features/library/providers/library_provider.dart';
import 'package:nextflix/features/details/providers/details_providers.dart';
import 'package:nextflix/features/home/widgets/media_row.dart';


class DetailsScreen extends ConsumerWidget {
  final Media media;
  final String heroContext;

  const DetailsScreen({
    required this.media,
    this.heroContext = 'default',
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInLibrary = ref.watch(libraryProvider.notifier).isInLibrary(media.id);
    final arg = (id: media.id, type: media.mediaType);
    
    final detailsAsync = ref.watch(mediaDetailsProvider(arg));
    final creditsAsync = ref.watch(creditsProvider(arg));
    final similarAsync = ref.watch(similarProvider(arg));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeroSection(context, ref, detailsAsync, isInLibrary),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Overview
                Text(
                  media.overview ?? '',
                  style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 16),
                ),
                const SizedBox(height: 30),
                _buildCastSection(creditsAsync),
                const SizedBox(height: 30),
                _buildSimilarSection(similarAsync),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref, AsyncValue<Map<String, dynamic>> detailsAsync, bool isInLibrary) {
    return SliverAppBar(
      expandedHeight: 650,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black.withOpacity(0.3),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop Image
            Hero(
              tag: 'media-${media.id}-${heroContext}',
              child: Image.network(
                media.backdropUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.image, size: 100, color: AppColors.textDim),
                ),
              ),
            ),
            
            // Premium Gradients
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 0.8, 1.0],
                  colors: [
                    Colors.black45,
                    Colors.transparent,
                    AppColors.background,
                    AppColors.background,
                  ],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0x990A0A0F),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Content Floating at bottom
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Genres
                  detailsAsync.when(
                    data: (details) {
                      final genres = (details['genres'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: genres.take(3).map((g) => _buildGenreBadge(g['name'])).toList(),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.premiumGradient.createShader(bounds),
                    child: Text(
                      media.displayName,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                  
                  // Tagline
                  detailsAsync.when(
                    data: (details) => details['tagline'] != null && details['tagline'] != ''
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              details['tagline'],
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Meta Info
                  Row(
                    children: [
                      _buildMetaIcon(Icons.star, AppColors.primary, media.voteAverage.toStringAsFixed(1)),
                      const SizedBox(width: 20),
                      _buildMetaIcon(Icons.calendar_month, Colors.grey, media.displayDate.split('-')[0]),
                      const SizedBox(width: 20),
                      detailsAsync.when(
                        data: (details) {
                          dynamic runtime = details['runtime'];
                          if (runtime == null) {
                            final List? runtimes = details['episode_run_time'];
                            if (runtimes != null && runtimes.isNotEmpty) {
                              runtime = runtimes[0];
                            }
                          }
                          if (runtime == null) return const SizedBox.shrink();
                          return _buildMetaIcon(Icons.access_time, Colors.grey, '${runtime}m');
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Primary CTA
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              final url = media.mediaType == 'movie' 
                                ? 'https://vidsrc-embed.ru/embed/movie?tmdb=${media.id}' 
                                : 'https://vidsrc-embed.ru/embed/tv?tmdb=${media.id}&season=1&episode=1';
                              context.push('/extractor', extra: {'url': url});
                            },
                            icon: const Icon(Icons.play_arrow, size: 28),
                            label: const Text('Watch Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildCircleAction(
                        icon: isInLibrary ? Icons.check : Icons.add,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(libraryProvider.notifier).toggleLibrary(media);
                        },
                        active: isInLibrary,
                      ),
                      const SizedBox(width: 12),
                      _buildCircleAction(icon: Icons.share, onTap: () => HapticFeedback.lightImpact()),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreBadge(String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: Colors.white.withOpacity(0.1),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaIcon(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildCircleAction({required IconData icon, required VoidCallback onTap, bool active = false}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            color: active ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.1),
            child: Icon(icon, color: active ? AppColors.primary : Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildCastSection(AsyncValue<List<Map<String, dynamic>>> creditsAsync) {
    return creditsAsync.when(
      data: (cast) {
        if (cast.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Cast',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cast.length.clamp(0, 15),
                itemBuilder: (context, index) {
                  final actor = cast[index];
                  final profilePath = actor['profile_path'];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 15),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.surface,
                          backgroundImage: profilePath != null
                              ? NetworkImage('https://image.tmdb.org/t/p/w185$profilePath')
                              : null,
                          child: profilePath == null ? const Icon(Icons.person, color: Colors.white) : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          actor['name'] ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSimilarSection(AsyncValue<List<Media>> similarAsync) {
    return similarAsync.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return MediaRow(title: 'More Like This', mediaList: list);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
