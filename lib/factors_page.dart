import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/custom_input_field.dart';

class FactorsPage extends StatelessWidget {
  final Function(CalculationResult) onCalculate;

  FactorsPage({required this.onCalculate});

  @override
  Widget build(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Hauptfaktoren:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          CustomInputField(
            label: 'Kaufpreis',
            suffix: '€',
            initialValue: mortgage.housePrice,
            onSubmitted: (value) {
              mortgage.updateHousePrice(value);
              _checkAndTriggerCalculation(context, mortgage);
            },
            decimalPlaces: 0,
            minValue: 10000,
            maxValue: 10000000,
            tooltip: 'Der Gesamtkaufpreis der Immobilie',
          ),
          SizedBox(height: 16),
          CustomInputField(
            label: 'Eigenkapital',
            suffix: '€',
            initialValue: mortgage.equity,
            onSubmitted: (value) {
              mortgage.updateEquity(value);
              _checkAndTriggerCalculation(context, mortgage);
            },
            decimalPlaces: 0,
            minValue: 0,
            maxValue: mortgage.housePrice,
            tooltip: 'Das eingesetzte Eigenkapital',
          ),
          SizedBox(height: 16),
          CustomInputField(
            label: 'Monatliche Rate',
            suffix: '€',
            initialValue: mortgage.monthlyPayment,
            onSubmitted: (value) {
              mortgage.updateMonthlyPayment(value);
              _checkAndTriggerCalculation(context, mortgage);
            },
            decimalPlaces: 0,
            minValue: 1,
            maxValue: mortgage.principal / 12,
            tooltip: 'Die monatliche Kreditrate',
          ),
          SizedBox(height: 16),
          CustomInputField(
            label: 'Jährlicher Zinssatz',
            suffix: '%',
            initialValue:
                mortgage.annualInterestRate, // Korrekte Umwandlung in Prozent
            onSubmitted: (value) {
              mortgage.updateAnnualInterestRate(
                  value / 100); // Umwandlung zurück in Dezimalzahl
              _checkAndTriggerCalculation(context, mortgage);
            },
            isPercentage: true,
            decimalPlaces: 2,
            minValue: 0.0,

            tooltip: 'Der jährliche Zinssatz des Kredits',
          ),
          SizedBox(height: 16),
          if (!mortgage.isCalculationValid)
            Text(
              'Bitte geben Sie gültige Werte ein, um die Berechnung zu ermöglichen.',
              style: TextStyle(color: const Color.fromARGB(255, 134, 111, 110)),
            ),
        ],
      ),
    );
  }

  void _checkAndTriggerCalculation(BuildContext context, Mortgage mortgage) {
    final calculationResult = mortgage.calculateMortgagePayments();
    onCalculate(calculationResult);
    _showUpdateNotification(context);
  }

  void _showUpdateNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berechnungen wurden aktualisiert'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
