import 'dart:convert';

import 'package:equatable/equatable.dart';

class PhotoModel extends Equatable {
  const PhotoModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.isLiked = false,
  });

  factory PhotoModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, Object?>;
    return PhotoModel.fromJson(json);
  }

  factory PhotoModel.fromJson(
    Map<String, Object?> json, [
    bool isLiked = false,
  ]) =>
      PhotoModel(
        id: json['id'] as int,
        title: json['title'] as String,
        imageUrl: json['url'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        isLiked: isLiked,
      );

  final int id;
  final String title;
  final String imageUrl;
  final String thumbnailUrl;
  final bool isLiked;

  Map<String, Object> toJson() => {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
        'isLiked': isLiked,
      };

  String toJsonString() => jsonEncode(toJson());

  PhotoModel toggleLike() => PhotoModel(
        id: id,
        title: title,
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        isLiked: !isLiked,
      );

  @override
  List<Object?> get props => [
        id,
        isLiked,
      ];
}
