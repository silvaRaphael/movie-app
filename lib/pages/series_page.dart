import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:movies/constants/api_key.dart';
import 'package:movies/pages/favorites_page.dart';
import 'package:movies/pages/movie_details.dart';
import 'package:movies/pages/search_page.dart';
import 'package:movies/utils/movie_card.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({Key? key}) : super(key: key);

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  int pageToLoad = 1;
  String categorySelected = '';
  String listType = 'tv';
  List categoriesList = [];
  List seriesList = [];
  int totalPages = 0;

  final TextEditingController _searchcontroller = TextEditingController();
  final focus = FocusNode();
  bool searchBarVisible = false;

  final ScrollController _serieCategoryController =
      ScrollController(keepScrollOffset: true);

  @override
  void initState() {
    getCategories();
    getSeries();
    super.initState();
  }

  Future getSeries() async {
    seriesList = [];

    var series = await get(Uri.parse(
        'https://api.themoviedb.org/3/discover/$listType?api_key=$apiKey&language=pt-BR&with_genres=$categorySelected&page=${pageToLoad.toString()}'));

    Map<String, dynamic> res = jsonDecode(series.body) as Map<String, dynamic>;

    setState(() {
      res['results'].forEach((element) {
        seriesList.add(element);
      });
      totalPages = res['total_pages'];
    });
  }

  Future getCategories() async {
    categoriesList = [];

    var categories = await get(Uri.parse(
        'https://api.themoviedb.org/3/genre/$listType/list?api_key=$apiKey&language=pt-BR'));

    Map<String, dynamic> res =
        jsonDecode(categories.body) as Map<String, dynamic>;

    setState(() {
      res['genres'].forEach((element) {
        categoriesList.add(element);
      });
    });
  }

  void searchMovie() {
    if (searchBarVisible) {
      if (_searchcontroller.text.trim().isNotEmpty) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SearchPage(
              query: _searchcontroller.text.trim(),
              listType: 'movie',
            ),
          ),
        );
        searchBarVisible = false;
      }
    } else {
      setState(() {
        _searchcontroller.clear();
        searchBarVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchBarVisible
            ? TextFormField(
                onFieldSubmitted: (value) {
                  searchMovie();
                },
                autofocus: true,
                controller: _searchcontroller,
                decoration: InputDecoration(
                  hintText: 'O que está procurando?',
                  hintStyle: TextStyle(
                    color: Colors.grey[700],
                  ),
                  border: InputBorder.none,
                ),
                cursorColor: Colors.grey[700],
                style: TextStyle(color: Colors.grey[700]),
              )
            : Text(
                'S É R I E S',
                style: TextStyle(
                  color: Colors.grey[900],
                ),
              ),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const FavoriteMovies()),
            );
          },
          child: const Icon(Icons.favorite_border),
        ),
        actions: [
          searchBarVisible
              ? Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: GestureDetector(
                    onTap: () {
                      _searchcontroller.clear();
                      setState(() {
                        searchBarVisible = false;
                      });
                    },
                    child: const Icon(Icons.close),
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 15),
            child: GestureDetector(
              onTap: () {
                searchMovie();
                FocusScope.of(context).requestFocus(focus);
              },
              child: const Icon(Icons.search),
            ),
          ),
        ],
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        backgroundColor: Colors.grey[100],
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // categorie list
              categoriesList.isNotEmpty
                  ? Container(
                      height: 40,
                      margin: const EdgeInsets.only(top: 20),
                      child: ListView.builder(
                        key: const PageStorageKey('SeriesCategoryKey'),
                        controller: _serieCategoryController,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: categoriesList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  categorySelected = '';
                                  pageToLoad = 1;
                                  getSeries();
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: categorySelected == ''
                                      ? Colors.grey[500]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  child: Text(
                                    'Todos',
                                    style: TextStyle(
                                      color: categorySelected == ''
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                categorySelected =
                                    categoriesList[index - 1]['id'].toString();
                                pageToLoad = 1;
                                getSeries();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: categorySelected ==
                                        categoriesList[index - 1]['id']
                                            .toString()
                                    ? Colors.grey[500]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                child: Text(
                                  categoriesList[index - 1]['name'],
                                  style: TextStyle(
                                    color: categorySelected ==
                                            categoriesList[index - 1]['id']
                                                .toString()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox(),

              // serie list
              seriesList.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // section title
                        categorySelected == ''
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Populares',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : const SizedBox(height: 30),

                        // movies grid
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1 / 1.85,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                          ),
                          shrinkWrap: true,
                          itemCount: seriesList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => MovieDetails(
                                      listType: listType,
                                      movieId:
                                          seriesList[index]['id'].toString(),
                                      title: seriesList[index]['name'],
                                      imagePath: seriesList[index]
                                          ['backdrop_path'],
                                      verticalImage: seriesList[index]
                                          ['poster_path'],
                                      voteAverage: seriesList[index]
                                              ['vote_average']
                                          .toString(),
                                      releaseDate: seriesList[index]
                                          ['first_air_date'],
                                      overview: seriesList[index]['overview'],
                                    ),
                                  ),
                                );
                              },
                              child: MovieCard(
                                title: seriesList[index]['name'],
                                imagePath: seriesList[index]['poster_path'],
                                voteAverage: seriesList[index]['vote_average']
                                    .toString(),
                              ),
                            );
                          },
                        ),

                        // change pages
                        totalPages > 1
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        color: pageToLoad - 1 > 0
                                            ? Colors.grey[200]
                                            : Colors.grey[100],
                                        child: IconButton(
                                          onPressed: () {
                                            if (pageToLoad - 1 > 0) {
                                              setState(() {
                                                pageToLoad -= 1;
                                                getSeries();
                                              });
                                            }
                                          },
                                          color: pageToLoad - 1 > 0
                                              ? Colors.black
                                              : Colors.grey[400],
                                          splashColor: pageToLoad - 1 > 0
                                              ? Colors.grey[300]
                                              : Colors.transparent,
                                          highlightColor: pageToLoad - 1 > 0
                                              ? Colors.grey[300]
                                              : Colors.transparent,
                                          icon: const Icon(
                                            Icons.chevron_left,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text('Página ${pageToLoad.toString()}'),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        color: pageToLoad + 1 <= totalPages
                                            ? Colors.grey[200]
                                            : Colors.grey[100],
                                        child: IconButton(
                                          onPressed: () {
                                            if (pageToLoad + 1 <= totalPages) {
                                              setState(() {
                                                pageToLoad += 1;
                                                getSeries();
                                              });
                                            }
                                          },
                                          color: pageToLoad + 1 <= totalPages
                                              ? Colors.black
                                              : Colors.grey[400],
                                          splashColor:
                                              pageToLoad + 1 <= totalPages
                                                  ? Colors.grey[300]
                                                  : Colors.transparent,
                                          highlightColor:
                                              pageToLoad + 1 <= totalPages
                                                  ? Colors.grey[300]
                                                  : Colors.transparent,
                                          icon: const Icon(
                                            Icons.chevron_right,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ],
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
