import 'package:flutter/material.dart';
import 'package:immo24calculator/welcome_page.dart';
import 'package:immo24calculator/factors_page.dart';
import 'package:immo24calculator/values_page.dart';
import 'package:immo24calculator/summary_page.dart';
import 'package:immo24calculator/payment_history_page.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/app_scaffold.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pageWidgets = [
    WelcomePage(),
    FactorsPage(),
    ValuesPage(),
    _SummaryPageWrapper(),
    _PaymentHistoryPageWrapper(),
  ];

  final List<String> _pageTitles = [
    'Willkommen',
    'Hauptfaktoren',
    'Rahmenwerte',
    'Zusammenfassung',
    'Zahlungsverlauf',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        automaticallyImplyLeading: false,
      ),
      body: _pageWidgets[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Start',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Hauptfaktoren',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Rahmenwerte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.summarize),
            label: 'Zusammenfassung',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Zahlungsverlauf',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _SummaryPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context);
    final calculationResult = mortgage.calculateMortgagePayments();
    return SummaryPage(calculationResult: calculationResult);
  }
}

class _PaymentHistoryPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context);
    final calculationResult = mortgage.calculateMortgagePayments();
    return PaymentHistoryPage(calculationResult: calculationResult);
  }
}
