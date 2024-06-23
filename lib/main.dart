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
  double principal = 600000;
  double annualInterestRate = 3.61;
  double initialPayment = 3200.00;
  double monthlySpecialPayment = 1185; // Zusätzliche monatliche Sonderzahlungen
  double maxSpecialPaymentPercent =
      5; // Maximal 5% der ursprünglichen Kreditsumme als zusätzliche Sonderzahlungen
  double rentalShare = 580000 /
      544000; // Verhältnis von vermietetem/gewerblichem Anteil zu Gesamtkredit
  double topTaxRate = 0.42; // 42% Spitzensteuersatz
  double purchasePrice = 800000;
  double annualDepreciationRate = 0.03;

  CalculationResult? calculationResult;

  void calculatePayments() {
    setState(() {
      calculationResult = calculateMortgagePayments(
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

  Widget buildInputField(
      String label, String initialValue, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: initialValue,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hypothekenrechner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Eingabedaten:'),
            buildInputField(
              'Kreditsumme',
              principal.toString(),
              (value) {
                principal = double.tryParse(value) ?? 0.0;
              },
            ),
            buildInputField(
              'Jährlicher Zinssatz',
              annualInterestRate.toString(),
              (value) {
                annualInterestRate = double.tryParse(value) ?? 0.0;
              },
            ),
            buildInputField(
              'Anfangszahlung',
              initialPayment.toString(),
              (value) {
                initialPayment = double.tryParse(value) ?? 0.0;
              },
            ),
            buildInputField(
              'Monatliche Sonderzahlung',
              monthlySpecialPayment.toString(),
              (value) {
                monthlySpecialPayment = double.tryParse(value) ?? 0.0;
              },
            ),
            buildInputField(
              'Mietanteil',
              rentalShare.toString(),
              (value) {
                rentalShare = double.tryParse(value) ?? 0.0;
              },
            ),
            buildInputField(
              'Kaufpreis',
              purchasePrice.toString(),
              (value) {
                purchasePrice = double.tryParse(value) ?? 0.0;
              },
            ),
            buildInputField(
              'Jährliche Abschreibung',
              annualDepreciationRate.toString(),
              (value) {
                annualDepreciationRate = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: calculatePayments,
              child: const Text('Berechnen'),
            ),
            const SizedBox(height: 16.0),
            if (calculationResult != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ergebnisse:'),
                  Text(
                      'Dauer bis zur Rückzahlung: ${calculationResult!.totalMonths} Monate'),
                  Text(
                      'Gesamtsumme über alle Spalten: ${calculationResult!.totalSum.toStringAsFixed(2)} €'),
                  const SizedBox(height: 16.0),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Monat')),
                      DataColumn(label: Text('Restschuld')),
                      DataColumn(label: Text('Tilgung')),
                      DataColumn(label: Text('Zinsen')),
                      DataColumn(label: Text('Sonderzahlung')),
                      DataColumn(label: Text('Verbleibende Sonderzahlung')),
                      DataColumn(label: Text('Zinsvorteil')),
                      DataColumn(label: Text('Abschreibung')),
                    ],
                    rows: calculationResult!.payments.map((payment) {
                      return DataRow(cells: [
                        DataCell(Text(payment.month.toString())),
                        DataCell(
                            Text(payment.remainingBalance.toStringAsFixed(2))),
                        DataCell(
                            Text(payment.principalPayment.toStringAsFixed(2))),
                        DataCell(
                            Text(payment.interestPayment.toStringAsFixed(2))),
                        DataCell(
                            Text(payment.specialPayment.toStringAsFixed(2))),
                        DataCell(Text(payment.remainingSpecialPayment
                            .toStringAsFixed(2))),
                        DataCell(
                            Text(payment.interestRebate.toStringAsFixed(2))),
                        DataCell(Text(payment.depreciation.toStringAsFixed(2))),
                      ]);
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
