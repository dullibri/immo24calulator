import 'package:flutter/material.dart';
import 'annuität.dart'; // Importieren Sie die Datei, in der sich Ihre Logik befindet

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hypothekenrechner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MortgageCalculatorPage(),
    );
  }
}

class MortgageCalculatorPage extends StatefulWidget {
  @override
  _MortgageCalculatorPageState createState() => _MortgageCalculatorPageState();
}

class _MortgageCalculatorPageState extends State<MortgageCalculatorPage> {
  double principal = 544000;
  double annualInterestRate = 3.61;
  double initialPayment = 2617.67;
  double monthlySpecialPayment = 1185; // Zusätzliche monatliche Sonderzahlungen
  double maxSpecialPaymentPercent =
      5; // Maximal 5% der ursprünglichen Kreditsumme als zusätzliche Sonderzahlungen
  double rentalShare = 530063 /
      544000; // Verhältnis von vermietetem/gewerblichem Anteil zu Gesamtkredit
  double topTaxRate = 0.42; // 42% Spitzensteuersatz
  double purchasePrice = 700000;
  double annualDepreciationRate = 0.03;

  List<MortgagePayment>? payments;

  void calculatePayments() {
    setState(() {
      payments = calculateMortgagePayments(
        principal: principal,
        annualInterestRate: annualInterestRate,
        initialPayment: initialPayment,
        monthlySpecialPayment: monthlySpecialPayment,
        maxSpecialPaymentPercent: maxSpecialPaymentPercent,
        rentalShare: rentalShare,
        topTaxRate: topTaxRate,
        purchasePrice: purchasePrice,
        annualDepreciationRate: annualDepreciationRate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hypothekenrechner'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eingabedaten:'),
            TextFormField(
              decoration: InputDecoration(labelText: 'Kreditsumme'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                principal = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Jährlicher Zinssatz'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                annualInterestRate = double.tryParse(value) ?? 0.0;
              },
            ),
            // Weitere Eingabefelder für andere Parameter hinzufügen...
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: calculatePayments,
              child: Text('Berechnen'),
            ),
            SizedBox(height: 16.0),
            if (payments != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ergebnisse:'),
                  for (var payment in payments!)
                    Text(
                      'Monat ${payment.month}: Restschuld ${payment.remainingBalance.toStringAsFixed(2)}',
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
