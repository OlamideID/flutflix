
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/features/movies/models/search_movie.dart';
import 'package:netflix/models/person_search.dart';
import 'package:netflix/models/search_tv.dart';
import 'package:netflix/providers/search.dart';
import 'package:netflix/screens/actor_profile_screen.dart';
import 'package:netflix/screens/movie_details.dart';
import 'package:netflix/screens/series_detailscreen.dart';


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _lockPortrait();

    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _onTextChanged() {
    final text = _controller.text;
    ref.read(debouncedSearchProvider.notifier).updateQuery(text);
  }

  void _lockPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchType = ref.watch(searchTypeProvider);
    final currentInput = ref.watch(debouncedSearchProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(currentInput),
            const SizedBox(height: 20),
            Expanded(
              child: _buildContent(
                searchQuery,
                currentInput,
                resultsAsync,
                searchType,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String currentInput) {
    final searchType = ref.watch(searchTypeProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with animation
          Row(
            children: [
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_slideAnimation.value, 0),
                    child: const Text(
                      "Search",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search input
          _buildSearchInput(currentInput),
          const SizedBox(height: 20),

          // Category tabs
          _buildCategoryTabs(searchType),
        ],
      ),
    );
  }

  Widget _buildSearchInput(String currentInput) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              currentInput.isNotEmpty
                  ? Colors.white.withOpacity(0.8)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: "Search movies, TV shows, people...",
          hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 16),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF999999),
            size: 24,
          ),
          suffixIcon:
              currentInput.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      color: Color(0xFF999999),
                      size: 20,
                    ),
                    onPressed: _clearSearch,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(SearchType searchType) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          _buildCategoryTab(
            "Movies",
            searchType == SearchType.movie,
            () => _onTabPressed(SearchType.movie),
          ),
          const SizedBox(width: 16),
          _buildCategoryTab(
            "TV Shows",
            searchType == SearchType.tv,
            () => _onTabPressed(SearchType.tv),
          ),
          const SizedBox(width: 16),
          _buildCategoryTab(
            "People",
            searchType == SearchType.person,
            () => _onTabPressed(SearchType.person),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : const Color(0xFF666666),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    String searchQuery,
    String currentInput,
    AsyncValue resultsAsync,
    SearchType searchType,
  ) {
    // Show different states based on search status
    if (searchQuery.isEmpty) {
      return _buildEmptyState(currentInput);
    }

    return resultsAsync.when(
      data: (results) => _buildSearchResults(results, searchType),
      loading: () => _buildLoadingState(),
      error: (e, _) => _buildErrorState(),
    );
  }

  Widget _buildEmptyState(String currentInput) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, color: Color(0xFF666666), size: 64),
            const SizedBox(height: 16),
            const Text(
              "Search for movies, TV shows, and people",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              currentInput.isNotEmpty && currentInput.length < 2
                  ? "Type at least 2 characters to search"
                  : "Find your next favorite content",
              style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(dynamic results, SearchType searchType) {
    if (results == null) return _buildEmptyState('');

    final items =
        searchType == SearchType.movie
            ? (results as SearchMovie).results
            : searchType == SearchType.tv
            ? (results as SearchTV).results
            : (results as Perasonsearch).results;

    if (items.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder:
          (context, index) => _buildResultItem(items[index], searchType),
    );
  }

  Widget _buildResultItem(dynamic item, SearchType searchType) {
    if (searchType == SearchType.person) {
      final person = item as Result;
      return _buildPersonItem(person);
    } else {
      return _buildMediaItem(item, searchType);
    }
  }

  Widget _buildMediaItem(dynamic item, SearchType searchType) {
    final posterPath = item.posterPath as String?;
    final id = item.id as int;
    final title = searchType == SearchType.movie ? item.title : item.name;
    final overview = item.overview as String?;

    return InkWell(
      onTap: () => _navigateToDetails(id, searchType),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(posterPath, "$searchType-$id"),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (overview?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      overview!,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonItem(Result person) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActorProfileScreen(actorId: person.id),
            ),
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(
              person.profilePath,
              "person-${person.id}",
              isPerson: true,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.knownForDepartment,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (person.knownFor.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Known for: ${person.knownFor.take(3).map((e) => e.title ?? e.name ?? '').where((title) => title.isNotEmpty).join(', ')}",
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.info_outline, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(
    String? imagePath,
    String heroTag, {
    bool isPerson = false,
  }) {
    return Container(
      width: 120,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child:
            imagePath != null
                ? Hero(
                  tag: heroTag,
                  child: Image.network(
                    "https://image.tmdb.org/t/p/w300$imagePath",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(isPerson),
                  ),
                )
                : _buildPlaceholder(isPerson),
      ),
    );
  }

  Widget _buildPlaceholder(bool isPerson) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF333333),
      child: Icon(
        isPerson ? Icons.person : Icons.movie,
        color: const Color(0xFF666666),
        size: 32,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            "Searching...",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off, color: Color(0xFF666666), size: 64),
            SizedBox(height: 16),
            Text(
              "No results found",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Try different keywords or filters",
              style: TextStyle(color: Color(0xFF999999), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE50914), size: 64),
            SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Please try again later",
              style: TextStyle(color: Color(0xFF999999), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(int id, SearchType searchType) {
    if (searchType == SearchType.movie) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: id)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SeriesDetailsScreen(id: id)),
      );
    }
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(debouncedSearchProvider.notifier).clearSearch();
  }

  void _onTabPressed(SearchType type) {
    ref.read(searchTypeProvider.notifier).state = type;
  }
}
