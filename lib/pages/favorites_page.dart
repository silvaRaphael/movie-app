import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:movies/pages/movie_details.dart';
import 'package:movies/utils/movie_card.dart';
import 'package:movies/utils/shadow_button.dart';

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
                  const Text(
                    'Favoritos',
                    style: TextStyle(
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
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1.6,
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
                              movieId:
                                  favoriteMovies[index]['movieId'].toString(),
                              title: favoriteMovies[index]['title'],
                              imagePath: favoriteMovies[index]['imagePath'],
                              verticalImage: favoriteMovies[index]
                                  ['verticalImage'],
                              voteAverage:
                                  '${favoriteMovies[index]['voteAverage']}',
                              releaseDate: favoriteMovies[index]['releaseDate'],
                              overview: favoriteMovies[index]['overview'],
                            ),
                          ),
                        ).then((value) {
                          if (value == false) {
                            setState(() {
                              _boxFavoriteMovies
                                  .delete(favoriteMovies[index]['movieId']);
                              favoriteMovies.removeAt(index);
                            });
                          }
                        });
                      },
                      child: MovieCard(
                        title: favoriteMovies[index]['title'],
                        imagePath: favoriteMovies[index]['verticalImage'],
                        voteAverage: '${favoriteMovies[index]['voteAverage']}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
