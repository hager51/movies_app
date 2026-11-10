import 'cast_model.dart';

class MovieModel {
  final int id;
  final String title;
  final int year;
  final double rating;
  final int runtime;
  final int likeCount;
  final String summary;
  final List<String> genres;
  final String mediumCoverImage;
  final String largeCoverImage;
  final String backgroundImage;
  final List<String> screenshots;
  final List<CastModel> cast;

  MovieModel({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.likeCount,
    required this.summary,
    required this.genres,
    required this.mediumCoverImage,
    required this.largeCoverImage,
    required this.backgroundImage,
    required this.screenshots,
    required this.cast,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final screenshots = <String>[];
    for (int i = 1; i <= 3; i++) {
      final url = json['large_screenshot_image$i'];
      if (url != null && url.toString().isNotEmpty) {
        screenshots.add(fixImageUrl(url));
      }
    }

    final castList = <CastModel>[];
    if (json['cast'] != null) {
      for (final item in json['cast']) {
        castList.add(CastModel.fromJson(item));
      }
    }

    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      year: json['year'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      runtime: json['runtime'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      summary: json['description_full'] ?? json['summary'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      mediumCoverImage: fixImageUrl(json['medium_cover_image'] ?? ''),
      largeCoverImage: fixImageUrl(json['large_cover_image'] ?? ''),
      backgroundImage: fixImageUrl(json['background_image_original'] ?? ''),
      screenshots: screenshots,
      cast: castList,
    );
  }

  factory MovieModel.fromSaved(Map<String, dynamic> data) {
    return MovieModel(
      id: data['id'] ?? 0,
      title: data['title'] ?? '',
      year: 0,
      rating: (data['rating'] ?? 0).toDouble(),
      runtime: 0,
      likeCount: 0,
      summary: '',
      genres: [],
      mediumCoverImage: data['image'] ?? '',
      largeCoverImage: data['image'] ?? '',
      backgroundImage: '',
      screenshots: [],
      cast: [],
    );
  }
}

String fixImageUrl(String url) {
  return url.replaceFirst('://yts.gg/', '://img.yts.gg/');
}