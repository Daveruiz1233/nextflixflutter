import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:nextflix/core/models/media.dart';
import 'package:nextflix/core/theme/app_colors.dart';

import 'package:flutter/services.dart';

class HeroCarousel extends StatefulWidget {
  final List<Media> mediaList;

  const HeroCarousel({super.key, required this.mediaList});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.mediaList.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 600.0,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 8),
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          items: widget.mediaList.map((media) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => context.push('/details', extra: {
                    'media': media,
                    'heroContext': 'carousel',
                  }),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Backdrop Image
                      Hero(
                        tag: 'media-${media.id}-carousel',
                        child: Image.network(
                          media.backdropUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.movie, size: 100, color: AppColors.textDim),
                          ),
                        ),
                      ),
                      
                      // Premium Gradients (Matching Original)
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.4, 0.7, 1.0],
                            colors: [
                              Colors.black38,
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
                              Color(0xCC0A0A0F),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Left-aligned Content
                      Positioned(
                        bottom: 60,
                        left: 20,
                        right: 20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => AppColors.premiumGradient.createShader(bounds),
                              child: Text(
                                media.displayName,
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1.5,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Meta Info
                            Row(
                              children: [
                                Icon(Icons.star, color: AppColors.primary, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  media.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  media.displayDate.split('-')[0],
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(width: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white38),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    media.mediaType.toUpperCase(),
                                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Overview (Limited to match premium clean look)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                media.overview ?? '',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 14),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Action Buttons
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    final url = media.mediaType == 'movie' 
                                      ? 'https://vidsrc-embed.ru/embed/movie?tmdb=${media.id}' 
                                      : 'https://vidsrc-embed.ru/embed/tv?tmdb=${media.id}&season=1&episode=1';
                                    context.push('/extractor', extra: {'url': url});
                                  },
                                  icon: const Icon(Icons.play_arrow, size: 24),
                                  label: const Text('Play', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () => context.push('/details', extra: {
                                    'media': media,
                                    'heroContext': 'carousel',
                                  }),
                                  icon: const Icon(Icons.info_outline, size: 24),
                                  label: const Text('More Info'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white38),
                                    backgroundColor: Colors.black26,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
        
        // Slide Indicators (Bottom Left)
        Positioned(
          bottom: 30,
          left: 20,
          child: Row(
            children: widget.mediaList.asMap().entries.map((entry) {
              return Container(
                width: _currentIndex == entry.key ? 24.0 : 8.0,
                height: 4.0,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentIndex == entry.key ? AppColors.primary : Colors.white38,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
