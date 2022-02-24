import 'dart:convert';

import 'package:http/http.dart';
import 'package:photos/src/data/app_preferences.dart';
import 'package:photos/src/data/models/photo_model.dart';
import 'package:collection/collection.dart';

abstract class IPhotosRepository {
  Future<List<PhotoModel>> getPhotos([int position = 0]);
  Future<bool> persistLikes(List<PhotoModel> likedPhotos);
}

class HttpPhotosRepository implements IPhotosRepository {
  const HttpPhotosRepository({
    required Client client,
    required IAppPreferences preferences,
  })  : _client = client,
        _preferences = preferences;

  final Client _client;
  final IAppPreferences _preferences;

  static const _likedPhotoIdsKey = 'likedPhotoIds';

  @override
  Future<List<PhotoModel>> getPhotos([int position = 0]) async {
    final url =
        'https://jsonplaceholder.typicode.com/photos?_start=$position&_limit=10';

    final likedPhotosIds =
        await _preferences.getStringList(_likedPhotoIdsKey) ?? [];
    final response = await _client.get(Uri.parse(url));

    final data = (jsonDecode(response.body) as List<Object?>)
        .map((object) => object as Map<String, Object?>)
        .toList();

    final photos = data.map((photo) {
      final isPhotoLiked = likedPhotosIds
              .firstWhereOrNull((id) => int.parse(id) == photo['id']) !=
          null;

      return PhotoModel.fromJson(photo, isPhotoLiked);
    }).toList();

    return photos;
  }

  @override
  Future<bool> persistLikes(List<PhotoModel> likedPhotos) {
    final likedIds = likedPhotos.map((photo) => photo.id.toString()).toList();
    return _preferences.setStringList(_likedPhotoIdsKey, likedIds);
  }
}
