import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextflix/core/models/media.dart';
import 'package:nextflix/features/home/providers/home_providers.dart';

final creditsProvider = FutureProvider.family<List<Map<String, dynamic>>, ({int id, String type})>((ref, arg) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return tmdbService.getCredits(arg.id, arg.type);
});

final similarProvider = FutureProvider.family<List<Media>, ({int id, String type})>((ref, arg) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return tmdbService.getSimilar(arg.id, arg.type);
});

final mediaDetailsProvider = FutureProvider.family<Map<String, dynamic>, ({int id, String type})>((ref, arg) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return tmdbService.getMediaDetails(arg.id, arg.type);
});
