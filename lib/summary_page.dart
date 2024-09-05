import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/house.dart';
import 'package:provider/provider.dart';
import 'calculations/annuität.dart';

class SummaryPage extends StatelessWidget {
  final CalculationResult calculationResult;

  SummaryPage({required this.calculationResult});

  @override
  Widget build(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context, listen: false);

    final housePriceOutput = mortgage.housePriceOutput;
    final principal = mortgage.principal;

    return AppScaffold(
      title: 'Zusammenfassung',
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
            'Gesamtkosten: ${housePriceOutput.totalHousePrice.toStringAsFixed(2)} €'),
        Text('Kreditsumme: ${principal.toStringAsFixed(2)} €'),
        Text(
            'Dauer bis zur Rückzahlung: ${calculationResult.totalMonths} Monate'),
        Text(
            'Gesamtsumme über alle Zahlungen: ${calculationResult.totalSum.toStringAsFixed(2)} €'),
        const SizedBox(height: 16.0),
        const Text('Zusätzliche Kosten:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
            'Notargebühren: ${housePriceOutput.notaryFees.toStringAsFixed(2)} €'),
        Text(
            'Grundbuchgebühren: ${housePriceOutput.landRegistryFees.toStringAsFixed(2)} €'),
        Text(
            'Maklerprovision: ${housePriceOutput.brokerCommission.toStringAsFixed(2)} €'),
        const SizedBox(height: 16.0),
        const Text('Zahlungsdetails:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
            'Monatliche Rate: ${calculationResult.payments.isNotEmpty ? calculationResult.payments[0].principalPayment.toStringAsFixed(2) : "N/A"} €'),
        Text(
            'Gesamte Zinszahlungen: ${(calculationResult.totalSum - principal).toStringAsFixed(2)} €'),
        Text(
            'Steuervorteil: ${calculationResult.totalTaxRepayment.toStringAsFixed(2)} €'),
      ],
    );
  }
}
