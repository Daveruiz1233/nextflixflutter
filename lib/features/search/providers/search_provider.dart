import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextflix/features/home/providers/home_providers.dart';
import 'package:nextflix/core/models/media.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Media>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final service = ref.watch(tmdbServiceProvider);
  
  // Debounce logic is handled by the UI updating the searchQueryProvider
  return service.searchMedia(query);
});
