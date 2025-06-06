import 'package:flutter/material.dart';
import 'package:netflix/components/movie_list.dart';
import 'package:netflix/components/series_section.dart';
import 'package:netflix/screens/home.dart';

class MovieSection extends StatelessWidget {
  final Future future;
  final String sectionTitle;
  final bool isReverse;

  const MovieSection({
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
            child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                print("ConnectionState: ${snapshot.connectionState}");
                print("Has data: ${snapshot.hasData}");
                print("Has error: ${snapshot.hasError}");
                print("Data: ${snapshot.data}");

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } else if (snapshot.hasError) {
                  print("Error: ${snapshot.error}");
                  return ErrorDisplay(error: snapshot.error.toString());
                } else if (snapshot.hasData && snapshot.data != null) {
                  final movies = snapshot.data?.results ?? [];
                  print("Movies count: ${movies.length}");

                  if (movies.isEmpty) {
                    return const Center(
                      child: Text(
                        "No movies found",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return MovieList(movies: movies, isReverse: isReverse);
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
