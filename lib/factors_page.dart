import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/german_currency_input.dart';
import 'package:provider/provider.dart';
import 'summary_page.dart';

class FactorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context);

    return AppScaffold(
      title: 'Hauptfaktoren',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Hauptfaktoren:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            GermanCurrencyInput(
              label: 'Kaufpreis',
              initialValue: mortgage.housePrice.round(),
              onChanged: (value) => mortgage.updateHousePrice(value.toDouble()),
            ),
            GermanCurrencyInput(
              label: 'Eigenkapital',
              initialValue: mortgage.equity.round(),
              onChanged: (value) => mortgage.updateEquity(value.toDouble()),
            ),
            GermanCurrencyInput(
              label: 'Monatliche Rate',
              initialValue: mortgage.monthlyPayment.round(),
              onChanged: (value) =>
                  mortgage.updateMonthlyPayment(value.toDouble()),
            ),
            buildInputField(
              context,
              'Jährlicher Zinssatz (%)',
              mortgage.annualInterestRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgage.updateAnnualInterestRate),
              true,
            ),
            GermanCurrencyInput(
                label: 'Monatliche Sonderzahlung',
                initialValue: mortgage.monthlySpecialPayment.round(),
                onChanged: (value) => value.toDouble()),
            buildInputField(
              context,
              'Max. Sonderzahlung (%)',
              mortgage.maxSpecialPaymentPercent.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgage.updateMaxSpecialPaymentPercent),
              true,
            ),
            buildInputField(
              context,
              'Mietanteil',
              mortgage.rentalShare.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgage.updateRentalShare),
              false,
            ),
            buildInputField(
              context,
              'Spitzensteuersatz',
              mortgage.topTaxRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgage.updateTopTaxRate),
              false,
            ),
            buildInputField(
              context,
              'Jährliche Abschreibung (%)',
              mortgage.annualDepreciationRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgage.updateAnnualDepreciationRate),
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
    final mortgage = Provider.of<Mortgage>(context, listen: false);

    // Calculate mortgage payments
    final calculationResult = mortgage.calculateMortgagePayments();

    // Update house price
    mortgage.calculateTotalHousePrice();

    // Navigate to the summary page with the calculation result
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SummaryPage(calculationResult: calculationResult)),
    );
  }
}
