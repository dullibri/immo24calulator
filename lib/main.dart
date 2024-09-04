import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/annuität.dart';
import 'package:immo_credit/calculations/house.dart';
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
      ),
      home: HomePage(),
    );
  }
}
