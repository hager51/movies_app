import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/movies_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onSeeMorePressed;

  const HomeScreen({super.key, required this.onSeeMorePressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MoviesApiService api = MoviesApiService();
  late final Future<List<List<MovieModel>>> moviesFuture;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    moviesFuture = Future.wait([
      api.getMovies(limit: 10, minimumRating: 7),
      api.getMovies(genre: 'Action', limit: 10),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<MovieModel>>>(
      future: moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.yellow),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Something went wrong, check your internet',
              style: TextStyle(color: AppColors.white),
            ),
          );
        }

        final availableMovies = snapshot.data![0];
        final actionMovies = snapshot.data![1];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAvailableNow(availableMovies),
              buildGenreSection('Action', actionMovies),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget buildAvailableNow(List<MovieModel> movies) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        if (movies.isNotEmpty) buildBackground(movies[currentIndex]),
        Column(
          children: [
            SizedBox(height: topPadding + 20),
            buildTitleImage(
              'assets/images/available_now.png',
              'Available Now',
              fallbackSize: 36,
            ),
            const SizedBox(height: 20),
            CarouselSlider(
              options: CarouselOptions(
                height: 400,
                viewportFraction: 0.6,
                enlargeCenterPage: true,
                enlargeFactor: 0.3,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() => currentIndex = index);
                },
              ),
              items: movies.map((movie) {
                return MovieCard(movie: movie, width: 240, height: 360);
              }).toList(),
            ),
            const SizedBox(height: 20),
            buildTitleImage(
              'assets/images/watch_now.png',
              'Watch Now',
              fallbackSize: 40,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  Widget buildBackground(MovieModel movie) {
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Stack(
          key: ValueKey(movie.id),
          fit: StackFit.expand,
          children: [
            Image.network(
              movie.largeCoverImage,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColors.background);
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withOpacity(0.7),
                    AppColors.background.withOpacity(0.85),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitleImage(
      String imagePath,
      String fallbackText, {
        required double fallbackSize,
      }) {
    return Image.asset(
      imagePath,
      height: 70,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          fallbackText,
          style: TextStyle(
            color: AppColors.white,
            fontSize: fallbackSize,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        );
      },
    );
  }

  Widget buildGenreSection(String genre, List<MovieModel> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                genre,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: widget.onSeeMorePressed,
                child: const Text(
                  'See More >',
                  style: TextStyle(color: AppColors.yellow, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: movies.map((movie) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: MovieCard(movie: movie),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}