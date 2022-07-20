// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:movies/constants/api_key.dart';
import 'package:movies/pages/movie_details.dart';
import 'package:movies/utils/movie_card.dart';
import 'package:movies/utils/shadow_button.dart';

class CategoryMovies extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  String listType;
  CategoryMovies({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.listType,
  }) : super(key: key);

  @override
  State<CategoryMovies> createState() => _CategoryMoviesState();
}

class _CategoryMoviesState extends State<CategoryMovies> {
  int pageToLoad = 1;
  List categoriesList = [];
  List moviesList = [];
  int totalPages = 0;

  Future getMovies() async {
    moviesList = [];

    var movies = await get(Uri.parse(
        'https://api.themoviedb.org/3/discover/${widget.listType}?api_key=$apiKey&language=pt-BR&with_genres=${widget.categoryId}&page=${pageToLoad.toString()}'));

    Map<String, dynamic> res = jsonDecode(movies.body) as Map<String, dynamic>;

    setState(() {
      res['results'].forEach((element) {
        moviesList.add(element);
      });
      totalPages = res['total_pages'];
    });
  }

  @override
  void initState() {
    getMovies();
    super.initState();
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
            expandedHeight: 90,
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
                    icon: Icons.arrow_back,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    widget.categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 50),
                ],
              ),
            ),
          ),

          // movie content
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: 1,
              (context, categoryIndex) {
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1 / 1.55,
                        crossAxisSpacing: 10,
                      ),
                      shrinkWrap: true,
                      itemCount: moviesList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => MovieDetails(
                                  listType: widget.listType,
                                  movieId: moviesList[index]['id'].toString(),
                                  title: widget.listType == 'movie'
                                      ? moviesList[index]['title']
                                      : moviesList[index]['name'],
                                  imagePath: moviesList[index]['backdrop_path'],
                                  verticalImage: moviesList[index]
                                      ['poster_path'],
                                  voteAverage:
                                      '${moviesList[index]['vote_average']}',
                                  releaseDate: widget.listType == 'movie'
                                      ? moviesList[index]['release_date']
                                      : moviesList[index]['first_air_date'],
                                  overview: moviesList[index]['overview'],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: MovieCard(
                              title: widget.listType == 'movie'
                                  ? moviesList[index]['title']
                                  : moviesList[index]['name'],
                              imagePath: moviesList[index]['poster_path'],
                              voteAverage:
                                  moviesList[index]['vote_average'].toString(),
                            ),
                          ),
                        );
                      },
                    ),

                    // controls
                    moviesList.isNotEmpty && totalPages > 1
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                pageToLoad - 1 > 0
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                          color: Colors.grey[900],
                                          child: IconButton(
                                            onPressed: () {
                                              if (pageToLoad - 1 > 0) {
                                                setState(() {
                                                  pageToLoad -= 1;
                                                  getMovies();
                                                });
                                              }
                                            },
                                            color: Colors.white,
                                            splashColor: Colors.black,
                                            highlightColor: Colors.black,
                                            icon: const Icon(
                                              Icons.chevron_left,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(width: 50),
                                Text('Página ${pageToLoad.toString()}'),
                                pageToLoad + 1 <= totalPages
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                          color: Colors.grey[900],
                                          child: IconButton(
                                            onPressed: () {
                                              if (pageToLoad + 1 <=
                                                  totalPages) {
                                                setState(() {
                                                  pageToLoad += 1;
                                                  getMovies();
                                                });
                                              }
                                            },
                                            color: Colors.white,
                                            splashColor: Colors.black,
                                            highlightColor: Colors.black,
                                            icon: const Icon(
                                              Icons.chevron_right,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(width: 50),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
