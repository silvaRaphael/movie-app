import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:movies/constants/api_key.dart';
import 'package:movies/pages/category_movies.dart';
import 'package:movies/pages/favorites_page.dart';
import 'package:movies/pages/movie_details.dart';
import 'package:movies/pages/search_page.dart';
import 'package:movies/utils/movie_card.dart';
import 'package:movies/utils/shadow_button.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({Key? key}) : super(key: key);

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  String categorySelected = '';
  String listType = 'tv';
  List categoriesList = [];
  List moviesList = [];
  List popularMovie = [];

  @override
  void initState() {
    getPopularMovie();
    getCategories();
    super.initState();
  }

  Future getPopularMovie() async {
    var movies = await get(Uri.parse(
        'https://api.themoviedb.org/3/$listType/popular?api_key=$apiKey&language=pt-BR&page=1&region=BR'));

    Map<String, dynamic> res = jsonDecode(movies.body) as Map<String, dynamic>;

    setState(() {
      popularMovie.add(res['results'][0]);
    });
  }

  Future getCategories() async {
    categoriesList = [];

    var categories = await get(Uri.parse(
        'https://api.themoviedb.org/3/genre/$listType/list?api_key=$apiKey&language=pt-BR'));

    Map<String, dynamic> res =
        jsonDecode(categories.body) as Map<String, dynamic>;

    res['genres'].forEach((element) {
      setState(() {
        categoriesList.add(element);
      });
    });
    getMoviesByCategory();
  }

  Future getMoviesByCategory() async {
    moviesList = [];
    List moviesByCategory = [];

    for (var element in categoriesList) {
      var movies = await get(Uri.parse(
          'https://api.themoviedb.org/3/discover/$listType?api_key=$apiKey&language=pt-BR&with_genres=${element['id']}'));

      Map<String, dynamic> res =
          jsonDecode(movies.body) as Map<String, dynamic>;

      setState(() {
        moviesByCategory = [];
        for (var element in res['results']) {
          moviesByCategory.add(element);
          if (moviesByCategory.length == categoriesList.length) {
            moviesList.add(moviesByCategory);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff111111),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xA9111111),
            expandedHeight: MediaQuery.of(context).size.width * 1.45,
            collapsedHeight: 90,
            toolbarHeight: 90,
            leadingWidth: 0,
            leading: const SizedBox.shrink(),
            title: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShadowButton(
                    color: const Color(0xff111111),
                    icon: Icons.favorite_border,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const FavoriteMovies(),
                        ),
                      );
                    },
                  ),
                  ShadowButton(
                    color: const Color(0xff111111),
                    icon: Icons.search,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => SearchPage(
                            listType: listType,
                            categoriesList: categoriesList,
                            defaultList: moviesList[0],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: popularMovie.isNotEmpty
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500${popularMovie[0]['poster_path']}',
                      fit: BoxFit.cover,
                    )
                  : const SizedBox(),
              title: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MovieDetails(
                        listType: listType,
                        movieId: popularMovie[0]['id'].toString(),
                        title: popularMovie[0]['name'],
                        imagePath: popularMovie[0]['backdrop_path'],
                        verticalImage: popularMovie[0]['poster_path'],
                        voteAverage: '${popularMovie[0]['vote_average']}',
                        releaseDate: popularMovie[0]['first_air_date'],
                        overview: popularMovie[0]['overview'],
                      ),
                    ),
                  );
                },
              ),
              centerTitle: true,
            ),
          ),

          // home content
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: categoriesList.length,
              (context, categoryIndex) {
                if (moviesList.isEmpty || moviesList.runtimeType == Null) {
                  return const SizedBox();
                }
                if (moviesList.length > categoryIndex) {
                  return Padding(
                    padding: categoryIndex == 0
                        ? const EdgeInsets.only(top: 50)
                        : const EdgeInsets.only(top: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categoriesList[categoryIndex]['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => CategoryMovies(
                                        categoryId:
                                            categoriesList[categoryIndex]['id']
                                                .toString(),
                                        categoryName:
                                            categoriesList[categoryIndex]
                                                ['name'],
                                        listType: listType,
                                      ),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => MovieDetails(
                                        listType: listType,
                                        movieId: moviesList[categoryIndex]
                                                [index]['id']
                                            .toString(),
                                        title: moviesList[categoryIndex][index]
                                            ['name'],
                                        imagePath: moviesList[categoryIndex]
                                            [index]['backdrop_path'],
                                        verticalImage: moviesList[categoryIndex]
                                            [index]['poster_path'],
                                        voteAverage:
                                            '${moviesList[categoryIndex][index]['vote_average']}',
                                        releaseDate: moviesList[categoryIndex]
                                            [index]['first_air_date'],
                                        overview: moviesList[categoryIndex]
                                            [index]['overview'],
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: MovieCard(
                                    title: moviesList[categoryIndex][index]
                                        ['name'],
                                    imagePath: moviesList[categoryIndex][index]
                                        ['poster_path'],
                                    voteAverage:
                                        '${moviesList[categoryIndex][index]['vote_average']}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (moviesList.length == categoryIndex) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
