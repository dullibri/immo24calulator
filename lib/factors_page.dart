import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/german_currency_input.dart';
import 'package:immo24calculator/widgets/german_percentage_handler.dart';
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
            GermanPercentageInput(
                label: 'Jährlicher Zinssatz',
                initialValue: mortgage.annualInterestRate,
                onChanged: (value) {
                  if (value != null) {
                    mortgage.updateAnnualInterestRate(value);
                  }
                }),
            GermanCurrencyInput(
              label: 'Monatliche Sonderzahlung',
              initialValue: mortgage.monthlySpecialPayment.round(),
              onChanged: (value) =>
                  mortgage.updateMonthlySpecialPayment(value.toDouble()),
            ),
            GermanPercentageInput(
              label: 'Max. Sonderzahlung',
              initialValue: mortgage.maxSpecialPaymentPercent,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateMaxSpecialPaymentPercent(value);
                }
              },
            ),
            GermanPercentageInput(
              label: 'Mietanteil',
              initialValue: mortgage.rentalShare,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateRentalShare(value);
                }
              },
            ),
            GermanPercentageInput(
              label: 'Spitzensteuersatz',
              initialValue: mortgage.topTaxRate,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateTopTaxRate(value);
                }
              },
            ),
            GermanPercentageInput(
              label: 'Jährliche Abschreibung',
              initialValue: mortgage.annualDepreciationRate,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateAnnualDepreciationRate(value);
                }
              },
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

  void calculateAndNavigate(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context, listen: false);
    final calculationResult = mortgage.calculateMortgagePayments();
    mortgage.calculateTotalHousePrice();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SummaryPage(calculationResult: calculationResult)),
    );
  }
}
