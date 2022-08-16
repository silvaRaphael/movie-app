// ignore_for_file: sized_box_for_whitespace, must_be_immutable, avoid_unnecessary_containers

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:movies/pages/movies_page.dart';
import 'package:movies/pages/series_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasConnection = false;

  int tabIndex = 0;

  List<Widget> pages = [
    const MoviesPage(),
    const SeriesPage(),
  ];

  Future<void> checkConnectivity() async {
    var connection = await Connectivity().checkConnectivity();

    _updateConnectionStatus(connection);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    });
  }

  @override
  void initState() {
    checkConnectivity();
    // StreamSubscription<ConnectivityResult> stream =
    Connectivity().onConnectivityChanged.listen((connection) {
      _updateConnectionStatus(connection);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // no connection screen
    if (!hasConnection) {
      return Scaffold(
        backgroundColor: const Color(0xff111111),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  'Não conectado à internet!',
                  style: TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Tente se conectar e tente novamente.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

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
