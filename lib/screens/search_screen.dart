import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/movies_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final MoviesApiService api = MoviesApiService();

  Timer? debounceTimer;
  List<MovieModel> results = [];
  bool isLoading = false;
  bool hasError = false;

  @override
  void dispose() {
    debounceTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void onTextChanged(String text) {
    debounceTimer?.cancel();

    if (text.trim().isEmpty) {
      setState(() {
        results = [];
        isLoading = false;
        hasError = false;
      });
      return;
    }

    debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchMovies(text.trim());
    });
  }

  Future<void> searchMovies(String query) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final movies = await api.getMovies(query: query, limit: 30);
      if (!mounted) return;
      if (searchController.text.trim() != query) return;
      setState(() {
        results = movies;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        results = [];
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSearchField(),
            const SizedBox(height: 20),
            buildBody(),
          ],
        ),
      ),
    );
  }

  Widget buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: onTextChanged,
      textInputAction: TextInputAction.search,
      onSubmitted: (text) {
        debounceTimer?.cancel();
        if (text.trim().isNotEmpty) searchMovies(text.trim());
      },
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(color: AppColors.white),
        filled: true,
        fillColor: AppColors.card,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Image.asset('assets/Icons/Search_icon.png', width: 22),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(color: AppColors.yellow),
      );
    }
    if (hasError) {
      return buildMessage('Something went wrong, check your internet');
    }
    if (results.isEmpty) {
      return buildEmptyState();
    }
    return buildResultsGrid();
  }

  Widget buildMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Text(text, style: const TextStyle(color: AppColors.white)),
    );
  }

  Widget buildEmptyState() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.25),
      child: Image.asset(
        'assets/images/empty_state.png',
        width: 120,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.movie_outlined,
            color: AppColors.yellow,
            size: 80,
          );
        },
      ),
    );
  }

  Widget buildResultsGrid() {
    final cardWidth = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: results.map((movie) {
        return MovieCard(
          movie: movie,
          width: cardWidth,
          height: cardWidth * 1.5,
        );
      }).toList(),
    );
  }
}