import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photos/src/data/app_preferences.dart';
import 'package:photos/src/data/models/photo_model.dart';
import 'package:photos/src/data/photos_repository.dart';
import 'package:photos/src/logic/photos_cubit.dart';

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

  blocTest<PhotosCubit, PhotosState>(
    'When repository succeed should emit [Loading, Success]',
    build: () {
      final uri = Uri.parse(
          'https://jsonplaceholder.typicode.com/photos?_start=0&_limit=10');
      final response = Response(successfulGetPhotos, 200);

      when(() => client.get(uri)).thenAnswer(
        (invocation) => Future.value(response),
      );

      when(() => preferences.getStringList(any()))
          .thenAnswer((_) => Future.value([]));

      return PhotosCubit(repository);
    },
    act: (bloc) => bloc.getPhotos(),
    expect: () {
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

      return [
        const LoadingState(),
        LoadedState(expectedPhotos),
      ];
    },
  );

  blocTest<PhotosCubit, PhotosState>(
    'When repository fails should emit [Loading, Error]',
    build: () {
      final uri = Uri.parse(
          'https://jsonplaceholder.typicode.com/photos?_start=0&_limit=10');

      when(() => client.get(uri)).thenThrow(Exception());

      when(() => preferences.getStringList(any()))
          .thenAnswer((_) => Future.value([]));

      return PhotosCubit(repository);
    },
    act: (bloc) => bloc.getPhotos(),
    expect: () => [
      const LoadingState(),
      const ErrorState(),
    ],
  );

  blocTest<PhotosCubit, PhotosState>(
    'When preferences succeed should emit [LoadedState]',
    build: () {
      final uri = Uri.parse(
          'https://jsonplaceholder.typicode.com/photos?_start=0&_limit=10');

      final response = Response(successfulGetPhotos, 200);

      when(() => client.get(uri)).thenAnswer(
        (invocation) => Future.value(response),
      );

      when(() => preferences.getStringList(any()))
          .thenAnswer((_) => Future.value([]));

      when(() => preferences.setStringList(any(), any()))
          .thenAnswer((_) => Future.value(true));

      return PhotosCubit(repository);
    },
    act: (bloc) async {
      await bloc.getPhotos();
      bloc.persistLike(
        const PhotoModel(
          id: 1,
          title: 'accusamus beatae ad facilis cum similique qui sunt',
          imageUrl: 'https://via.placeholder.com/600/92c952',
          thumbnailUrl: 'https://via.placeholder.com/600/92c952',
        ),
      );
    },
    expect: () {
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

      final expectedPhotosAfterLike = [
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

      return [
        const LoadingState(),
        LoadedState(expectedPhotos),
        LoadedState(expectedPhotosAfterLike),
      ];
    },
  );
}
