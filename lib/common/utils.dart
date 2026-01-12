import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apikey = dotenv.env['TMDB_API_KEY'] ?? '';

const String baseUrl = 'https://api.themoviedb.org/3/';
const String imageUrl = 'https://image.tmdb.org/t/p/original';
const String imageUrl2 = 'https://image.tmdb.org/t/p/w500';