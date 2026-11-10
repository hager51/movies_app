import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/movies_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/movie_card.dart';
import '../services/user_movies_service.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  Future<List<dynamic>> loadData() async {
    final api = MoviesApiService();
    final movie = await api.getMovieDetails(movieId);
    final similar = await api.getSuggestions(movieId);

    try {
      await UserMoviesService().addToHistory(movie);
    } catch (e) {
      print('HISTORY ERROR: $e');
    }

    return [movie, similar];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<dynamic>>(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow),
            );
          }
          if (snapshot.hasError) {
            return buildErrorView(context);
          }

          final movie = snapshot.data![0] as MovieModel;
          final similar = snapshot.data![1] as List<MovieModel>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(context, movie),
                buildTitleSection(context, movie),
                buildScreenshots(movie),
                buildSimilar(context, similar),
                buildSummary(movie),
                buildCast(movie),
                buildGenres(movie),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildErrorView(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: buildBackButton(context),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Something went wrong, check your internet',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context, MovieModel movie) {
    final height = MediaQuery.of(context).size.height * 0.62;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            movie.largeCoverImage,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: AppColors.card);
            },
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.45, 1.0],
                colors: [Colors.transparent, AppColors.background],
              ),
            ),
          ),
          Center(
            child: Image.asset('assets/Icons/play.png', width: 80),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildBackButton(context),
                    StreamBuilder<bool>(
                      stream: UserMoviesService().isInWatchlist(movie.id),
                      builder: (context, snapshot) {
                        final isSaved = snapshot.data ?? false;
                        return IconButton(
                          onPressed: () {
                            UserMoviesService().toggleWatchlist(movie);
                          },
                          icon: Image.asset(
                            'assets/Icons/save_icon.png',
                            width: 24,
                            color: isSaved ? AppColors.yellow : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 8,
            child: Column(
              children: [
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${movie.year}',
                  style: const TextStyle(color: AppColors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Image.asset('assets/Icons/back_icon.png', width: 24),
    );
  }

  Widget buildTitleSection(BuildContext context, MovieModel movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          buildWatchButton(context),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildInfoChip(
                  'assets/Icons/Like_icon.png',
                  '${movie.likeCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildInfoChip(
                  'assets/Icons/time_icon.png',
                  '${movie.runtime}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildInfoChip(
                  'assets/Icons/star_icon.png',
                  '${movie.rating}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWatchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trailer coming soon')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Watch',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildInfoChip(String iconPath, String value) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 22),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildScreenshots(MovieModel movie) {
    if (movie.screenshots.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Screen Shots'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(movie.screenshots.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    movie.screenshots[index],
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 170,
                        color: AppColors.card,
                        child: const Icon(Icons.image, color: AppColors.grey),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget buildSimilar(BuildContext context, List<MovieModel> similar) {
    if (similar.isEmpty) return const SizedBox();

    final cardWidth = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Similar'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: similar.map((movie) {
              return MovieCard(
                movie: movie,
                width: cardWidth,
                height: cardWidth * 1.5,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildSummary(MovieModel movie) {
    if (movie.summary.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Summary'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            movie.summary,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCast(MovieModel movie) {
    if (movie.cast.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Cast'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: movie.cast.map((actor) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        actor.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: AppColors.background,
                            child: const Icon(
                              Icons.person,
                              color: AppColors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name : ${actor.name}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Character : ${actor.characterName}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildGenres(MovieModel movie) {
    if (movie.genres.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Genres'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: movie.genres.map((genre) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  genre,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}