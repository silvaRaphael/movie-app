// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart';
import 'package:movies/constants/api_key.dart';
import 'package:movies/utils/movie_card.dart';

class MovieDetails extends StatefulWidget {
  String listType;
  String movieId;
  String title;
  var imagePath;
  var verticalImage;
  String voteAverage;
  var releaseDate;
  String overview;
  MovieDetails({
    Key? key,
    required this.listType,
    required this.movieId,
    required this.title,
    required this.imagePath,
    required this.verticalImage,
    required this.voteAverage,
    required this.releaseDate,
    required this.overview,
  }) : super(key: key);

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  final _boxFavoriteMovies = Hive.box('boxFavoriteMovies');

  List similarMovies = [];
  List moviePosters = [];
  List streamMovieProviders = [];
  List buyMovieProviders = [];
  List rentMovieProviders = [];
  String releaseDateFormated = '';
  bool movieIsFavorite = false;

  @override
  void initState() {
    super.initState();
    formatDate();
    getMoviePosters();
    getMovieProviders();
    getSimilarMovies();
    setState(() {
      movieIsFavorite = checkIfMovieIsFavorite();
      if (widget.imagePath.runtimeType != Null) {
        moviePosters.add(widget.imagePath);
      }
    });
  }

  void formatDate() {
    if (widget.releaseDate.isNotEmpty) {
      String day = DateTime.parse(widget.releaseDate).day.toString();
      if (day.length == 1) day = '0$day';

      String month = DateTime.parse(widget.releaseDate).month.toString();
      if (month.length == 1) month = '0$month';

      releaseDateFormated =
          '$day/$month/${DateTime.parse(widget.releaseDate).year}';
    }
  }

  Future getSimilarMovies() async {
    var movies = await get(Uri.parse(
        'https://api.themoviedb.org/3/${widget.listType}/${widget.movieId}/similar?api_key=$apiKey&language=pt-BR'));

    Map<String, dynamic> res = jsonDecode(movies.body) as Map<String, dynamic>;

    Map<String, dynamic> res2 = res;

    setState(() {
      res2['results'].forEach((element) {
        similarMovies.add(element);
      });
    });
  }

  Future getMoviePosters() async {
    var posters = await get(Uri.parse(
        'https://api.themoviedb.org/3/${widget.listType}/${widget.movieId}/images?api_key=$apiKey&include_image_language=en'));

    Map<String, dynamic> res = jsonDecode(posters.body) as Map<String, dynamic>;

    Map<String, dynamic> res2 = res;

    setState(() {
      res2['backdrops'].forEach((element) {
        moviePosters.add(element['file_path']);
      });
    });
  }

  Future getMovieProviders() async {
    var providers = await get(Uri.parse(
        'https://api.themoviedb.org/3/${widget.listType}/${widget.movieId}/watch/providers?api_key=$apiKey&language=pt-BR&watch_region=BR'));

    Map<String, dynamic> res =
        jsonDecode(providers.body) as Map<String, dynamic>;

    Map<String, dynamic> res2 = res;

    setState(() {
      res2['results']['BR']['flatrate'].forEach((element) {
        streamMovieProviders.add(element);
      });
      res2['results']['BR']['buy'].forEach((element) {
        buyMovieProviders.add(element);
      });
      res2['results']['BR']['rent'].forEach((element) {
        rentMovieProviders.add(element);
      });
    });
  }

  bool checkIfMovieIsFavorite() {
    if (_boxFavoriteMovies.get(widget.movieId) == null) {
      return false;
    } else {
      return true;
    }
  }

  void setFavorite() {
    setState(() {
      if (!checkIfMovieIsFavorite()) {
        _boxFavoriteMovies.put(widget.movieId, {
          'listType': widget.listType,
          'movieId': widget.movieId,
          'title': widget.title,
          'imagePath': widget.imagePath,
          'verticalImage': widget.verticalImage,
          'voteAverage': widget.voteAverage,
          'releaseDate': widget.releaseDate,
          'overview': widget.overview,
        });
      } else {
        _boxFavoriteMovies.delete(widget.movieId);
      }
      movieIsFavorite = checkIfMovieIsFavorite();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[900],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 15),
            // ignore: prefer_const_constructors
            child: GestureDetector(
              onTap: () {
                setFavorite();
              },
              child: Icon(
                movieIsFavorite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
          ),
        ],
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.grey[700],
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              moviePosters.isNotEmpty
                  ? AspectRatio(
                      aspectRatio: 2 / 1.1,
                      child: NotificationListener(
                        onNotification:
                            (OverscrollIndicatorNotification notification) {
                          notification.disallowIndicator();
                          return false;
                        },
                        child: PageView(
                          children: [
                            ...moviePosters
                                .map(
                                  (item) => Image.network(
                                    'https://image.tmdb.org/t/p/w500$item',
                                    fit: BoxFit.cover,
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                double.parse(widget.voteAverage)
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(releaseDateFormated),
                    const SizedBox(height: 20),
                    Text(
                      widget.overview,
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              // stream movie providers
              Container(
                child: streamMovieProviders.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              'Stream',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, left: 10, right: 10),
                            height: (streamMovieProviders.length +
                                    streamMovieProviders.length % 2) /
                                2 *
                                70,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                mainAxisExtent: 50,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: streamMovieProviders.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${streamMovieProviders[index]['logo_path']}',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            streamMovieProviders[index]
                                                ['provider_name'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : null,
              ),

              // buy movie providers
              Container(
                child: buyMovieProviders.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              'Comprar',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, left: 10, right: 10),
                            height: (buyMovieProviders.length +
                                    buyMovieProviders.length % 2) /
                                2 *
                                70,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                mainAxisExtent: 50,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: buyMovieProviders.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${buyMovieProviders[index]['logo_path']}',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            buyMovieProviders[index]
                                                ['provider_name'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : null,
              ),

              // rent movie providers
              Container(
                child: rentMovieProviders.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              'Alugar',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, left: 10, right: 10),
                            height: (rentMovieProviders.length +
                                    rentMovieProviders.length % 2) /
                                2 *
                                70,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                mainAxisExtent: 50,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: rentMovieProviders.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${rentMovieProviders[index]['logo_path']}',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            rentMovieProviders[index]
                                                ['provider_name'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : null,
              ),

              // similar movies
              Container(
                child: similarMovies.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              widget.listType == 'movie'
                                  ? 'Filmes Similares'
                                  : 'Séries Similares',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            height: 300,
                            margin: const EdgeInsets.only(top: 20),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: similarMovies.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => MovieDetails(
                                          listType: widget.listType,
                                          movieId: similarMovies[index]['id']
                                              .toString(),
                                          title: widget.listType == 'movie'
                                              ? similarMovies[index]['title']
                                              : similarMovies[index]['name'],
                                          imagePath: similarMovies[index]
                                              ['backdrop_path'],
                                          verticalImage: similarMovies[index]
                                              ['poster_path'],
                                          voteAverage:
                                              '${similarMovies[index]['vote_average']}',
                                          releaseDate: similarMovies[index]
                                              ['release_date'],
                                          overview: similarMovies[index]
                                              ['overview'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: MovieCard(
                                      title: widget.listType == 'movie'
                                          ? similarMovies[index]['title']
                                          : similarMovies[index]['name'],
                                      imagePath: similarMovies[index]
                                          ['poster_path'],
                                      voteAverage: similarMovies[index]
                                              ['vote_average']
                                          .toString(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
