import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/house.dart';
import 'package:provider/provider.dart';
import 'calculations/annuität.dart';

class SummaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgageProvider = Provider.of<MortgageCalculatorProvider>(context);
    final housePriceProvider = Provider.of<HousePriceProvider>(context);

    final calculationResult = mortgageProvider.calculateMortgagePayments();
    final housePriceOutput = housePriceProvider.housePriceOutput;
    final principal = mortgageProvider.principal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zusammenfassung'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: buildSummary(calculationResult, housePriceOutput, principal),
      ),
    );
  }

  Widget buildSummary(CalculationResult? calculationResult,
      HousePriceOutput? housePriceOutput, double principal) {
    if (calculationResult == null || housePriceOutput == null) {
      return const Text(
          'Keine Daten verfügbar. Bitte berechnen Sie zuerst die Hypothek und den Hauspreis.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Zusammenfassung:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
            'Gesamtkosten: ${housePriceOutput.totalHousePrice.toStringAsFixed(0)} €'),
        Text('Kreditsumme: ${principal.toStringAsFixed(0)} €'),
        Text(
            'Dauer bis zur Rückzahlung: ${calculationResult.totalMonths} Monate'),
        Text(
            'Gesamtsumme über alle Zahlungen: ${calculationResult.totalSum.toStringAsFixed(0)} €'),
        const SizedBox(height: 16.0),
        const Text('Zusätzliche Kosten:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
            'Notargebühren: ${housePriceOutput.notaryFees.toStringAsFixed(0)} €'),
        Text(
            'Grundbuchgebühren: ${housePriceOutput.landRegistryFees.toStringAsFixed(0)} €'),
        Text(
            'Maklerprovision: ${housePriceOutput.brokerCommission.toStringAsFixed(0)} €'),
      ],
    );
  }
}
