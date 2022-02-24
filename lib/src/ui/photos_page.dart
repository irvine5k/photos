import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photos/src/data/models/photo_model.dart';
import 'package:photos/src/logic/photos_cubit.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({Key? key}) : super(key: key);

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  late final ScrollController _scrollController = ScrollController()
    ..addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 5) {
        context.read<PhotosCubit>().getPhotos();
      }
    });

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Photos'),
      ),
      body: BlocBuilder<PhotosCubit, PhotosState>(
        builder: (context, state) => ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: state.photos.length + 1,
          itemBuilder: (context, index) => itemBuilder(state, index),
        ),
      ),
    );
  }

  Widget itemBuilder(PhotosState state, int index) {
    if (state.photos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (index >= state.photos.length) {
      return state is LoadingState
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const SizedBox();
    }

    final photo = state.photos[index];

    return _PhotoTileWidget(
      photo: photo,
      onLike: (photo) => context.read<PhotosCubit>().persistLike(photo),
    );
  }
}

class _PhotoTileWidget extends StatelessWidget {
  const _PhotoTileWidget({
    Key? key,
    required this.photo,
    this.onLike,
  }) : super(key: key);

  final PhotoModel photo;
  final ValueChanged<PhotoModel>? onLike;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(photo.thumbnailUrl),
        title: Text(photo.title),
        trailing: IconButton(
          onPressed: onLike != null ? () => onLike!(photo) : null,
          icon: photo.isLiked
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border),
        ),
        onTap: () {
          showBottomSheet<void>(
              context: context,
              builder: (context) => Image.network(photo.imageUrl));
        },
      ),
    );
  }
}
