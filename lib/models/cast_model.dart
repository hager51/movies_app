import 'movie_model.dart';

class CastModel {
  final String name;
  final String characterName;
  final String imageUrl;

  CastModel({
    required this.name,
    required this.characterName,
    required this.imageUrl,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] ?? '',
      characterName: json['character_name'] ?? '',
      imageUrl: fixImageUrl(json['url_small_image'] ?? ''),
    );
  }
}