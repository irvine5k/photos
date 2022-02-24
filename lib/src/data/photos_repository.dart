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
    final response =
        await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

    final data = _bodyToMapList(response.body);

    final photos = data
        .map(
          (photo) => _mergeWithLikeInfo(
            photo,
            likedPhotosIds,
          ),
        )
        .toList();

    return photos;
  }

  List<Map<String, Object?>> _bodyToMapList(String body) {
    final decodedBody = jsonDecode(body) as List<Object?>;
    return decodedBody.map((object) => object as Map<String, Object?>).toList();
  }

  PhotoModel _mergeWithLikeInfo(
    Map<String, Object?> photoJson,
    List<String> likedIds,
  ) {
    final isPhotoLiked =
        likedIds.firstWhereOrNull((id) => int.parse(id) == photoJson['id']) !=
            null;

    return PhotoModel.fromJson(photoJson, isPhotoLiked);
  }

  @override
  Future<bool> persistLikes(List<PhotoModel> likedPhotos) {
    final likedIds = likedPhotos.map((photo) => photo.id.toString()).toList();
    return _preferences.setStringList(_likedPhotoIdsKey, likedIds);
  }
}
