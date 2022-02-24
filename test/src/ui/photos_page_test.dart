import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photos/src/data/app_preferences.dart';
import 'package:photos/src/data/photos_repository.dart';
import 'package:photos/src/logic/photos_cubit.dart';
import 'package:photos/src/ui/photos_page.dart';

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

  // Disable Network Images for testing purposes
  setUpAll(() => HttpOverrides.global = null);

  testWidgets(
    'When emits Success should show a list of photos',
    (tester) async {
      final uri = Uri.parse(
          'https://jsonplaceholder.typicode.com/photos?_start=0&_limit=10');
      final response = Response(successfulGetPhotos, 200);

      when(() => client.get(uri)).thenAnswer(
        (invocation) => Future.value(response),
      );

      when(() => preferences.getStringList(any()))
          .thenAnswer((_) => Future.value([]));

      await _createWidget(tester, repository);

      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);
    },
  );
}

Future<void> _createWidget(
  WidgetTester tester,
  HttpPhotosRepository repository,
) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<PhotosCubit>(
        create: (context) => PhotosCubit(repository)..getPhotos(),
        child: const PhotosPage(),
      ),
    ),
  );
}
