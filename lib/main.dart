import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/annuit%C3%A4t.dart';
import 'package:immo_credit/calculations/house.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MortgageCalculatorProvider()),
        ChangeNotifierProvider(
          create: (_) => HousePriceProvider(
            initialInput: HousePriceInput(
              squareMeters: 100,
              housePrice: 500000,
            ),
          ),
        ),
      ],
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
