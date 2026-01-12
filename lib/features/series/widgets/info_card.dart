import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netflix/models/series_details.dart';

class InfoCard extends StatelessWidget {
  final SeriesDetails series;
  final dateFormat = DateFormat.yMMMMd();

  InfoCard({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Status', series.status),
          _buildInfoRow('Type', series.type),
          _buildInfoRow('In Production', series.inProduction ? 'Yes' : 'No'),
          _buildInfoRow(
            'First Air Date',
            dateFormat.format(series.firstAirDate),
          ),
          _buildInfoRow('Last Air Date', dateFormat.format(series.lastAirDate)),
          _buildInfoRow('Seasons', series.numberOfSeasons.toString()),
          _buildInfoRow('Episodes', series.numberOfEpisodes.toString()),
          _buildInfoRow(
            'Original Language',
            series.originalLanguage.toUpperCase(),
          ),
        ],
      ),
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
}
