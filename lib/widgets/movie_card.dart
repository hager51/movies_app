import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../screens/movie_details_screen.dart';
import '../utils/app_colors.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final double width;
  final double height;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 140,
    this.height = 210,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movieId: movie.id),
          ),
        );
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            buildPoster(),
            buildRatingBadge(),
          ],
        ),
      ),
    );
  }

  Widget buildPoster() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        movie.mediumCoverImage,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.card,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.yellow),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('IMAGE ERROR: $error | URL: ${movie.mediumCoverImage}');
          return Container(
            width: width,
            height: height,
            color: AppColors.card,
            child: const Icon(Icons.movie, color: AppColors.grey),
          );
        },
      ),
    );
  }

  Widget buildRatingBadge() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              movie.rating.toString(),
              style: const TextStyle(color: AppColors.white, fontSize: 12),
            ),
            const SizedBox(width: 4),
            Image.asset('assets/Icons/star_icon.png', width: 12),
          ],
        ),
      ),
    );
  }
}