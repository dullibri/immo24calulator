import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/annuit%C3%A4t.dart';
import 'package:provider/provider.dart';
import 'summary_page.dart';

class FactorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MortgageCalculatorProvider>(context);

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
              provider.purchasePrice.toString(),
              (value) => handleTextFieldChange(context, value, (newValue) {
                provider.updatePurchasePrice(newValue);
                if (provider.equity > newValue) {
                  provider.updateEquity(newValue);
                }
              }),
              true,
            ),
            buildInputField(
              context,
              'Eigenkapital',
              provider.equity.toString(),
              (value) => handleTextFieldChange(context, value, (newValue) {
                provider.updateEquity(newValue);
                if (newValue > provider.purchasePrice) {
                  provider.updatePurchasePrice(newValue);
                }
              }),
              true,
            ),
            buildInputField(
              context,
              'Jährlicher Zinssatz (%)',
              provider.annualInterestRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, provider.updateAnnualInterestRate),
              true,
            ),
            buildInputField(
              context,
              'Anfängliche Zahlung',
              provider.initialPayment.toString(),
              (value) => handleTextFieldChange(
                  context, value, provider.updateInitialPayment),
              true,
            ),
            buildInputField(
              context,
              'Monatliche Sonderzahlung',
              provider.monthlySpecialPayment.toString(),
              (value) => handleTextFieldChange(
                  context, value, provider.updateMonthlySpecialPayment),
              true,
            ),
            buildInputField(
              context,
              'Max. Sonderzahlung (%)',
              provider.maxSpecialPaymentPercent.toString(),
              (value) => handleTextFieldChange(
                  context, value, provider.updateMaxSpecialPaymentPercent),
              true,
            ),
            buildInputField(
              context,
              'Mietanteil',
              provider.rentalShare.toString(),
              (value) => handleTextFieldChange(
                  context, value, provider.updateRentalShare),
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
    final provider =
        Provider.of<MortgageCalculatorProvider>(context, listen: false);
    provider.updatePrincipal(provider.purchasePrice - provider.equity);
    final calculationResult = provider.calculateMortgagePayments();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryPage(
          principal: provider.principal,
          calculationResult: calculationResult,
          housePriceOutput: null,
        ),
      ),
    );
  }
}
