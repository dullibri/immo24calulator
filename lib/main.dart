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
          create: (_) => HousePriceProvider(),
        ),
        ChangeNotifierProxyProvider<HousePriceProvider,
            MortgageCalculatorProvider>(
          create: (context) {
            final housePriceProvider =
                Provider.of<HousePriceProvider>(context, listen: false);
            return MortgageCalculatorProvider(housePriceProvider)
              ..initializeValues();
          },
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
