// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:movies/constants/api_key.dart';
import 'package:movies/pages/movie_details.dart';
import 'package:movies/utils/movie_card.dart';

class SearchPage extends StatefulWidget {
  String query;
  String listType;
  SearchPage({
    Key? key,
    required this.query,
    required this.listType,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int pageToLoad = 1;
  String categorySelected = '';
  String listType = 'movie';
  final TextEditingController _searchcontroller = TextEditingController();
  final focus = FocusNode();
  bool searchBarVisible = false;

  Future getSearch() async {
    var search = await get(Uri.parse(
        'https://api.themoviedb.org/3/search/$listType?api_key=$apiKey&language=pt-BR&page=${pageToLoad.toString()}&query=${Uri.encodeFull(widget.query)}'));
    return jsonDecode(search.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchBarVisible
            ? TextField(
                focusNode: focus,
                controller: _searchcontroller,
                decoration: const InputDecoration(
                  hintText: 'O que está procurando?',
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                ),
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
              )
            : Text(
                widget.query.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
        titleSpacing: 0,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                FutureBuilder(
                  future: getSearch(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (snapshot.hasError) {
                        setState(() {});
                        return const Center(child: Text('Erro'));
                      } else if (snapshot.hasData) {
                        Map<String, dynamic> data =
                            snapshot.data as Map<String, dynamic>;

                        return Column(
                          children: [
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 30,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1 / 1.85,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                              ),
                              shrinkWrap: true,
                              itemCount: data['results'].length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => MovieDetails(
                                          listType: listType,
                                          movieId: data['results'][index]['id']
                                              .toString(),
                                          title: data['results'][index]
                                              ['title'],
                                          imagePath: data['results'][index]
                                              ['backdrop_path'],
                                          verticalImage: data['results'][index]
                                              ['poster_path'],
                                          voteAverage:
                                              '${data['results'][index]['vote_average']}',
                                          releaseDate: data['results'][index]
                                              ['release_date'],
                                          overview: data['results'][index]
                                              ['overview'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: MovieCard(
                                    title: data['results'][index]['title'],
                                    imagePath: data['results'][index]
                                        ['poster_path'],
                                    voteAverage:
                                        '${data['results'][index]['vote_average']}',
                                  ),
                                );
                              },
                            ),

                            // change pages
                            Padding(
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
                                      color:
                                          pageToLoad + 1 < data['total_pages']
                                              ? Colors.grey[200]
                                              : Colors.grey[100],
                                      child: IconButton(
                                        onPressed: () {
                                          if (pageToLoad + 1 <
                                              data['total_pages']) {
                                            setState(() {
                                              pageToLoad += 1;
                                            });
                                          }
                                        },
                                        color:
                                            pageToLoad + 1 < data['total_pages']
                                                ? Colors.black
                                                : Colors.grey[400],
                                        splashColor:
                                            pageToLoad + 1 < data['total_pages']
                                                ? Colors.grey[300]
                                                : Colors.transparent,
                                        highlightColor:
                                            pageToLoad + 1 < data['total_pages']
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
                            ),
                          ],
                        );
                      } else {
                        setState(() {});
                        return const Text('');
                      }
                    } else {
                      setState(() {});
                      return const Text('');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
