import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextflix/core/models/media.dart';
import 'package:nextflix/features/home/providers/home_providers.dart';

class SearchState {
  final String query;
  final String type; // 'all', 'movie', 'tv'
  final int? selectedGenreId;

  SearchState({
    this.query = '',
    this.type = 'all',
    this.selectedGenreId,
  });

  SearchState copyWith({
    String? query,
    String? type,
    int? selectedGenreId,
  }) {
    return SearchState(
      query: query ?? this.query,
      type: type ?? this.type,
      selectedGenreId: selectedGenreId, // Note: can be null
    );
  }
}

final searchStateProvider = StateProvider<SearchState>((ref) => SearchState());

final movieGenresProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(tmdbServiceProvider).getGenres('movie');
});

final tvGenresProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(tmdbServiceProvider).getGenres('tv');
});

final searchResultsProvider = FutureProvider<List<Media>>((ref) async {
  final state = ref.watch(searchStateProvider);
  if (state.query.isEmpty) return [];

  return ref.watch(tmdbServiceProvider).searchMedia(
    state.query,
    type: state.type == 'all' ? null : state.type,
    genreId: state.selectedGenreId,
  );
});
