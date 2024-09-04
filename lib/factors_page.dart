import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/annuit%C3%A4t.dart';
import 'package:immo_credit/calculations/house.dart';
import 'package:provider/provider.dart';
import 'summary_page.dart';

class FactorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgageProvider = Provider.of<MortgageCalculatorProvider>(context);

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
            buildInputField(
              context,
              'Kaufpreis',
              mortgageProvider.purchasePrice.toString(),
              (value) => handleTextFieldChange(context, value, (newValue) {
                if (newValue > mortgageProvider.purchasePrice) {
                  final housePriceProvider =
                      Provider.of<HousePriceProvider>(context, listen: false);
                  housePriceProvider.updateHousePriceInput(
                      housePrice: newValue);
                }
              }),
              true,
            ),
            buildInputField(
              context,
              'Monatliche Rate',
              mortgageProvider.initialPayment.toString(),
              (value) => handleTextFieldChange(context, value, (newValue) {
                if (newValue > mortgageProvider.initialPayment) {
                  mortgageProvider.updateInitialPayment(newValue);
                }
              }),
              true,
            ),
            buildInputField(
              context,
              'Jährlicher Zinssatz (%)',
              mortgageProvider.annualInterestRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updateAnnualInterestRate),
              true,
            ),
            buildInputField(
              context,
              'Monatliche Sonderzahlung',
              mortgageProvider.monthlySpecialPayment.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updateMonthlySpecialPayment),
              true,
            ),
            buildInputField(
              context,
              'Max. Sonderzahlung (%)',
              mortgageProvider.maxSpecialPaymentPercent.toString(),
              (value) => handleTextFieldChange(context, value,
                  mortgageProvider.updateMaxSpecialPaymentPercent),
              true,
            ),
            buildInputField(
              context,
              'Mietanteil',
              mortgageProvider.rentalShare.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updateRentalShare),
              false,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => calculateAndNavigate(context),
              child: const Text('Berechnen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(BuildContext context, String label,
      String initialValue, Function(String)? onChanged, bool positiveOnly) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: initialValue,
      ),
      keyboardType: TextInputType.number,
      initialValue: initialValue,
      onChanged: onChanged != null
          ? (value) {
              if (positiveOnly &&
                  double.tryParse(value) != null &&
                  double.parse(value) < 0) {
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

  void handleTextFieldChange(
      BuildContext context, String value, Function(double) updateFunction) {
    if (double.tryParse(value) != null) {
      updateFunction(double.parse(value));
    }
  }

  void calculateAndNavigate(BuildContext context) {
    final mortgageProvider =
        Provider.of<MortgageCalculatorProvider>(context, listen: false);
    final housePriceProvider =
        Provider.of<HousePriceProvider>(context, listen: false);

    // Aktualisieren Sie den Hauptbetrag basierend auf dem aktuellen Kaufpreis und der Anfangszahlung
    mortgageProvider.updatePrincipal(
        mortgageProvider.purchasePrice - mortgageProvider.initialPayment);

    // Berechnen Sie die Hypothekenzahlungen neu, aber speichern Sie das Ergebnis nicht
    final calculationResult = mortgageProvider.calculateMortgagePayments();

    // Aktualisieren Sie den Hauspreis
    housePriceProvider.calculateTotalHousePrice();

    // Navigieren Sie zur Zusammenfassungsseite und übergeben Sie das Berechnungsergebnis
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SummaryPage(calculationResult: calculationResult)),
    );
  }
}
