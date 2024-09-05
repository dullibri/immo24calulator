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
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildInputField(
                      'Kaufpreis',
                      '€',
                      mortgage.housePrice,
                      (value) => mortgage.updateHousePrice(value),
                      constraints,
                      decimalPlaces: 0,
                    ),
                    _buildInputField(
                      'Quadratmeter',
                      'm²',
                      mortgage.squareMeters,
                      (value) => mortgage.updateSquareMeters(value),
                      constraints,
                      decimalPlaces: 1,
                    ),
                    _buildInputField(
                      'Eigenkapital',
                      '€',
                      mortgage.equity,
                      (value) => mortgage.updateEquity(value),
                      constraints,
                      decimalPlaces: 0,
                    ),
                    _buildInputField(
                      'Monatliche Rate',
                      '€',
                      mortgage.monthlyPayment,
                      (value) => mortgage.updateMonthlyPayment(value),
                      constraints,
                      decimalPlaces: 0,
                    ),
                    _buildInputField(
                      'Jährlicher Zinssatz',
                      '%',
                      mortgage.annualInterestRate,
                      (value) => mortgage.updateAnnualInterestRate(value),
                      constraints,
                      isPercentage: true,
                    ),
                    _buildInputField(
                      'Monatliche Sonderzahlung',
                      '€',
                      mortgage.monthlySpecialPayment,
                      (value) => mortgage.updateMonthlySpecialPayment(value),
                      constraints,
                      decimalPlaces: 0,
                    ),
                    _buildInputField(
                      'Max. Sonderzahlung',
                      '%',
                      mortgage.maxSpecialPaymentPercent,
                      (value) => mortgage.updateMaxSpecialPaymentPercent(value),
                      constraints,
                      isPercentage: true,
                    ),
                    _buildInputField(
                      'Mietanteil',
                      '%',
                      mortgage.rentalShare,
                      (value) => mortgage.updateRentalShare(value),
                      constraints,
                      isPercentage: true,
                    ),
                    _buildInputField(
                      'Spitzensteuersatz',
                      '%',
                      mortgage.topTaxRate,
                      (value) => mortgage.updateTopTaxRate(value),
                      constraints,
                      isPercentage: true,
                    ),
                    _buildInputField(
                      'Jährliche Abschreibung',
                      '%',
                      mortgage.annualDepreciationRate,
                      (value) => mortgage.updateAnnualDepreciationRate(value),
                      constraints,
                      isPercentage: true,
                    ),
                  ],
                );
              },
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

  Widget _buildInputField(
    String label,
    String suffix,
    double initialValue,
    ValueChanged<double> onChanged,
    BoxConstraints constraints, {
    bool isPercentage = false,
    int decimalPlaces = 2,
  }) {
    double width = constraints.maxWidth;
    if (width > 600) {
      width = (width - 16) / 2; // Two columns with 16px spacing
    }
    if (width > 400) {
      width = 400; // Max width for input fields
    }

    return Container(
      width: width,
      child: CustomInputField(
        label: label,
        suffix: suffix,
        initialValue: initialValue,
        onChanged: onChanged,
        isPercentage: isPercentage,
        decimalPlaces: decimalPlaces,
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
