import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photos/src/data/app_preferences.dart';
import 'package:photos/src/data/models/photo_model.dart';
import 'package:photos/src/data/photos_repository.dart';

import '../aux/fake_responses.dart';

class MockClient extends Mock implements Client {}

class MockAppPreferences extends Mock implements IAppPreferences {}

void main() {
  late HttpPhotosRepository repository;
  late Client client;
  late IAppPreferences preferences;

  setUp(() {
    client = MockClient();
    preferences = MockAppPreferences();
    repository = HttpPhotosRepository(client: client, preferences: preferences);
  });

  group('Given an empty list of liked photos', () {
    test(
      'When get photos successfuly should return a list of photos without likes',
      () async {
        final uri = Uri.parse(
            'https://jsonplaceholder.typicode.com/photos?_start=0&_limit=10');
        final response = Response(successfulGetPhotos, 200);

        when(() => client.get(uri)).thenAnswer(
          (invocation) => Future.value(response),
        );

        when(() => preferences.getStringList(any()))
            .thenAnswer((_) => Future.value([]));

        final expectedPhotos = [
          const PhotoModel(
            id: 1,
            title: 'accusamus beatae ad facilis cum similique qui sunt',
            imageUrl: 'https://via.placeholder.com/600/92c952',
            thumbnailUrl: 'https://via.placeholder.com/600/92c952',
          ),
          const PhotoModel(
            id: 2,
            title: 'reprehenderit est deserunt velit ipsam',
            imageUrl: 'https://via.placeholder.com/600/771796',
            thumbnailUrl: 'https://via.placeholder.com/150/771796',
          )
        ];

        expect(await repository.getPhotos(), expectedPhotos);
      },
    );

    test(
      'When get photos fails should throws an exception',
      () async {
        final uri = Uri.parse(
            'https://jsonplaceholder.typicode.com/photos?_start=0&_limit=10');

        when(() => client.get(uri)).thenThrow(Exception());

        when(() => preferences.getStringList(any()))
            .thenAnswer((_) => Future.value([]));

        expect(repository.getPhotos(), throwsException);
      },
    );
  });

  group('Given a list of liked photos', () {
    test(
      'When get photos successfuly should return a list of photos without likes',
      () async {
        final uri = Uri.parse(
            'https://jsonplaceholder.typicode.com/photos?_start=0&_limit=10');
        final response = Response(successfulGetPhotos, 200);

        when(() => client.get(uri)).thenAnswer(
          (invocation) => Future.value(response),
        );

        when(() => preferences.getStringList(any()))
            .thenAnswer((_) => Future.value(['1']));

        final expectedPhotos = [
          const PhotoModel(
            id: 1,
            title: 'accusamus beatae ad facilis cum similique qui sunt',
            imageUrl: 'https://via.placeholder.com/600/92c952',
            thumbnailUrl: 'https://via.placeholder.com/600/92c952',
            isLiked: true,
          ),
          const PhotoModel(
            id: 2,
            title: 'reprehenderit est deserunt velit ipsam',
            imageUrl: 'https://via.placeholder.com/600/771796',
            thumbnailUrl: 'https://via.placeholder.com/150/771796',
          )
        ];

        expect(await repository.getPhotos(), expectedPhotos);
      },
    );
  });

  group('persistLikes', () {
    test(
      'When preferences persist info with success should return true',
      () async {
        when(() => preferences.setStringList(any(), any()))
            .thenAnswer((_) => Future.value(true));

        final likedPhotos = [
          const PhotoModel(
            id: 1,
            title: 'accusamus beatae ad facilis cum similique qui sunt',
            imageUrl: 'https://via.placeholder.com/600/92c952',
            thumbnailUrl: 'https://via.placeholder.com/600/92c952',
            isLiked: true,
          ),
          const PhotoModel(
            id: 2,
            title: 'reprehenderit est deserunt velit ipsam',
            imageUrl: 'https://via.placeholder.com/600/771796',
            thumbnailUrl: 'https://via.placeholder.com/150/771796',
            isLiked: true,
          )
        ];

        expect(await repository.persistLikes(likedPhotos), true);
      },
    );

    test(
      'When preferences persist info fails should return false',
      () async {
        when(() => preferences.setStringList(any(), any()))
            .thenAnswer((_) => Future.value(false));

        final likedPhotos = [
          const PhotoModel(
            id: 1,
            title: 'accusamus beatae ad facilis cum similique qui sunt',
            imageUrl: 'https://via.placeholder.com/600/92c952',
            thumbnailUrl: 'https://via.placeholder.com/600/92c952',
            isLiked: true,
          ),
          const PhotoModel(
            id: 2,
            title: 'reprehenderit est deserunt velit ipsam',
            imageUrl: 'https://via.placeholder.com/600/771796',
            thumbnailUrl: 'https://via.placeholder.com/150/771796',
            isLiked: true,
          )
        ];

        expect(await repository.persistLikes(likedPhotos), false);
      },
    );
  });
}
