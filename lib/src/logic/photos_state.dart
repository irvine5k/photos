part of 'photos_cubit.dart';

abstract class PhotosState extends Equatable {
  const PhotosState({this.photos = const []});

  final List<PhotoModel> photos;

  @override
  List<Object?> get props => [];
}

class LoadingState extends PhotosState {
  const LoadingState({List<PhotoModel> photos = const []})
      : super(photos: photos);

  @override
  List<Object?> get props => [];
}

class LoadedState extends PhotosState {
  const LoadedState(List<PhotoModel> photos) : super(photos: photos);

  @override
  List<Object?> get props => [photos];
}

class ErrorState extends PhotosState {
  const ErrorState({List<PhotoModel> photos = const []})
      : super(photos: photos);

  @override
  List<Object?> get props => [];
}
