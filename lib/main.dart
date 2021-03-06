import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:movies/pages/home_page.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xE1111111),
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();

  await Hive.openBox('boxFavoriteMovies');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}
