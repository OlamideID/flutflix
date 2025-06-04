import 'package:flutter/material.dart';
import 'package:netflix/components/cards/series_card.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/screens/home.dart';

class SeriesSection extends StatelessWidget {
  final Future<PopularTvSeries?> future;
  final String sectionTitle;
  final bool isReverse;

  const SeriesSection({
    super.key,
    required this.future,
    required this.sectionTitle,
    this.isReverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: sectionTitle),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: FutureBuilder<PopularTvSeries?>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } else if (snapshot.hasError) {
                  return ErrorDisplay(error: snapshot.error.toString());
                } else if (snapshot.hasData) {
                  final seriesList = snapshot.data!.results;

                  if (seriesList.isEmpty) {
                    return const NoDataDisplay(message: 'No series found');
                  }

                  return SeriesList(
                    seriesList: seriesList,
                    isReverse: isReverse,
                  );
                } else {
                  return const NoDataDisplay();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// widgets/common/section_title.dart
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

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
    final displaySeries = isReverse ? seriesList.reversed.toList() : seriesList;

    return ListView.builder(
      reverse: isReverse,
      scrollDirection: Axis.horizontal,
      itemCount: displaySeries.length,
      itemBuilder: (context, index) {
        final series = displaySeries[index];
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: SeriesCard(series: series),
        );
      },
    );
  }
}
