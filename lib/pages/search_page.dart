// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:movies/constants/api_key.dart';
import 'package:movies/pages/category_movies.dart';
import 'package:movies/pages/movie_details.dart';
import 'package:movies/utils/movie_card.dart';
import 'package:movies/utils/shadow_button.dart';

class SearchPage extends StatefulWidget {
  List defaultList;
  List categoriesList;
  String listType;
  SearchPage({
    Key? key,
    required this.defaultList,
    required this.listType,
    required this.categoriesList,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool defaultContent = true;
  List searchResults = [];
  int pageToLoad = 1;
  int totalPages = 0;
  final TextEditingController _searchcontroller = TextEditingController();

  Future getSearch(String query) async {
    searchResults = [];

    var search = await get(Uri.parse(
        'https://api.themoviedb.org/3/search/${widget.listType}?api_key=$apiKey&language=pt-BR&page=${pageToLoad.toString()}&query=${Uri.encodeFull(query)}'));

    Map<String, dynamic> res = jsonDecode(search.body) as Map<String, dynamic>;

    setState(() {
      res['results'].forEach((element) {
        searchResults.add(element);
      });
      totalPages = res['total_pages'];
      defaultContent = false;
    });

    // ignore: use_build_context_synchronously
    FocusScope.of(context).unfocus();
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
            expandedHeight: 100,
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
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xff111111),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 20,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width - 60 - 100 - 30,
                          child: TextFormField(
                            onFieldSubmitted: (String value) {
                              if (value.trim().isNotEmpty) {
                                getSearch(value.trim());
                              }
                            },
                            autofocus: true,
                            controller: _searchcontroller,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'O que você procura?',
                              hintStyle: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (_searchcontroller.text.trim().isNotEmpty) {
                              getSearch(_searchcontroller.text.trim());
                            }
                          },
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // movies
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: 1,
              (context, index) {
                if (defaultContent) {
                  return Column(
                    children: [
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
                                      listType: widget.listType,
                                      movieId: widget.defaultList[index]['id']
                                          .toString(),
                                      title: widget.listType == 'movie'
                                          ? widget.defaultList[index]['title']
                                          : widget.defaultList[index]['name'],
                                      imagePath: widget.defaultList[index]
                                          ['backdrop_path'],
                                      verticalImage: widget.defaultList[index]
                                          ['poster_path'],
                                      voteAverage:
                                          '${widget.defaultList[index]['vote_average']}',
                                      releaseDate: widget.listType == 'movie'
                                          ? widget.defaultList[index]
                                              ['release_date']
                                          : widget.defaultList[index]
                                              ['first_air_date'],
                                      overview: widget.defaultList[index]
                                          ['overview'],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: MovieCard(
                                  title: widget.listType == 'movie'
                                      ? widget.defaultList[index]['title']
                                      : widget.defaultList[index]['name'],
                                  imagePath: widget.defaultList[index]
                                      ['poster_path'],
                                  voteAverage:
                                      '${widget.defaultList[index]['vote_average']}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          mainAxisSpacing: 20,
                        ),
                        shrinkWrap: true,
                        itemCount: widget.categoriesList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => CategoryMovies(
                                    categoryId: widget.categoriesList[index]
                                            ['id']
                                        .toString(),
                                    categoryName: widget.categoriesList[index]
                                        ['name'],
                                    listType: widget.listType,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xff444444),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.categoriesList[index]['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                } else {
                  if (searchResults.isEmpty) {
                    return const Center(
                      child: Text(
                        'Ops... Nada foi encontrado!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: [
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
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => MovieDetails(
                                      listType: widget.listType,
                                      movieId:
                                          searchResults[index]['id'].toString(),
                                      title: widget.listType == 'movie'
                                          ? searchResults[index]['title']
                                          : searchResults[index]['name'],
                                      imagePath: searchResults[index]
                                          ['backdrop_path'],
                                      verticalImage: searchResults[index]
                                          ['poster_path'],
                                      voteAverage:
                                          '${searchResults[index]['vote_average']}',
                                      releaseDate: widget.listType == 'movie'
                                          ? searchResults[index]['release_date']
                                          : searchResults[index]
                                              ['first_air_date'],
                                      overview: searchResults[index]
                                          ['overview'],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: MovieCard(
                                  title: widget.listType == 'movie'
                                      ? searchResults[index]['title']
                                      : searchResults[index]['name'],
                                  imagePath: searchResults[index]
                                      ['poster_path'],
                                  voteAverage:
                                      '${searchResults[index]['vote_average']}',
                                ),
                              ),
                            );
                          },
                        ),

                        // controls
                        searchResults.isNotEmpty && totalPages > 1
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    pageToLoad - 1 > 0
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Container(
                                              color: Colors.grey[900],
                                              child: IconButton(
                                                onPressed: () {
                                                  if (pageToLoad - 1 > 0) {
                                                    setState(() {
                                                      pageToLoad -= 1;
                                                      getSearch(
                                                          _searchcontroller.text
                                                              .trim());
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
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Container(
                                              color: Colors.grey[900],
                                              child: IconButton(
                                                onPressed: () {
                                                  if (pageToLoad + 1 <=
                                                      totalPages) {
                                                    setState(() {
                                                      pageToLoad += 1;
                                                      getSearch(
                                                          _searchcontroller.text
                                                              .trim());
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
                            : const SizedBox()
                      ],
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
