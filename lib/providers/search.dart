import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/providers/providers.dart';

final debouncedSearchProvider =
    StateNotifierProvider<DebouncedSearchNotifier, String>((ref) {
      return DebouncedSearchNotifier(ref);
    });

class DebouncedSearchNotifier extends StateNotifier<String> {
  DebouncedSearchNotifier(this.ref) : super('');

  final Ref ref;
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 500);

  void updateQuery(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      // Clear immediately for empty queries
      state = '';
      ref.read(searchQueryProvider.notifier).state = '';
      return;
    }

    // Update local state immediately for UI
    state = query;

    // Debounce the actual search
    if (query.trim().length >= 2) {
      _debounceTimer = Timer(_debounceDuration, () {
        ref.read(searchQueryProvider.notifier).state = query.trim();
      });
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = '';
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}


enum SearchType { movie, tv, person }

final searchTypeProvider = StateProvider<SearchType>((ref) => SearchType.movie);
final searchQueryProvider = StateProvider<String>((ref) => "");

final searchResultsProvider = FutureProvider((ref) async {
  final query = ref.watch(searchQueryProvider);
  final type = ref.watch(searchTypeProvider);
  final api = ref.read(apiServiceProvider);

  if (query.trim().isEmpty) return null;

  switch (type) {
    case SearchType.movie:
      return await api.searchMovies(query);
    case SearchType.tv:
      return await api.searchTVSeries(query);
    case SearchType.person:
      return await api.searchPerson(query);
  }
});
