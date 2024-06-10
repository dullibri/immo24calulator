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
  int _sortColumnIndex = 0;
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
              decoration: InputDecoration(
                labelText: 'Kreditsumme',
                hintText: principal.toString(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                principal = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Jährlicher Zinssatz',
                hintText: annualInterestRate.toString(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                annualInterestRate = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Anfangszahlung',
                hintText: initialPayment.toString(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                initialPayment = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Monatliche Sonderzahlung',
                hintText: monthlySpecialPayment.toString(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                monthlySpecialPayment = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Mietanteil',
                hintText: rentalShare.toString(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                rentalShare = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Kaufpreis',
                hintText: purchasePrice.toString(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                purchasePrice = double.tryParse(value) ?? 0.0;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Jährliche Abschreibung',
                hintText: annualDepreciationRate.toString(),
              ),
              keyboardType: TextInputType.number,
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
                      DataColumn(
                          label: Text('Monat'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                              if (ascending) {
                                payments!
                                    .sort((a, b) => a.month.compareTo(b.month));
                              } else {
                                payments!
                                    .sort((a, b) => b.month.compareTo(a.month));
                              }
                            });
                          }),
                      DataColumn(
                          label: Text('Restschuld'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                              if (ascending) {
                                payments!.sort((a, b) => a.remainingBalance
                                    .compareTo(b.remainingBalance));
                              } else {
                                payments!.sort((a, b) => b.remainingBalance
                                    .compareTo(a.remainingBalance));
                              }
                            });
                          }),
                      DataColumn(
                          label: Text('Hauptzahlung'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                              if (ascending) {
                                payments!.sort((a, b) => a.principalPayment
                                    .compareTo(b.principalPayment));
                              } else {
                                payments!.sort((a, b) => b.principalPayment
                                    .compareTo(a.principalPayment));
                              }
                            });
                          }),
                      DataColumn(
                          label: Text('Zinszahlung'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                              if (ascending) {
                                payments!.sort((a, b) => a.interestPayment
                                    .compareTo(b.interestPayment));
                              } else {
                                payments!.sort((a, b) => b.interestPayment
                                    .compareTo(a.interestPayment));
                              }
                            });
                          }),
                      DataColumn(
                          label: Text('Sonderzahlung'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                              if (ascending) {
                                payments!.sort((a, b) => a.specialPayment
                                    .compareTo(b.specialPayment));
                              } else {
                                payments!.sort((a, b) => b.specialPayment
                                    .compareTo(a.specialPayment));
                                payments!.sort((a, b) => b.specialPayment
                                    .compareTo(a.specialPayment));
                              }
                            });
                          }),
                      DataColumn(
                          label: Text('Rest-Sonderzahlung'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                              if (ascending) {
                                payments!.sort((a, b) => a
                                    .remainingSpecialPayment
                                    .compareTo(b.remainingSpecialPayment));
                              } else {
                                payments!.sort((a, b) => b
                                    .remainingSpecialPayment
                                    .compareTo(a.remainingSpecialPayment));
                              }
                            });
                          }),
                      DataColumn(
                          label: Text('Zinsrabatt'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                              if (ascending) {
                                payments!.sort((a, b) => a.interestRebate
                                    .compareTo(b.interestRebate));
                              } else {
                                payments!.sort((a, b) => b.interestRebate
                                    .compareTo(a.interestRebate));
                              }
                            });
                          }),
                      DataColumn(
                          label: Text('Abschreibung'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                              if (ascending) {
                                payments!.sort((a, b) =>
                                    a.depreciation.compareTo(b.depreciation));
                              } else {
                                payments!.sort((a, b) =>
                                    b.depreciation.compareTo(a.depreciation));
                              }
                            });
                          }),
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
