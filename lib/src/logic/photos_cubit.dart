import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photos/src/data/models/photo_model.dart';
import 'package:photos/src/data/photos_repository.dart';

part 'photos_state.dart';

class PhotosCubit extends Cubit<PhotosState> {
  PhotosCubit(IPhotosRepository repository)
      : _repository = repository,
        super(const LoadingState());

  final IPhotosRepository _repository;

  Future<void> getPhotos() async {
    try {
      emit(const LoadingState());

      final position = state.photos.isNotEmpty ? state.photos.last.id : 0;
      final newPhotos = await _repository.getPhotos(position);

      emit(LoadedState([...state.photos, ...newPhotos]));
    } catch (e) {
      return emit(const ErrorState());
    }
  }

  Future<void> persistLike(PhotoModel photo) async {
    final photos = [...state.photos];

    final index = photos.indexOf(photo);

    if (index == -1) {
      return;
    }

    photos
      ..removeAt(index)
      ..insert(index, photo.toggleLike());

    final likedPhotos = photos
        .where(
          (photo) => photo.isLiked,
        )
        .toList();

    final success = await _repository.persistLikes(likedPhotos);

    if (success) {
      return emit(LoadedState(photos));
    }
  }
}
