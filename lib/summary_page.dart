import 'package:flutter/material.dart';
import 'package:immo24calculator/widgets/german_currency_converter.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/house.dart';
import 'package:immo24calculator/widgets/german_percentage_handler.dart';
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
        child: buildSummary(
            calculationResult, housePriceOutput, principal, mortgage),
      ),
    );
  }

  Widget buildSummary(CalculationResult? calculationResult,
      HousePriceOutput? housePriceOutput, double principal, Mortgage mortgage) {
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
            'Gesamtkosten: ${GermanCurrencyFormatter.format(housePriceOutput.totalHousePrice)}'),
        Text('Kreditsumme: ${GermanCurrencyFormatter.format(principal)}'),
        Text(
            'Dauer bis zur Rückzahlung: ${calculationResult.totalMonths} Monate'),
        Text(
            'Gesamtsumme über alle Zahlungen: ${GermanCurrencyFormatter.format(calculationResult.totalSum)}'),
        Text(
            'Jährlicher Zinssatz: ${GermanPercentageHandler.format(mortgage.annualInterestRate / 100)}'),
        const SizedBox(height: 16.0),
        const Text('Zusätzliche Kosten:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
            'Notargebühren: ${GermanCurrencyFormatter.format(housePriceOutput.notaryFees)}'),
        Text(
            'Grundbuchgebühren: ${GermanCurrencyFormatter.format(housePriceOutput.landRegistryFees)}'),
        Text(
            'Maklerprovision: ${GermanCurrencyFormatter.format(housePriceOutput.brokerCommission)}'),
        const SizedBox(height: 16.0),
        const Text('Zahlungsdetails:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
            'Monatliche Rate: ${calculationResult.payments.isNotEmpty ? GermanCurrencyFormatter.format(calculationResult.payments[0].principalPayment + calculationResult.payments[0].interestPayment) : "N/A"}'),
        Text(
            'Gesamte Zinszahlungen: ${GermanCurrencyFormatter.format(calculationResult.totalInterestPayment)}'),
        Text(
            'Steuervorteil: ${GermanCurrencyFormatter.format(calculationResult.totalTaxRepayment)}'),
        Text(
            'Effektiver Jahreszins: ${GermanPercentageHandler.format(calculationResult.totalInterestPayment / calculationResult.totalSum)}'),
      ],
    );
  }
}
