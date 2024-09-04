import 'package:flutter/material.dart';
import 'package:immo_credit/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:immo_credit/calculations/annuität.dart';
import 'factors_page.dart';
import 'values_page.dart';
import 'summary_page.dart';
import 'payment_history_page.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  AppScaffold({required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: AppDrawer(),
      body: body,
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Navigation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Startseite'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Hauptfaktoren'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FactorsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Rahmenwerte'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ValuesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.summarize),
            title: Text('Zusammenfassung'),
            onTap: () {
              final mortgage = Provider.of<Mortgage>(context, listen: false);
              final calculationResult = mortgage.calculateMortgagePayments();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SummaryPage(calculationResult: calculationResult)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Zahlungsverlauf'),
            onTap: () {
              final mortgage = Provider.of<Mortgage>(context, listen: false);
              final calculationResult = mortgage.calculateMortgagePayments();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentHistoryPage(
                        calculationResult: calculationResult),
                  ));
            },
          ),
        ],
      ),
    );
  }
}
