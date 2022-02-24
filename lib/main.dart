import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:photos/src/data/app_preferences.dart';
import 'package:photos/src/data/photos_repository.dart';
import 'package:photos/src/logic/photos_cubit.dart';
import 'package:photos/src/ui/photos_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<PhotosCubit>(
        create: (context) {
          final client = Client();
          final preferences = LocalAppPreferences();
          final repository = HttpPhotosRepository(
            client: client,
            preferences: preferences,
          );

          return PhotosCubit(repository)..getPhotos();
        },
        child: const PhotosPage(),
      ),
    );
  }
}
