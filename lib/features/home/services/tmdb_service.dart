import 'package:nextflix/core/api/tmdb_client.dart';
import 'package:nextflix/core/models/media.dart';
import 'package:flutter/foundation.dart';

class TMDBService {
  final TMDBClient _client = TMDBClient();

  Future<List<Media>> getTrending() async {
    try {
      final response = await _client.get('/trending/all/day');
      return (response.data['results'] as List)
          .map((m) => Media.fromJson(m))
          .toList();
    } catch (e) {
      return _getMockMedia();
    }
  }

  Future<List<Media>> getPopular() async {
    try {
      final response = await _client.get('/movie/popular');
      return (response.data['results'] as List)
          .map((m) => Media.fromJson(m))
          .toList();
    } catch (e) {
      return _getMockMedia();
    }
  }

  Future<List<Media>> getTopRated() async {
    try {
      final response = await _client.get('/tv/top_rated');
      return (response.data['results'] as List)
          .map((m) => Media.fromJson(m))
          .toList();
    } catch (e) {
      return _getMockMedia();
    }
  }

  Future<List<Media>> searchMedia(String query, {String? type, int? genreId}) async {
    try {
      if (type == 'movie') {
        return searchMovies(query, genreId: genreId);
      } else if (type == 'tv') {
        return searchTV(query, genreId: genreId);
      }

      final response = await _client.get('/search/multi', queryParameters: {
        'query': query,
      });
      
      final results = (response.data['results'] as List);
      debugPrint('TMDB Search Multi: Found ${results.length} raw results');
      
      return results
          .map((m) {
            try {
              return Media.fromJson(m);
            } catch (e) {
              debugPrint('TMDB Search Error mapping: $e');
              return null;
            }
          })
          .whereType<Media>()
          .where((m) => m.mediaType != 'person')
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Media>> searchMovies(String query, {int? genreId}) async {
    try {
      final params = {'query': query};
      if (genreId != null) params['with_genres'] = genreId.toString();
      
      final response = await _client.get('/search/movie', queryParameters: params);
      return (response.data['results'] as List)
          .map((m) => Media.fromJson({...m, 'media_type': 'movie'}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Media>> searchTV(String query, {int? genreId}) async {
    try {
      final params = {'query': query};
      if (genreId != null) params['with_genres'] = genreId.toString();

      final response = await _client.get('/search/tv', queryParameters: params);
      return (response.data['results'] as List)
          .map((m) => Media.fromJson({...m, 'media_type': 'tv'}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGenres(String type) async {
    try {
      final response = await _client.get('/genre/$type/list');
      return (response.data['genres'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getMediaDetails(int id, String type) async {
    try {
      final response = await _client.get('/$type/$id');
      return response.data;
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getCredits(int id, String type) async {
    try {
      final response = await _client.get('/$type/$id/credits');
      return (response.data['cast'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<List<Media>> getSimilar(int id, String type) async {
    try {
      final response = await _client.get('/$type/$id/similar');
      return (response.data['results'] as List)
          .map((m) => Media.fromJson(m))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<Media> _getMockMedia() {
    return [
      Media(
        id: 1,
        title: 'Interstellar',
        overview: 'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
        posterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        backdropPath: '/rAiDLKRv5P6A8hWc78GvbeS8oJ1.jpg',
        releaseDate: '2014-11-05',
        voteAverage: 8.4,
        mediaType: 'movie',
      ),
      Media(
        id: 2,
        title: 'The Dark Knight',
        overview: 'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets.',
        posterPath: '/qJ2tW6WMUDp9QEQvTlvqEnORvll.jpg',
        backdropPath: '/nMKdUUtnkbviS8n30vXdzPlaR1P.jpg',
        releaseDate: '2008-07-16',
        voteAverage: 8.5,
        mediaType: 'movie',
      ),
      Media(
        id: 3,
        title: 'Stranger Things',
        overview: 'When a young boy vanishes, a small town uncovers a mystery involving secret experiments, terrifying supernatural forces and one strange little girl.',
        posterPath: '/49WJfev0moxmBEEp7VFr7Yp34uS.jpg',
        backdropPath: '/56v2KjHfs7Mxz3bfvYJqYZaUvC8.jpg',
        releaseDate: '2016-07-15',
        voteAverage: 8.6,
        mediaType: 'tv',
      ),
      Media(
        id: 4,
        title: 'Inception',
        overview: 'Cobb, a skilled thief who steals information from people’s dreams, is offered a chance to have his criminal history erased as payment for the implantation of another person\'s idea into a target\'s subconscious.',
        posterPath: '/edv5CZvj0VeF97oLc6vEGvGLHr3.jpg',
        backdropPath: '/8Z0R78mZMebZ9wwvSj4869uN96A.jpg',
        releaseDate: '2010-07-15',
        voteAverage: 8.3,
        mediaType: 'movie',
      ),
    ];
  }
}
