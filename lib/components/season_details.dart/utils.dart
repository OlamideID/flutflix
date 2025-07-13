import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:netflix/services/api_service.dart';

final seasonDetailsProvider = FutureProvider.family<
    EpisodeDetails?,
    ({int seriesId, int seasonNumber})>((ref, params) async {
  final api = ApiService();

  debugPrint(
    'Fetching episode details for series ${params.seriesId}, season ${params.seasonNumber}',
  );

  var result = await api.getEpisodeDetails(
    params.seriesId,
    params.seasonNumber,
  );

  if (result == null && params.seasonNumber != 1) {
    debugPrint(
      'Season ${params.seasonNumber} not found, trying season 1 as fallback',
    );
    result = await api.getEpisodeDetails(params.seriesId, 1);
  }

  if (result == null) {
    debugPrint('No episode details found for series ${params.seriesId}');
  } else {
    debugPrint(
      'Successfully loaded ${result.episodes.length} episodes for ${result.name}',
    );
  }

  return result;
});

final externalIdsProvider = FutureProvider.family<Map<String, dynamic>?, int>((
  ref,
  seriesId,
) async {
  final api = ApiService();
  return await api.getExternalIds(seriesId);
});