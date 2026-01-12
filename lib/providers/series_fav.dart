// providers/series_fav_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/models/series_details.dart';
import 'package:netflix/features/series/services/series_fav.dart';

final seriesFavoritesServiceProvider = Provider<SeriesFavoritesService>((ref) => SeriesFavoritesService());

final seriesFavoritesProvider = FutureProvider<List<FavoriteSeries>>((ref) async {
  final service = ref.read(seriesFavoritesServiceProvider);
  return await service.getFavorites();
});

// Provider to check if a specific series is in favorites
final isSeriesInFavoritesProvider = FutureProvider.family<bool, int>((ref, seriesId) async {
  final service = ref.read(seriesFavoritesServiceProvider);
  return await service.isInFavorites(seriesId);
});

// State notifier for managing series favorites operations
class SeriesFavoritesNotifier extends StateNotifier<AsyncValue<List<FavoriteSeries>>> {
  final SeriesFavoritesService _service;
  final Ref _ref;

  SeriesFavoritesNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final series = await _service.getFavorites();
      state = AsyncValue.data(series);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addSeries(SeriesDetails series) async {
    final success = await _service.addToFavorites(series);
    if (success) {
      await _loadFavorites();
      // Invalidate the specific series check
      _ref.invalidate(isSeriesInFavoritesProvider(series.id));
    }
    return success;
  }

  Future<bool> removeSeries(int seriesId) async {
    final success = await _service.removeFromFavorites(seriesId);
    if (success) {
      await _loadFavorites();
      // Invalidate the specific series check
      _ref.invalidate(isSeriesInFavoritesProvider(seriesId));
    }
    return success;
  }

  Future<bool> clearFavorites() async {
    final success = await _service.clearFavorites();
    if (success) {
      state = const AsyncValue.data([]);
      // Invalidate all series checks
      _ref.invalidate(isSeriesInFavoritesProvider);
    }
    return success;
  }
}

// Provider for the notifier
final seriesFavoritesNotifierProvider = StateNotifierProvider<SeriesFavoritesNotifier, AsyncValue<List<FavoriteSeries>>>((ref) {
  final service = ref.read(seriesFavoritesServiceProvider);
  return SeriesFavoritesNotifier(service, ref);
});