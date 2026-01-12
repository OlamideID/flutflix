import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/features/movie_details/model/movie_details_model.dart';
import 'package:netflix/features/movie_details/services/movie_fav.dart';

final myListServiceProvider = Provider<MyListService>((ref) => MyListService());

final myListProvider = FutureProvider<List<MyListMovie>>((ref) async {
  final service = ref.read(myListServiceProvider);
  return await service.getMyList();
});

// Provider to check if a specific movie is in my list
final isInMyListProvider = FutureProvider.family<bool, int>((ref, movieId) async {
  final service = ref.read(myListServiceProvider);
  return await service.isInMyList(movieId);
});

// Provider for my list count
final myListCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(myListServiceProvider);
  return await service.getMyListCount();
});

// State notifier for managing my list operations
class MyListNotifier extends StateNotifier<AsyncValue<List<MyListMovie>>> {
  final MyListService _service;
  final Ref _ref;

  MyListNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _loadMyList();
  }

  Future<void> _loadMyList() async {
    try {
      final movies = await _service.getMyList();
      state = AsyncValue.data(movies);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addMovie(Moviedetail movie) async {
    final success = await _service.addToMyList(movie);
    if (success) {
      await _loadMyList();
      // Invalidate related providers
      _ref.invalidate(isInMyListProvider(movie.id));
      _ref.invalidate(myListCountProvider);
    }
    return success;
  }

  Future<bool> removeMovie(int movieId) async {
    final success = await _service.removeFromMyList(movieId);
    if (success) {
      await _loadMyList();
      // Invalidate related providers
      _ref.invalidate(isInMyListProvider(movieId));
      _ref.invalidate(myListCountProvider);
    }
    return success;
  }

  Future<bool> clearList() async {
    final success = await _service.clearMyList();
    if (success) {
      state = const AsyncValue.data([]);
      // Invalidate all related providers
      _ref.invalidate(isInMyListProvider);
      _ref.invalidate(myListCountProvider);
    }
    return success;
  }

  Future<bool> cleanupList() async {
    final success = await _service.cleanupMyList();
    if (success) {
      await _loadMyList();
      _ref.invalidate(myListCountProvider);
    }
    return success;
  }

  // Refresh the list
  Future<void> refresh() async {
    await _loadMyList();
  }
}

// Provider for the notifier
final myListNotifierProvider = StateNotifierProvider<MyListNotifier, AsyncValue<List<MyListMovie>>>((ref) {
  final service = ref.read(myListServiceProvider);
  return MyListNotifier(service, ref);
});