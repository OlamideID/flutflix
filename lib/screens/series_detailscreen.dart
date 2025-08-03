// Updated series_details_screen.dart - Add these imports and modifications

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/components/series/widgets/episode_card.dart';
import 'package:netflix/components/series/widgets/header_section.dart';
import 'package:netflix/components/series/widgets/info_card.dart';
import 'package:netflix/components/series/widgets/recommendedseries.dart';
import 'package:netflix/components/series/widgets/season_card.dart';
import 'package:netflix/components/series/widgets/series_cast.dart';
import 'package:netflix/components/series/widgets/similar_series.dart';
import 'package:netflix/models/series_details.dart';
import 'package:netflix/providers/series_fav.dart';
import 'package:netflix/screens/my_list.dart';
import 'package:netflix/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

final seriesDetailsProvider = FutureProvider.family<SeriesDetails?, int>((
  ref,
  id,
) async {
  final api = ApiService();
  return await api.seriesDetail(id);
});

class SeriesDetailsScreen extends ConsumerStatefulWidget {
  const SeriesDetailsScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<SeriesDetailsScreen> createState() =>
      _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final seriesAsync = ref.watch(seriesDetailsProvider(widget.id));
    final isInFavoritesAsync = ref.watch(
      isSeriesInFavoritesProvider(widget.id),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: seriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Text(
                'Error loading series: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        data: (series) {
          if (series == null) {
            return const Center(
              child: Text(
                'No series data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              HeaderSection(series: series),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add to Favorites Button
                      _buildFavoritesButton(series, isInFavoritesAsync),
                      const SizedBox(height: 16),

                      if (series.tagline.isNotEmpty)
                        _buildTagline(series.tagline),
                      _buildSectionTitle(series.name),
                      _buildSectionTitle('Overview'),
                      Text(
                        series.overview,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      InfoCard(series: series),
                      const SizedBox(height: 24),
                      if (series.genres.isNotEmpty)
                        _buildGenresSection(series.genres),
                      if (series.seasons.isNotEmpty)
                        _buildSeasonsSection(series.seasons, series),
                      _buildLastEpisodeSection(series.lastEpisodeToAir),
                      if (series.networks.isNotEmpty)
                        _buildNetworksSection(series.networks),
                      if (series.productionCompanies.isNotEmpty)
                        _buildProductionCompaniesSection(
                          series.productionCompanies,
                        ),
                      if (series.createdBy.isNotEmpty)
                        _buildCreatedBySection(series.createdBy),
                      _buildAdditionalInfoSection(series),
                      const SizedBox(height: 24),
                      SeriesCastSection(tvId: widget.id),
                      SimilarSeriesSection(seriesId: widget.id),
                      RecommendedSeriesSection(seriesId: widget.id),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFavoritesButton(
    SeriesDetails series,
    AsyncValue<bool> isInFavoritesAsync,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isInFavoritesAsync.when(
        loading:
            () => ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Loading...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
        error:
            (_, __) => ElevatedButton(
              onPressed:
                  () => ref.refresh(isSeriesInFavoritesProvider(widget.id)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Retry', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
        data:
            (isInFavorites) => ElevatedButton(
              onPressed: () => _toggleFavorites(series, isInFavorites),
              style: ElevatedButton.styleFrom(
                backgroundColor: isInFavorites ? Colors.red : Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isInFavorites ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isInFavorites ? 'Remove from My List' : 'Add to My List',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Future<void> _toggleFavorites(
    SeriesDetails series,
    bool isCurrentlyInFavorites,
  ) async {
    final notifier = ref.read(seriesFavoritesNotifierProvider.notifier);
    bool success = false;
    String message = '';

    if (isCurrentlyInFavorites) {
      success = await notifier.removeSeries(series.id);
      message =
          success
              ? '${series.name} removed from My List'
              : 'Failed to remove from My List';
    } else {
      success = await notifier.addSeries(series);
      message =
          success
              ? '${series.name} added to My List'
              : 'Series already in My List';
    }

    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);

      // Clear any existing SnackBars before showing a new one
      messenger.clearSnackBars();

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
          action:
              success && !isCurrentlyInFavorites
                  ? SnackBarAction(
                    label: 'VIEW LIST',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyListScreen(),
                        ),
                      );
                    },
                  )
                  : null,
        ),
      );
    }
  }

  Widget _buildTagline(String tagline) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        '"$tagline"',
        style: const TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGenresSection(List<Genre> genres) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Genres'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              genres
                  .map(
                    (genre) => Chip(
                      label: Text(genre.name),
                      backgroundColor: Colors.grey[850],
                      labelStyle: const TextStyle(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSeasonsSection(List<Season> seasons, SeriesDetails series) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Seasons'),
        ...seasons.map((season) => SeasonCard(season: season, series: series)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLastEpisodeSection(LastEpisodeToAir episode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Last Episode To Air'),
        EpisodeCard(episode: episode),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNetworksSection(List<Network> networks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Networks'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              networks.map((network) {
                return Column(
                  children: [
                    if (network.logoPath != null)
                      Image.network(
                        'https://image.tmdb.org/t/p/w92${network.logoPath}',
                        width: 80,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    Text(
                      network.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                );
              }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProductionCompaniesSection(List<Network> companies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Production Companies'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              companies.map((company) {
                return Column(
                  children: [
                    if (company.logoPath != null)
                      Image.network(
                        'https://image.tmdb.org/t/p/w92${company.logoPath}',
                        width: 80,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    Text(
                      company.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                );
              }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCreatedBySection(List<CreatedBy> creators) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Created By'),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: creators.length,
            itemBuilder: (context, index) {
              final creator = creators[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          creator.profilePath != null
                              ? NetworkImage(
                                'https://image.tmdb.org/t/p/w185${creator.profilePath}',
                              )
                              : null,
                      child:
                          creator.profilePath == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      creator.name,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(SeriesDetails series) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Additional Info'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildInfoRow('Origin Country', series.originCountry.join(', ')),
              _buildInfoRow('Original Name', series.originalName),
              _buildInfoRow('Popularity', series.popularity.toStringAsFixed(0)),
              if (series.homepage.isNotEmpty)
                _buildInfoRowWithLink('Homepage', series.homepage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithLink(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: InkWell(
              onTap: () => launchUrl(Uri.parse(url)),
              child: Text(
                url,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
