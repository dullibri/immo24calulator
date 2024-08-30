import 'package:flutter/material.dart';
import 'calculations/house.dart';
import 'calculations/annuität.dart'; // Importiere die Berechnungslogik
import 'summary_page.dart';

class FactorsPage extends StatefulWidget {
  @override
  _FactorsPageState createState() => _FactorsPageState();
}

class _FactorsPageState extends State<FactorsPage> {
  // Variablen für die Eingabewerte
  double annualInterestRate = 3.61;
  double initialPayment = 3200.00;
  double monthlySpecialPayment = 1185;
  double maxSpecialPaymentPercent = 5;
  double rentalShare = 580000 / 544000;
  double purchasePrice = 800000;
  double equity = 100000;
  double principal = 0.0; // Kreditsumme

  void calculateAndNavigate() {
    // Berechne die Kreditsumme
    principal = purchasePrice - equity;

    // Berechne die Ergebnisse für die Hypothek
    final calculationResult = calculateMortgagePayments(
      principal: principal,
      annualInterestRate: annualInterestRate,
      initialPayment: initialPayment,
      monthlySpecialPayment: monthlySpecialPayment,
      maxSpecialPaymentPercent: maxSpecialPaymentPercent,
      rentalShare: rentalShare,
      topTaxRate: 0.42, // Beispielwert
      purchasePrice: purchasePrice,
      annualDepreciationRate: 0.03, // Beispielwert
    );

    // Navigiere zur SummaryPage und übergebe die berechneten Werte
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryPage(
          principal: principal, // Übergebe die berechnete Kreditsumme
          calculationResult:
              calculationResult, // Übergebe das Berechnungsergebnis
          housePriceOutput:
              null, // Optional: Falls du Hauspreise übergeben möchtest
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hauptfaktoren'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Hauptfaktoren:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Eingabefelder für die verschiedenen Parameter
            buildInputField(
              'Kaufpreis',
              purchasePrice.toString(),
              (value) => handleTextFieldChange(value, (newValue) {
                setState(() {
                  purchasePrice = newValue;
                  if (equity > purchasePrice) {
                    equity = purchasePrice;
                  }
                });
              }),
              true,
            ),
            buildInputField(
              'Eigenkapital',
              equity.toString(),
              (value) => handleTextFieldChange(value, (newValue) {
                setState(() {
                  equity = newValue;
                  if (equity > purchasePrice) {
                    purchasePrice = equity;
                  }
                });
              }),
              true,
            ),
            // Weitere Eingabefelder hier...
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: calculateAndNavigate,
              child: const Text('Berechnen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(String label, String initialValue,
      Function(String)? onChanged, bool positiveOnly) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: initialValue,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged != null
          ? (value) {
              if (positiveOnly &&
                  double.tryParse(value) != null &&
                  double.parse(value) < 0) {
                // Verhindere negative Eingaben
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Wert darf nicht negativ sein')),
                );
              } else {
                onChanged(value);
              }
            }
          : null,
    );
  }

  void handleTextFieldChange(String value, Function(double) updateFunction) {
    if (double.tryParse(value) != null) {
      updateFunction(double.parse(value));
    }
  }
}
