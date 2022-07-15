// ignore_for_file: sized_box_for_whitespace, must_be_immutable, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:movies/pages/movies_page.dart';
import 'package:movies/pages/series_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tabIndex = 0;

  List<Widget> pages = [
    const MoviesPage(),
    const SeriesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[tabIndex],
      bottomNavigationBar: SizedBox(
        height: 48,
        child: BottomNavigationBar(
          currentIndex: tabIndex,
          onTap: (int index) {
            setState(() {
              tabIndex = index;
            });
          },
          elevation: 2,
          selectedItemColor: Colors.black,
          selectedIconTheme: const IconThemeData(
            color: Colors.black,
          ),
          unselectedIconTheme: IconThemeData(
            color: Colors.grey[400],
          ),
          iconSize: 18,
          selectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.tv,
              ),
              label: 'Filmes',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.computer,
              ),
              label: 'Séries',
            ),
          ],
        ),
      ),
    );
  }
}
