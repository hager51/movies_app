import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/movies_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/movie_card.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final MoviesApiService api = MoviesApiService();

  static const List<String> genres = [
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Sport',
    'Thriller',
    'War',
    'Western',
  ];

  String selectedGenre = 'Action';
  bool isLoading = false;
  bool hasError = false;

  final Map<String, List<MovieModel>> cache = {};

  @override
  void initState() {
    super.initState();
    loadMovies(selectedGenre);
  }

  Future<void> loadMovies(String genre) async {
    if (cache.containsKey(genre)) {
      setState(() {
        selectedGenre = genre;
        hasError = false;
      });
      return;
    }

    setState(() {
      selectedGenre = genre;
      isLoading = true;
      hasError = false;
    });

    try {
      final movies = await api.getMovies(genre: genre, limit: 30);
      cache[genre] = movies;
      if (!mounted || selectedGenre != genre) return;
      setState(() => isLoading = false);
    } catch (e) {
      if (!mounted || selectedGenre != genre) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          buildGenreTabs(),
          const SizedBox(height: 16),
          Expanded(child: buildBody()),
        ],
      ),
    );
  }

  Widget buildGenreTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: genres.map((genre) => buildGenreChip(genre)).toList(),
      ),
    );
  }

  Widget buildGenreChip(String genre) {
    final isSelected = genre == selectedGenre;

    return GestureDetector(
      onTap: () => loadMovies(genre),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellow, width: 1.5),
        ),
        child: Text(
          genre,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.yellow),
      );
    }
    if (hasError) {
      return buildMessage('Something went wrong, check your internet');
    }

    final movies = cache[selectedGenre] ?? [];
    if (movies.isEmpty) {
      return buildMessage('No movies found');
    }
    return buildMoviesGrid(movies);
  }

  Widget buildMessage(String text) {
    return Center(
      child: Text(text, style: const TextStyle(color: AppColors.white)),
    );
  }

  Widget buildMoviesGrid(List<MovieModel> movies) {
    final cardWidth = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: movies.map((movie) {
              return MovieCard(
                movie: movie,
                width: cardWidth,
                height: cardWidth * 1.5,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}