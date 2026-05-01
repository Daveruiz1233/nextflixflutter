import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDBClient {
  late Dio _dio;

  TMDBClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('TMDB_BASE_URL'),
        queryParameters: {
          'api_key': dotenv.get('TMDB_API_KEY'),
        },
      ),
    );

    // Interceptors can be added here
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }
}
