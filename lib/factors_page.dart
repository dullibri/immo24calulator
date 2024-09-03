import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/annuit%C3%A4t.dart';
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
                  mortgageProvider.updatePurchasePrice(newValue);
                }
              }),
              true,
            ),
            buildInputField(
              context,
              'Eigenkapital',
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
              'Anfängliche Zahlung',
              mortgageProvider.initialPayment.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updateInitialPayment),
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
    mortgageProvider.updatePrincipal(
        mortgageProvider.purchasePrice - mortgageProvider.initialPayment);
    final calculationResult = mortgageProvider.calculateMortgagePayments();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryPage(
          principal: mortgageProvider.principal,
          calculationResult: calculationResult,
          housePriceOutput: null,
        ),
      ),
    );
  }
}
