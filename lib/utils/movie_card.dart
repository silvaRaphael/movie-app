// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  String title;
  // ignore: prefer_typing_uninitialized_variables
  var imagePath;
  String voteAverage;

  MovieCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.voteAverage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1.77,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: imagePath.runtimeType == Null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                imagePath.runtimeType != Null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500$imagePath',
                          fit: BoxFit.contain,
                        ),
                      )
                    : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0x68111111),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(6),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              double.parse(voteAverage).toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 15),
            //   child: Text(
            //     title,
            //     style: const TextStyle(
            //       fontSize: 12,
            //     ),
            //     overflow: TextOverflow.ellipsis,
            //     maxLines: 2,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
