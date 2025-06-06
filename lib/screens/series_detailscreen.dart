// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:netflix/components/episode_card.dart';
import 'package:netflix/components/header_section.dart';
import 'package:netflix/components/info_card.dart';
import 'package:netflix/components/season_card.dart';
import 'package:netflix/models/series_details.dart';
import 'package:netflix/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SeriesDetailsScreen extends StatefulWidget {
  const SeriesDetailsScreen({super.key, required this.id});
  final int id;

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<SeriesDetails?> _seriesFuture;

  @override
  void initState() {
    super.initState();
    _seriesFuture = _apiService.seriesDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<SeriesDetails?>(
        future: _seriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading series: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No series data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final series = snapshot.data!;

          return CustomScrollView(
            slivers: [
              HeaderSection(series: series),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActionButtons(),
                      const SizedBox(height: 24),

                      if (series.tagline.isNotEmpty)
                        _buildTagline(series.tagline),

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

                      if (series.lastEpisodeToAir != null)
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('My List'),
          ),
        ),
      ],
    );
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
        Wrap(
          spacing: 8,
          children:
              genres
                  .map(
                    (genre) => Chip(
                      label: Text(genre.name),
                      backgroundColor: Colors.grey[900],
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 24),
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
              networks
                  .map(
                    (network) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                    ),
                  )
                  .toList(),
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
              companies
                  .map(
                    (company) => Column(
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
                    ),
                  )
                  .toList(),
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

  // Future<void> _playSeries(String seriesId) async {
  //   final url = 'https://www.themoviedb.org/tv/$seriesId';
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url));
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Could not launch URL')),
  //     );
  //   }
  // }

  // void _addToMyList() {
  //   // Implement your "Add to My List" functionality
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Added to My List')),
  //   );
  // }
}
