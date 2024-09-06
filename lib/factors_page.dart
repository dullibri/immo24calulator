import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/custom_input_field.dart';

class FactorsPage extends StatefulWidget {
  final Function(CalculationResult) onCalculate;

  FactorsPage({required this.onCalculate});

  @override
  _FactorsPageState createState() => _FactorsPageState();
}

class _FactorsPageState extends State<FactorsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mortgage = Provider.of<Mortgage>(context, listen: false);
      if (!mortgage.isFactorsPageVisited) {
        _performInitialCalculation(mortgage);
        _showInitialMessage();
        mortgage.setFactorsPageVisited();
      }
    });
  }

  void _performInitialCalculation(Mortgage mortgage) {
    final calculationResult = mortgage.calculateMortgagePayments();
    widget.onCalculate(calculationResult);
  }

  void _showInitialMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Die Berechnung wird automatisch aktualisiert, wenn Sie Werte ändern.'),
        duration: Duration(seconds: 5),
      ),
    );
  }

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
              _triggerCalculation(mortgage);
              _showUpdateNotification();
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
              _triggerCalculation(mortgage);
              _showUpdateNotification();
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
              _triggerCalculation(mortgage);
              _showUpdateNotification();
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
            initialValue: mortgage.annualInterestRate,
            onSubmitted: (value) {
              mortgage.updateAnnualInterestRate(value);
              _triggerCalculation(mortgage);
              _showUpdateNotification();
            },
            isPercentage: true,
            decimalPlaces: 2,
            minValue: 0.01,
            maxValue: 20.0,
            tooltip: 'Der jährliche Zinssatz des Kredits',
          ),
          SizedBox(height: 16),
          if (!mortgage.isCalculationValid)
            Text(
              'Bitte geben Sie gültige Werte ein, um die Berechnung zu ermöglichen.',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  void _triggerCalculation(Mortgage mortgage) {
    if (mortgage.isCalculationValid) {
      final calculationResult = mortgage.calculateMortgagePayments();
      widget.onCalculate(calculationResult);
    } else {
      setState(
          () {}); // Aktualisiere UI, um mögliche Fehlermeldungen anzuzeigen
    }
  }

  void _showUpdateNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berechnungen wurden aktualisiert'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
