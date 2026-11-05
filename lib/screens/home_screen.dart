import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/movies_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/movie_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatelessWidget {
  // بتفتح تاب الـ Browse لما تدوسي See More
  final VoidCallback onSeeMorePressed;

  const HomeScreen({super.key, required this.onSeeMorePressed});

  @override
  Widget build(BuildContext context) {
    final api = MoviesApiService();

    return SafeArea(
      child: FutureBuilder<List<List<MovieModel>>>(
        future: Future.wait([
          api.getMovies(limit: 10, minimumRating: 7),
          api.getMovies(genre: 'Action', limit: 10),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong, check your internet',
                style: const TextStyle(color: AppColors.white),
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
      ),
    );
  }

  // الجزء الكبير فوق: Available Now + بوسترات كبيرة + Watch Now
  Widget buildAvailableNow(List<MovieModel> movies) {
    return Column(
      children: [
        const SizedBox(height: 20),
        buildTitleImage(
          'assets/images/available_now.png',
          'Available Now',
          fallbackSize: 36,
        ),
        const SizedBox(height: 20),
        CarouselSlider(
          options: CarouselOptions(
            height: 400,
            viewportFraction: 0.7,
            enlargeCenterPage: true,
            enlargeFactor: 0.3,
            enableInfiniteScroll: false,
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
    );
  }

  // بتعرض صورة العنوان، ولو مش موجودة بترجع للنص العادي
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

  // قسم النوع (Action مثلاً): العنوان + See More + صف أفلام
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
                onTap: onSeeMorePressed,
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