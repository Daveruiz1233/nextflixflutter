import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextflix/features/home/services/tmdb_service.dart';
import 'package:nextflix/core/models/media.dart';

final tmdbServiceProvider = Provider((ref) => TMDBService());

final trendingMoviesProvider = FutureProvider<List<Media>>((ref) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getTrending();
});

final popularMoviesProvider = FutureProvider<List<Media>>((ref) async {
  return ref.watch(tmdbServiceProvider).getPopular();
});

final topRatedTVProvider = FutureProvider<List<Media>>((ref) async {
  return ref.watch(tmdbServiceProvider).getTopRated();
});
