import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'factors_page.dart';
import 'values_page.dart';
import 'summary_page.dart';
import 'annual_values_page.dart';
import 'monthly_values_page.dart'; // Neuer Import
import 'calculations/annuität.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hypothekenrechner'),
      ),
      drawer: Drawer(
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
              title: Text('Hauptfaktoren'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FactorsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Rahmenwerte'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ValuesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.summarize),
              title: Text('Zusammenfassung'),
              onTap: () {
                final mortgageProvider =
                    Provider.of<MortgageCalculatorProvider>(context,
                        listen: false);
                final calculationResult =
                    mortgageProvider.calculateMortgagePayments();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SummaryPage(calculationResult: calculationResult)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Jährliche Werte'),
              onTap: () {
                final mortgageProvider =
                    Provider.of<MortgageCalculatorProvider>(context,
                        listen: false);
                final calculationResult =
                    mortgageProvider.calculateMortgagePayments();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AnnualValuesPage(
                          calculationResult: calculationResult)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_view_month),
              title: Text('Monatliche Werte'),
              onTap: () {
                final mortgageProvider =
                    Provider.of<MortgageCalculatorProvider>(context,
                        listen: false);
                final calculationResult =
                    mortgageProvider.calculateMortgagePayments();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MonthlyValuesPage(
                          calculationResult: calculationResult)),
                );
              },
            ),
          ],
        ),
      ),
      body: FactorsPage(), // Startseite
    );
  }
}
