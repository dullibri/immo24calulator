import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/house.dart';
import 'package:immo24calculator/widgets/german_currency_converter.dart';
import 'package:immo24calculator/widgets/german_currency_input.dart';
import 'package:immo24calculator/widgets/german_percentage_handler.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/calculations/annuität.dart';

class ValuesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context);

    return AppScaffold(
      title: 'Rahmenwerte',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Voreingestellte Rahmenwerte:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            GermanPercentageInput(
              label: 'Notargebührenrate',
              initialValue: mortgage.notaryFeesRate * 100,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateNotaryFeesRate(value / 100);
                }
              },
            ),
            GermanPercentageInput(
              label: 'Grundbuchgebührenrate',
              initialValue: mortgage.landRegistryFeesRate * 100,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateLandRegistryFeesRate(value / 100);
                }
              },
            ),
            GermanPercentageInput(
              label: 'Maklerprovisionrate',
              initialValue: mortgage.brokerCommissionRate * 100,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateBrokerCommissionRate(value / 100);
                }
              },
            ),
            GermanPercentageInput(
              label: 'Max. Sonderzahlungsprozentsatz',
              initialValue: mortgage.maxSpecialPaymentPercent,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateMaxSpecialPaymentPercent(value);
                }
              },
            ),
            GermanPercentageInput(
              label: 'Mietanteil',
              initialValue: mortgage.rentalShare * 100,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateRentalShare(value / 100);
                }
              },
            ),
            GermanPercentageInput(
              label: 'Spitzensteuersatz',
              initialValue: mortgage.topTaxRate * 100,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateTopTaxRate(value / 100);
                }
              },
            ),
            GermanPercentageInput(
              label: 'Jährliche Abschreibung',
              initialValue: mortgage.annualDepreciationRate * 100,
              onChanged: (value) {
                if (value != null) {
                  mortgage.updateAnnualDepreciationRate(value / 100);
                }
              },
            ),
            GermanCurrencyInput(
              label: 'Quadratmeter',
              initialValue: mortgage.squareMeters.round(),
              onChanged: (value) =>
                  mortgage.updateSquareMeters(value.toDouble()),
            ),
            GermanCurrencyInput(
              label: 'Vermietete Quadratmeter',
              initialValue: mortgage.letSquareMeters.round(),
              onChanged: (value) =>
                  mortgage.updateLetSquareMeters(value.toDouble()),
            ),
            SizedBox(height: 20),
            Text(
                'Gesamthauspreis: ${GermanCurrencyFormatter.format(mortgage.housePriceOutput.totalHousePrice as num)}'),
            Text(
                'Notargebühren: ${GermanCurrencyFormatter.format(mortgage.housePriceOutput.notaryFees as num)}'),
            Text(
                'Grundbuchgebühren: ${GermanCurrencyFormatter.format(mortgage.housePriceOutput.landRegistryFees as num)}'),
            Text(
                'Maklerprovision: ${GermanCurrencyFormatter.format(mortgage.housePriceOutput.brokerCommission as num)}'),
          ],
        ),
      ),
    );
  }
}
