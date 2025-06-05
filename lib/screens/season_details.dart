import 'package:flutter/material.dart';
import 'package:netflix/models/season_details.dart';
import 'package:netflix/services/api_service.dart';

class SeasonDetails extends StatefulWidget {
  const SeasonDetails({
    super.key,
    required this.id,
    this.seasonNumber,
    this.seasonName,
  });
  final int id;
  final int? seasonNumber;
  final String? seasonName;

  @override
  State<SeasonDetails> createState() => _SeasonDetailsState();
}

class _SeasonDetailsState extends State<SeasonDetails> {
  final ApiService apiService = ApiService();
  late Future<Seasondetails?> series;

  @override
  void initState() {
    super.initState();
    fetchSeasonData();
  }

  fetchSeasonData() {
    series = apiService.getSeasonDetails(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seasonName ?? 'Season Details'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<Seasondetails?>(
        future: series,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        fetchSeasonData();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'No series data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final seasonDetails = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(seasonDetails),
                const SizedBox(height: 24),

                // Overview Section
                _buildOverviewSection(seasonDetails),
                const SizedBox(height: 24),

                // Details Section
                _buildDetailsSection(seasonDetails),
                const SizedBox(height: 24),

                // Seasons List
                _buildSeasonsSection(seasonDetails),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(Seasondetails details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster
        Container(
          width: 120,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[800],
          ),
          // ignore: unnecessary_null_comparison
          child:
              details.posterPath != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${details.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.movie,
                          color: Colors.grey,
                          size: 48,
                        );
                      },
                    ),
                  )
                  : const Icon(Icons.movie, color: Colors.grey, size: 48),
        ),
        const SizedBox(width: 16),

        // Title and basic info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (details.originalName != details.name) ...[
                const SizedBox(height: 4),
                Text(
                  details.originalName,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                details.tagline,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${details.voteAverage}/10',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${details.numberOfSeasons} Season${details.numberOfSeasons != 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewSection(Seasondetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details.overview,
          style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(Seasondetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('Status', details.status),
        _buildDetailRow('First Air Date', _formatDate(details.firstAirDate)),
        _buildDetailRow('Last Air Date', _formatDate(details.lastAirDate)),
        _buildDetailRow('Episodes', '${details.numberOfEpisodes}'),
        _buildDetailRow('Genres', details.genres.map((g) => g.name).join(', ')),
        if (details.networks.isNotEmpty)
          _buildDetailRow(
            'Networks',
            details.networks.map((n) => n.name).join(', '),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonsSection(Seasondetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seasons',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: details.seasons.length,
          itemBuilder: (context, index) {
            final season = details.seasons[index];
            return _buildSeasonCard(season);
          },
        ),
      ],
    );
  }

  Widget _buildSeasonCard(Season season) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Season poster
            Container(
              width: 60,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[800],
              ),
              child:
                  season.posterPath != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w200${season.posterPath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.tv,
                              color: Colors.grey,
                              size: 24,
                            );
                          },
                        ),
                      )
                      : const Icon(Icons.tv, color: Colors.grey, size: 24),
            ),
            const SizedBox(width: 12),

            // Season info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    season.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${season.episodeCount} episodes',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(season.airDate),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  if (season.overview.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      season.overview,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
