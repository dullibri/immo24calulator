import 'package:flutter/material.dart';
import 'package:immo24calculator/calculations/annuit%C3%A4t.dart';
import 'package:immo24calculator/factors_page.dart';
import 'package:immo24calculator/payment_history_page.dart';
import 'package:immo24calculator/summary_page.dart';
import 'package:immo24calculator/values_page.dart';
import 'package:immo24calculator/welcome_page.dart';
// Importieren Sie hier alle benötigten Seiten

import 'package:flutter/material.dart';
// Importieren Sie hier alle benötigten Seiten und Modelle

class NavigationPages extends StatefulWidget {
  @override
  _NavigationPagesState createState() => _NavigationPagesState();
}

class _NavigationPagesState extends State<NavigationPages> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  CalculationResult? _calculationResult;

  final List<String> _pageNames = [
    'Willkommen',
    'Rahmenwerte',
    'Hauptfaktoren',
    'Zusammenfassung',
    'Zahlungsverlauf'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: [
                WelcomePage(),
                ValuesPage(),
                FactorsPage(
                  onCalculate: (result) {
                    setState(() {
                      _calculationResult = result;
                    });
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                if (_calculationResult != null)
                  SummaryPage(calculationResult: _calculationResult!)
                else
                  Center(
                      child: Text(
                          'Bitte führen Sie zuerst eine Berechnung durch.')),
                if (_calculationResult != null)
                  PaymentHistoryPage(calculationResult: _calculationResult!)
                else
                  Center(
                      child: Text(
                          'Bitte führen Sie zuerst eine Berechnung durch.')),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPageIndex > 0)
                  ElevatedButton.icon(
                    icon: Icon(Icons.arrow_back),
                    label: Text(_pageNames[_currentPageIndex - 1]),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                else
                  SizedBox(width: 100), // Platzhalter
                if (_currentPageIndex < _pageNames.length - 1)
                  ElevatedButton.icon(
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    label: Text(_pageNames[_currentPageIndex + 1],
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (_currentPageIndex == 2 &&
                          _calculationResult == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Bitte führen Sie zuerst eine Berechnung durch.')),
                        );
                        return;
                      }
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .primaryColor, // Ändern Sie 'primary' zu 'backgroundColor'
                    ),
                  )
                else
                  SizedBox(width: 100), // Platzhalter
              ],
            ),
          ),
        ],
      ),
    );
  }
}
