import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/screens/series_detailscreen.dart';
import 'package:netflix/services/api_service.dart';

class SeriesCard extends StatefulWidget {
  final dynamic series;

  const SeriesCard({super.key, required this.series});

  @override
  State<SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final posterPath = widget.series.posterPath;

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _isLoading ? null : () => _handleSeriesTap(context),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (posterPath == null || posterPath.isEmpty)
                    ? _buildErrorCard()
                    : _buildImage(posterPath),
              ),
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String posterPath) {
    if (kIsWeb) {
      return Image.network(
        "$imageUrl$posterPath",
        width: 120,
        height: 180,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 120,
            height: 180,
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorCard(),
        cacheWidth: 240,
        cacheHeight: 360,
      );
    }

    return CachedNetworkImage(
      imageUrl: "$imageUrl$posterPath",
      width: 120,
      height: 180,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 120,
        height: 180,
        color: Colors.grey[900],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => _buildErrorCard(),
      fadeInDuration: const Duration(milliseconds: 200),
      memCacheWidth: 240,
      memCacheHeight: 360,
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.tv,
        color: Colors.white54,
        size: 40,
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
}
