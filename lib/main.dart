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
  int? _sortColumnIndex;
  bool _sortAscending = true;

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

  DataColumn buildDataColumn(String label, int columnIndex,
      int Function(MortgagePayment a, MortgagePayment b) compare) {
    return DataColumn(
      label: Text(label),
      onSort: (index, ascending) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _sortAscending = ascending;
          payments!.sort((a, b) => ascending ? compare(a, b) : compare(b, a));
        });
      },
    );
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
            MortgageInputField(
              label: 'Kreditsumme',
              initialValue: principal.toString(),
              onChanged: (value) {
                principal = double.tryParse(value) ?? 0.0;
              },
            ),
            MortgageInputField(
              label: 'Jährlicher Zinssatz',
              initialValue: annualInterestRate.toString(),
              onChanged: (value) {
                annualInterestRate = double.tryParse(value) ?? 0.0;
              },
            ),
            MortgageInputField(
              label: 'Anfangszahlung',
              initialValue: initialPayment.toString(),
              onChanged: (value) {
                initialPayment = double.tryParse(value) ?? 0.0;
              },
            ),
            MortgageInputField(
              label: 'Monatliche Sonderzahlung',
              initialValue: monthlySpecialPayment.toString(),
              onChanged: (value) {
                monthlySpecialPayment = double.tryParse(value) ?? 0.0;
              },
            ),
            MortgageInputField(
              label: 'Mietanteil',
              initialValue: rentalShare.toString(),
              onChanged: (value) {
                rentalShare = double.tryParse(value) ?? 0.0;
              },
            ),
            MortgageInputField(
              label: 'Kaufpreis',
              initialValue: purchasePrice.toString(),
              onChanged: (value) {
                purchasePrice = double.tryParse(value) ?? 0.0;
              },
            ),
            MortgageInputField(
              label: 'Jährliche Abschreibung',
              initialValue: annualDepreciationRate.toString(),
              onChanged: (value) {
                annualDepreciationRate = double.tryParse(value) ?? 0.0;
              },
            ),
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
                  DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columns: [
                      buildDataColumn(
                          'Monat', 0, (a, b) => a.month.compareTo(b.month)),
                      buildDataColumn(
                          'Restschuld',
                          1,
                          (a, b) =>
                              a.remainingBalance.compareTo(b.remainingBalance)),
                      buildDataColumn(
                          'Hauptzahlung',
                          2,
                          (a, b) =>
                              a.principalPayment.compareTo(b.principalPayment)),
                      buildDataColumn(
                          'Zinszahlung',
                          3,
                          (a, b) =>
                              a.interestPayment.compareTo(b.interestPayment)),
                      buildDataColumn(
                          'Sonderzahlung',
                          4,
                          (a, b) =>
                              a.specialPayment.compareTo(b.specialPayment)),
                      buildDataColumn(
                          'Rest-Sonderzahlung',
                          5,
                          (a, b) => a.remainingSpecialPayment
                              .compareTo(b.remainingSpecialPayment)),
                      buildDataColumn(
                          'Zinsrabatt',
                          6,
                          (a, b) =>
                              a.interestRebate.compareTo(b.interestRebate)),
                      buildDataColumn('Abschreibung', 7,
                          (a, b) => a.depreciation.compareTo(b.depreciation)),
                    ],
                    rows: payments!.map((payment) {
                      return DataRow(
                        cells: [
                          DataCell(Text(payment.month.toString())),
                          DataCell(Text(
                              payment.remainingBalance.toStringAsFixed(2))),
                          DataCell(Text(
                              payment.principalPayment.toStringAsFixed(2))),
                          DataCell(
                              Text(payment.interestPayment.toStringAsFixed(2))),
                          DataCell(
                              Text(payment.specialPayment.toStringAsFixed(2))),
                          DataCell(Text(payment.remainingSpecialPayment
                              .toStringAsFixed(2))),
                          DataCell(
                              Text(payment.interestRebate.toStringAsFixed(2))),
                          DataCell(
                              Text(payment.depreciation.toStringAsFixed(2))),
                        ],
                      );
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

class MortgageInputField extends StatelessWidget {
  final String label;
  final String initialValue;
  final Function(String) onChanged;

  MortgageInputField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: initialValue,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}
