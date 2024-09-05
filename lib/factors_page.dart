import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/custom_input_field.dart';
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
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                CustomInputField(
                  label: 'Kaufpreis',
                  suffix: '€',
                  initialValue: mortgage.housePrice,
                  onChanged: (value) => mortgage.updateHousePrice(value),
                ),
                CustomInputField(
                  label: 'Quadratmeter',
                  suffix: 'm²',
                  initialValue: mortgage.squareMeters,
                  onChanged: (value) => mortgage.updateSquareMeters(value),
                  decimalPlaces: 1,
                ),
                CustomInputField(
                  label: 'Eigenkapital',
                  suffix: '€',
                  initialValue: mortgage.equity,
                  onChanged: (value) => mortgage.updateEquity(value),
                ),
                CustomInputField(
                  label: 'Monatliche Rate',
                  suffix: '€',
                  initialValue: mortgage.monthlyPayment,
                  onChanged: (value) => mortgage.updateMonthlyPayment(value),
                ),
                CustomInputField(
                  label: 'Jährlicher Zinssatz',
                  suffix: '%',
                  initialValue: mortgage.annualInterestRate,
                  onChanged: (value) =>
                      mortgage.updateAnnualInterestRate(value),
                  isPercentage: true,
                ),
                CustomInputField(
                  label: 'Monatliche Sonderzahlung',
                  suffix: '€',
                  initialValue: mortgage.monthlySpecialPayment,
                  onChanged: (value) =>
                      mortgage.updateMonthlySpecialPayment(value),
                ),
                CustomInputField(
                  label: 'Max. Sonderzahlung',
                  suffix: '%',
                  initialValue: mortgage.maxSpecialPaymentPercent,
                  onChanged: (value) =>
                      mortgage.updateMaxSpecialPaymentPercent(value),
                  isPercentage: true,
                ),
                CustomInputField(
                  label: 'Mietanteil',
                  suffix: '%',
                  initialValue: mortgage.rentalShare,
                  onChanged: (value) => mortgage.updateRentalShare(value),
                  isPercentage: true,
                ),
                CustomInputField(
                  label: 'Spitzensteuersatz',
                  suffix: '%',
                  initialValue: mortgage.topTaxRate,
                  onChanged: (value) => mortgage.updateTopTaxRate(value),
                  isPercentage: true,
                ),
                CustomInputField(
                  label: 'Jährliche Abschreibung',
                  suffix: '%',
                  initialValue: mortgage.annualDepreciationRate,
                  onChanged: (value) =>
                      mortgage.updateAnnualDepreciationRate(value),
                  isPercentage: true,
                ),
              ],
            ),
            SizedBox(height: 16),
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
