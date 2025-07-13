import 'package:flutter/material.dart';
import 'package:netflix/components/series/season_cast.dart';

class SeasonCastWidget extends StatelessWidget {
  final int seriesId;
  final int seasonNumber;

  const SeasonCastWidget({
    super.key,
    required this.seriesId,
    required this.seasonNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SeasonCastSection(
      seriesId: seriesId,
      seasonNumber: seasonNumber,
    );
  }
}