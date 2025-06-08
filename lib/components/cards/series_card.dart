import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/helpers/helpers.dart';
import 'package:netflix/screens/series_detailscreen.dart';
import 'package:netflix/services/api_service.dart';

class SeriesCard extends StatelessWidget {
  final dynamic series;

  const SeriesCard({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _handleSeriesTap(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child:
            kIsWeb
                ? Image.network(
                  "$imageUrl${series.posterPath}",
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const ImageErrorWidget(),
                )
                : CachedNetworkImage(
                  imageUrl: "$imageUrl${series.posterPath}",
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ImagePlaceholder(),
                  errorWidget:
                      (context, url, error) => const ImageErrorWidget(),
                ),
      ),
    );
  }

  Future<void> _handleSeriesTap(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ApiService();
      final seriesDetails = await apiService.seriesDetail(series.id);

      Navigator.of(context).pop();

      if (seriesDetails == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Series details not available')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeriesDetailsScreen(id: series.id),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
