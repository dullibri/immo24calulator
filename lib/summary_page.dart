import 'package:flutter/material.dart';
import 'calculations/annuität.dart'; // Importiere die Berechnungslogik
import 'calculations/house.dart'; // Importiere HousePriceOutput

class SummaryPage extends StatelessWidget {
  final double principal; // Kreditsumme
  final CalculationResult? calculationResult;
  final HousePriceOutput? housePriceOutput;

  SummaryPage({
    required this.principal,
    this.calculationResult,
    this.housePriceOutput,
  });

  Widget buildSummary() {
    if (calculationResult == null || housePriceOutput == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Zusammenfassung:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
            'Gesamtkosten: ${housePriceOutput!.totalHousePrice.toStringAsFixed(0)} €'),
        Text(
            'Kreditsumme: ${principal.toStringAsFixed(0)} €'), // Zeigt die Kreditsumme an
        Text(
            'Dauer bis zur Rückzahlung: ${calculationResult!.totalMonths} Monate'),
        Text(
            'Gesamtsumme über alle Zahlungen: ${calculationResult!.totalSum.toStringAsFixed(0)} €'),
        const SizedBox(height: 16.0),
        const Text('Zusätzliche Kosten:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
            'Notargebühren: ${housePriceOutput!.notaryFees.toStringAsFixed(0)} €'),
        Text(
            'Grundbuchgebühren: ${housePriceOutput!.landRegistryFees.toStringAsFixed(0)} €'),
        Text(
            'Maklerprovision: ${housePriceOutput!.brockerCommision.toStringAsFixed(0)} €'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zusammenfassung'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: buildSummary(),
      ),
    );
  }
}
