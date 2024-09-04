import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/annuität.dart';
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
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updatePurchasePrice),
              true,
            ),
            buildInputField(
              context,
              'Eigenkapital',
              mortgageProvider.equity.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updateEquity),
              true,
            ),
            buildInputField(
              context,
              'Monatliche Rate',
              mortgageProvider.monthlyPayment.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updateMonthlyPayment),
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
            buildInputField(
              context,
              'Spitzensteuersatz',
              mortgageProvider.topTaxRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updateTopTaxRate),
              false,
            ),
            buildInputField(
              context,
              'Jährliche Abschreibung (%)',
              mortgageProvider.annualDepreciationRate.toString(),
              (value) => handleTextFieldChange(context, value,
                  mortgageProvider.updateAnnualDepreciationRate),
              true,
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

    // Calculate mortgage payments
    final calculationResult = mortgageProvider.calculateMortgagePayments();

    // Update house price
    housePriceProvider.calculateTotalHousePrice();

    // Navigate to the summary page with the calculation result
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SummaryPage(calculationResult: calculationResult)),
    );
  }
}
