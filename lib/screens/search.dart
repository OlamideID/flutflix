import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/models/person_search.dart'; // Add this import
import 'package:netflix/components/movies/models/search_movie.dart';
import 'package:netflix/models/search_tv.dart';
import 'package:netflix/providers/providers.dart';
import 'package:netflix/screens/actor_profile_screen.dart';
import 'package:netflix/screens/movie_details.dart';
import 'package:netflix/screens/series_detailscreen.dart';
// import 'package:netflix/screens/person_details.dart'; // You'll need to create this

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
    _controller = TextEditingController();
    _controller.text = ref.read(searchQueryProvider);
    _controller.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _controller.text.trim();
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchType = ref.watch(searchTypeProvider);
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            query.isNotEmpty
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
                        hintText: "Search for a title or person",
                        hintStyle: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF999999),
                          size: 24,
                        ),
                        suffixIcon:
                            query.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Color(0xFF999999),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _controller.clear();
                                    ref
                                        .read(searchQueryProvider.notifier)
                                        .state = "";
                                  },
                                )
                                : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: resultsAsync.when(
                data: (results) {
                  if (query.isEmpty || results == null) {
                    return _buildEmptyState();
                  }

                  final items =
                      searchType == SearchType.movie
                          ? (results as SearchMovie).results
                          : searchType == SearchType.tv
                          ? (results as SearchTV).results
                          : (results as Perasonsearch).results;

                  if (items.isEmpty) {
                    return _buildNoResultsState();
                  }

                  return _buildResultsList(items, searchType);
                },
                loading: () => _buildLoadingState(),
                error: (e, _) => _buildErrorState(e.toString()),
              ),
            ),
          ],
        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: const Color(0xFF666666), size: 64),
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
            const Text(
              "Find your next favorite title or celebrity",
              style: TextStyle(color: Color(0xFF999999), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.search_off, color: Color(0xFF666666), size: 64),
          const SizedBox(height: 16),
          const Text(
            "Your search did not have any matches.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Try different keywords or remove search filters.",
            style: TextStyle(color: Color(0xFF999999), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFE50914), // Netflix red
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE50914), size: 64),
          const SizedBox(height: 16),
          const Text(
            "Something went wrong",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please try again later",
            style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<dynamic> items, SearchType searchType) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final rawItem = items[index];

        if (searchType == SearchType.person) {
          final item = rawItem as Result;
          return _buildPersonResultItem(
            item.profilePath,
            item.id,
            item.name,
            item.knownForDepartment,
            item.knownFor,
          );
        } else {
          final String? posterPath;
          final int id;
          final String title;
          final String? overview;

          if (searchType == SearchType.movie) {
            final item = rawItem as MovieResult;
            posterPath = item.posterPath;
            id = item.id;
            title = item.title;
            overview = item.overview;
          } else {
            final item = rawItem as TVResult;
            posterPath = item.posterPath;
            id = item.id;
            title = item.name;
            overview = item.overview;
          }

          return _buildResultItem(posterPath, id, title, overview, searchType);
        }
      },
    );
  }

  Widget _buildResultItem(
    String? posterPath,
    int id,
    String title,
    String? overview,
    SearchType searchType,
  ) {
    return InkWell(
      onTap: () {
        if (searchType == SearchType.movie) {
          print('Movie id is $id');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: id)),
          );
        } else {
          print('Series id is $id');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SeriesDetailsScreen(id: id)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child:
                    posterPath != null
                        ? Hero(
                          tag: "$searchType-$id",
                          child: Image.network(
                            "https://image.tmdb.org/t/p/w300$posterPath",
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => _buildImagePlaceholder(),
                          ),
                        )
                        : _buildImagePlaceholder(),
              ),
            ),

            const SizedBox(width: 16),

            // Content
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
                  if (overview != null && overview.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      overview,
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

            // Play button
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonResultItem(
    String? profilePath,
    int id,
    String name,
    String knownForDepartment,
    List<KnownFor> knownFor,
  ) {
    return InkWell(
      onTap: () {
        print('Person id is $id');
        // Navigate to person details screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActorProfileScreen(actorId: id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child:
                    profilePath != null
                        ? Hero(
                          tag: "person-$id",
                          child: Image.network(
                            "https://image.tmdb.org/t/p/w300$profilePath",
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => _buildPersonPlaceholder(),
                          ),
                        )
                        : _buildPersonPlaceholder(),
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
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
                    knownForDepartment,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (knownFor.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Known for: ${knownFor.take(3).map((e) => e.title ?? e.name ?? '').where((title) => title.isNotEmpty).join(', ')}",
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

            // Info icon for person
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF333333),
      child: const Icon(Icons.movie, color: Color(0xFF666666), size: 32),
    );
  }

  Widget _buildPersonPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF333333),
      child: const Icon(Icons.person, color: Color(0xFF666666), size: 32),
    );
  }

  void _onTabPressed(SearchType type) {
    ref.read(searchTypeProvider.notifier).state = type;
    ref.read(searchQueryProvider.notifier).state = "";
    _controller.clear();
  }
}
