import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class MoviesApiService {
  static const String baseUrl = 'https://movies-api.accel.li/api/v2';

  Future<List<MovieModel>> getMovies({
    String? genre,
    String? query,
    int? minimumRating,
    int limit = 20,
    int page = 1,
  }) async {
    final params = {
      'limit': '$limit',
      'page': '$page',
      if (genre != null && genre.isNotEmpty) 'genre': genre,
      if (query != null && query.isNotEmpty) 'query_term': query,
      if (minimumRating != null) 'minimum_rating': '$minimumRating',
    };
    final uri = Uri.parse('$baseUrl/list_movies.json')
        .replace(queryParameters: params);

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load movies');
    }

    final data = jsonDecode(response.body)['data'];
    final movies = data['movies'];
    if (movies == null) return [];

    return List<MovieModel>.from(movies.map((m) => MovieModel.fromJson(m)));
  }

  Future<MovieModel> getMovieDetails(int movieId) async {
    final uri = Uri.parse('$baseUrl/movie_details.json').replace(
      queryParameters: {
        'movie_id': '$movieId',
        'with_images': 'true',
        'with_cast': 'true',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load movie details');
    }

    final data = jsonDecode(response.body)['data'];
    return MovieModel.fromJson(data['movie']);
  }

  Future<List<MovieModel>> getSuggestions(int movieId) async {
    final uri = Uri.parse('$baseUrl/movie_suggestions.json')
        .replace(queryParameters: {'movie_id': '$movieId'});

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load suggestions');
    }

    final data = jsonDecode(response.body)['data'];
    final movies = data['movies'];
    if (movies == null) return [];

    return List<MovieModel>.from(movies.map((m) => MovieModel.fromJson(m)));
  }
}