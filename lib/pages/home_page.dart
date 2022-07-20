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
        height: 50,
        child: BottomNavigationBar(
          backgroundColor: const Color(0xAB111111),
          currentIndex: tabIndex,
          onTap: (int index) {
            setState(() {
              tabIndex = index;
            });
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          selectedFontSize: 14,
          items: const [
            BottomNavigationBarItem(
              icon: SizedBox.shrink(),
              label: 'Filmes',
            ),
            BottomNavigationBarItem(
              icon: SizedBox.shrink(),
              label: 'Séries',
            ),
          ],
        ),
      ),
    );
  }
}
