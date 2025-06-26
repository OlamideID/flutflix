
// // movie_card.dart - Fixed for web
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:netflix/common/utils.dart';
// import 'package:netflix/screens/movie_details.dart';

// class MovieCard extends StatelessWidget {
//   final dynamic movie;

//   const MovieCard({super.key, required this.movie});

//   @override
//   Widget build(BuildContext context) {
//     // Check if posterPath exists
//     final posterPath = movie.posterPath;
//     if (posterPath == null || posterPath.isEmpty) {
//       return _buildErrorCard();
//     }

//     return RepaintBoundary(
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(10),
//           onTap: () => _navigateToDetails(context),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: _buildImage(posterPath),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImage(String posterPath) {
//     if (kIsWeb) {
//       return Image.network(
//         "$imageUrl$posterPath",
//         width: 120,
//         height: 180,
//         fit: BoxFit.cover,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Container(
//             width: 120,
//             height: 180,
//             color: Colors.grey[900],
//             child: const Center(
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) => _buildErrorCard(),
//         // Add these for better web performance
//         cacheWidth: 240, // 2x for retina displays
//         cacheHeight: 360,
//       );
//     }

//     return CachedNetworkImage(
//       imageUrl: "$imageUrl$posterPath",
//       width: 120,
//       height: 180,
//       fit: BoxFit.cover,
//       placeholder: (context, url) => Container(
//         width: 120,
//         height: 180,
//         color: Colors.grey[900],
//         child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
//       ),
//       errorWidget: (context, url, error) => _buildErrorCard(),
//       fadeInDuration: const Duration(milliseconds: 200),
//       memCacheWidth: 240,
//       memCacheHeight: 360,
//     );
//   }

//   Widget _buildErrorCard() {
//     return Container(
//       width: 120,
//       height: 180,
//       decoration: BoxDecoration(
//         color: Colors.grey[800],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: const Icon(
//         Icons.movie,
//         color: Colors.white54,
//         size: 40,
//       ),
//     );
//   }

//   void _navigateToDetails(BuildContext context) {
//     if (movie.id == null) return;
    
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MovieDetailsScreen(movieId: movie.id),
//       ),
//     );
//   }
// }