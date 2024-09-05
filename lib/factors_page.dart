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
            onChanged: (value) => mortgage.updateHousePrice(value),
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
            onChanged: (value) => mortgage.updateEquity(value),
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
            onChanged: (value) => mortgage.updateMonthlyPayment(value),
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
                mortgage.annualInterestRate * 100, // Umrechnung in Prozent
            onChanged: (value) => mortgage.updateAnnualInterestRate(
                value / 100), // Umrechnung in Dezimalzahl
            isPercentage: true,
            minValue: 0.1,
            maxValue: 20,
            tooltip: 'Der jährliche Zinssatz des Kredits',
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final calculationResult = mortgage.calculateMortgagePayments();
              mortgage.calculateTotalHousePrice();
              onCalculate(calculationResult);
            },
            child: const Text('Berechnen'),
          ),
        ],
      ),
    );
  }
}
