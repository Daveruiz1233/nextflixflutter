import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nextflix/features/home/providers/home_providers.dart';
import 'package:nextflix/features/home/widgets/hero_carousel.dart';
import 'package:nextflix/features/home/widgets/media_row.dart';
import 'package:nextflix/core/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingMoviesProvider);
    final popular = ref.watch(popularMoviesProvider);
    final topRated = ref.watch(topRatedTVProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/0/08/Netflix_2015_logo.svg',
          height: 30,
          errorBuilder: (context, error, stackTrace) => const Text(
            'NEXTFLIX',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () => context.push('/search'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            trending.when(
              data: (media) => HeroCarousel(mediaList: media.take(5).toList()),
              loading: () => const SizedBox(height: 500, child: Center(child: CircularProgressIndicator())),
              error: (e, s) => const SizedBox(height: 500, child: Center(child: Text('Error loading hero'))),
            ),

            // Trending Now Row
            trending.when(
              data: (media) => MediaRow(title: 'Trending Now', mediaList: media),
              loading: () => const MediaRow(title: 'Trending Now', isLoading: true),
              error: (e, s) => Container(),
            ),

            // Popular Movies Row
            popular.when(
              data: (media) => MediaRow(title: 'Popular Movies', mediaList: media),
              loading: () => const MediaRow(title: 'Popular Movies', isLoading: true),
              error: (e, s) => Container(),
            ),

            // Top Rated TV Row
            topRated.when(
              data: (media) => MediaRow(title: 'Top Rated TV Shows', mediaList: media),
              loading: () => const MediaRow(title: 'Top Rated TV Shows', isLoading: true),
              error: (e, s) => Container(),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
