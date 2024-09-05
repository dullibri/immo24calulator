import 'package:flutter/material.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/calculations/house.dart';
import 'package:immo24calculator/welcome_page.dart';
import 'package:immo24calculator/widgets/navigations_pages.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Mortgage(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hypothekenrechner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NavigationPages(),
    );
  }
}
