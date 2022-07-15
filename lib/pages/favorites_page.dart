import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:movies/pages/movie_details.dart';
import 'package:movies/utils/movie_card.dart';

class FavoriteMovies extends StatefulWidget {
  const FavoriteMovies({Key? key}) : super(key: key);

  @override
  State<FavoriteMovies> createState() => _FavoriteMoviesState();
}

class _FavoriteMoviesState extends State<FavoriteMovies> {
  final _boxFavoriteMovies = Hive.box('boxFavoriteMovies');

  List favoriteMovies = [];

  @override
  void initState() {
    getFavorites();
    super.initState();
  }

  void getFavorites() {
    for (var element in _boxFavoriteMovies.values) {
      favoriteMovies.add(element);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'F A V O R I T O S',
          style: TextStyle(
            color: Colors.grey[900],
          ),
        ),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        backgroundColor: Colors.grey[100],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, size: 24),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1 / 1.85,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            shrinkWrap: true,
            itemCount: favoriteMovies.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MovieDetails(
                        listType: favoriteMovies[index]['listType'],
                        movieId: favoriteMovies[index]['movieId'].toString(),
                        title: favoriteMovies[index]['title'],
                        imagePath: favoriteMovies[index]['imagePath'],
                        verticalImage: favoriteMovies[index]['verticalImage'],
                        voteAverage: '${favoriteMovies[index]['voteAverage']}',
                        releaseDate: favoriteMovies[index]['releaseDate'],
                        overview: favoriteMovies[index]['overview'],
                      ),
                    ),
                  );
                },
                child: MovieCard(
                  title: favoriteMovies[index]['title'],
                  imagePath: favoriteMovies[index]['verticalImage'],
                  voteAverage: '${favoriteMovies[index]['voteAverage']}',
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
