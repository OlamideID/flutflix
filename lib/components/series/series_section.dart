import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/components/series/series_card.dart';
import 'package:netflix/helpers/helpers.dart';
import 'package:netflix/screens/series_detailscreen.dart';
import 'package:netflix/services/api_service.dart';

class SeriesSection extends ConsumerWidget {
  final String sectionTitle;
  final bool isReverse;
  final FutureProvider provider;

  const SeriesSection({
    super.key,
    required this.sectionTitle,
    this.isReverse = false,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSeries = ref.watch(provider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {}, // Add "See All" functionality
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220, // Increased height for better visuals
            child: asyncSeries.when(
              loading: () => const _LoadingCarousel(),
              error: (e, _) => ErrorDisplay(error: e.toString()),
              data: (data) {
                final series = data?.results ?? [];
                if (series.isEmpty) return const NoDataDisplay();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: series.length,
                  itemBuilder: (context, index) {
                    final seriesItem =
                        isReverse
                            ? series[series.length - 1 - index]
                            : series[index];
                    return _SeriesCarouselCard(series: seriesItem);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesCarouselCard extends StatefulWidget {
  final dynamic series;

  const _SeriesCarouselCard({required this.series});

  @override
  State<_SeriesCarouselCard> createState() => _SeriesCarouselCardState();
}

class _SeriesCarouselCardState extends State<_SeriesCarouselCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : () => _handleSeriesTap(context),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with Stack
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    // Image Background
                    Positioned.fill(
                      child:
                          widget.series.posterPath != null
                              ? CachedNetworkImage(
                                imageUrl:
                                    "$imageUrl${widget.series.posterPath}",
                                fit: BoxFit.cover,
                                placeholder:
                                    (_, __) =>
                                        Container(color: Colors.grey[900]),
                                errorWidget:
                                    (_, __, ___) => _buildErrorPlaceholder(),
                              )
                              : _buildErrorPlaceholder(),
                    ),

                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                            stops: const [0.7, 1],
                          ),
                        ),
                      ),
                    ),

                    // Play Button
                    // Positioned.fill(
                    //   child: Center(
                    //     child: AnimatedOpacity(
                    //       opacity: _isLoading ? 0 : 1,
                    //       duration: const Duration(milliseconds: 200),
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //           color: Colors.black.withOpacity(0.5),
                    //           shape: BoxShape.circle,
                    //         ),
                    //         padding: const EdgeInsets.all(8),
                    //         child: const Icon(
                    //           Icons.play_arrow,
                    //           color: Colors.white,
                    //           size: 30,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // Loading Indicator
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Text Content
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.series.name ?? 'Unknown Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.series.voteAverage?.toStringAsFixed(1) ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSeriesTap(BuildContext context) async {
    if (widget.series.id == null) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final seriesDetails = await apiService.seriesDetail(widget.series.id);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (seriesDetails == null) {
        _showErrorMessage(context, 'Series details not available');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeriesDetailsScreen(id: widget.series.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorMessage(context, 'Error loading series: ${e.toString()}');
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.tv, color: Colors.white54, size: 40),
      ),
    );
  }
}

class _LoadingCarousel extends StatelessWidget {
  const _LoadingCarousel();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 150,
          margin: const EdgeInsets.only(right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(height: 16, width: 100, color: Colors.grey[800]),
              const SizedBox(height: 4),
              Container(height: 12, width: 40, color: Colors.grey[800]),
            ],
          ),
        );
      },
    );
  }
}

// widgets/common/section_title.dart
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }
}

class SeriesList extends StatelessWidget {
  final List seriesList;
  final bool isReverse;

  const SeriesList({
    super.key,
    required this.seriesList,
    required this.isReverse,
  });

  @override
  Widget build(BuildContext context) {
    if (seriesList.isEmpty) {
      return const Center(
        child: Text(
          "No series available",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final displaySeries = isReverse ? seriesList.reversed.toList() : seriesList;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: displaySeries.length,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final series = displaySeries[index];
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 10),
          child: SeriesCard(series: series),
        );
      },
    );
  }
}
