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

  List<MortgagePayment>? payments;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  Map<String, bool> columnVisibility = {
    'Monat': true,
    'Restschuld': true,
    'Hauptzahlung': true,
    'Zinszahlung': true,
    'Sonderzahlung': true,
    'Rest-Sonderzahlung': true,
    'Zinsrabatt': true,
    'Abschreibung': true,
  };

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
      label: Row(
        children: [
          Text(label),
          Checkbox(
            value: columnVisibility[label],
            onChanged: (value) {
              setState(() {
                columnVisibility[label] = value!;
              });
            },
          ),
        ],
      ),
      onSort: (index, ascending) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _sortAscending = ascending;
          payments!.sort((a, b) => ascending ? compare(a, b) : compare(b, a));
        });
      },
    );
  }

  List<DataColumn> getVisibleColumns() {
    int index = 0;
    List<String> labels = [
      'Monat',
      'Restschuld',
      'Hauptzahlung',
      'Zinszahlung',
      'Sonderzahlung',
      'Rest-Sonderzahlung',
      'Zinsrabatt',
      'Abschreibung'
    ];
    List<int Function(MortgagePayment, MortgagePayment)> comparators = [
      (a, b) => a.month.compareTo(b.month),
      (a, b) => a.remainingBalance.compareTo(b.remainingBalance),
      (a, b) => a.principalPayment.compareTo(b.principalPayment),
      (a, b) => a.interestPayment.compareTo(b.interestPayment),
      (a, b) => a.specialPayment.compareTo(b.specialPayment),
      (a, b) => a.remainingSpecialPayment.compareTo(b.remainingSpecialPayment),
      (a, b) => a.interestRebate.compareTo(b.interestRebate),
      (a, b) => a.depreciation.compareTo(b.depreciation),
    ];

    return labels
        .asMap()
        .entries
        .map((entry) {
          int index = entry.key;
          String label = entry.value;
          if (columnVisibility[label]!) {
            return buildDataColumn(label, index, comparators[index]);
          }
          return null;
        })
        .where((column) => column != null)
        .cast<DataColumn>()
        .toList();
  }

  List<DataCell> getVisibleCells(MortgagePayment payment) {
    List<String> labels = [
      'Monat',
      'Restschuld',
      'Hauptzahlung',
      'Zinszahlung',
      'Sonderzahlung',
      'Rest-Sonderzahlung',
      'Zinsrabatt',
      'Abschreibung'
    ];
    List<DataCell> cells = [
      DataCell(Text(payment.month.toString())),
      DataCell(Text(payment.remainingBalance.toStringAsFixed(0))),
      DataCell(Text(payment.principalPayment.toStringAsFixed(0))),
      DataCell(Text(payment.interestPayment.toStringAsFixed(0))),
      DataCell(Text(payment.specialPayment.toStringAsFixed(0))),
      DataCell(Text(payment.remainingSpecialPayment.toStringAsFixed(0))),
      DataCell(Text(payment.interestRebate.toStringAsFixed(0))),
      DataCell(Text(payment.depreciation.toStringAsFixed(0))),
    ];

    return labels
        .asMap()
        .entries
        .map((entry) {
          int index = entry.key;
          String label = entry.value;
          if (columnVisibility[label]!) {
            return cells[index];
          }
          return null;
        })
        .where((cell) => cell != null)
        .cast<DataCell>()
        .toList();
  }

  void showColumnToggleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Spalten ein-/ausblenden'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: columnVisibility.keys.map((label) {
              return Row(
                children: [
                  Text(label),
                  Checkbox(
                    value: columnVisibility[label],
                    onChanged: (value) {
                      setState(() {
                        columnVisibility[label] = value!;
                      });
                    },
                  ),
                ],
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Schließen'),
            ),
          ],
        );
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
                    columns: getVisibleColumns(),
                    rows: payments!.map((payment) {
                      return DataRow(
                        cells: getVisibleCells(payment),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showColumnToggleDialog,
        child: Icon(Icons.settings),
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
