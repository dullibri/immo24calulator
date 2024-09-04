import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/annuität.dart';
import 'package:immo_credit/calculations/house.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HousePriceProvider(
            initialInput: HousePriceInput(
              squareMeters: 100,
              housePrice: 500000,
            ),
          ),
        ),
        ChangeNotifierProxyProvider<HousePriceProvider,
            MortgageCalculatorProvider>(
          create: (context) => MortgageCalculatorProvider(
            Provider.of<HousePriceProvider>(context, listen: false),
          ),
          update: (context, housePriceProvider, previous) =>
              previous ?? MortgageCalculatorProvider(housePriceProvider),
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
