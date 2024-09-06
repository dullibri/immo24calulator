import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/house.dart';
import 'package:immo24calculator/widgets/german_currency_converter.dart';
import 'package:immo24calculator/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/calculations/annuität.dart';

class ValuesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Voreingestellte Rahmenwerte:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              CustomInputField(
                label: 'Notargebührenrate',
                suffix: '%',
                initialValue: mortgage.notaryFeesRate,
                onChanged: (value) => mortgage.updateNotaryFeesRate(value),
                isPercentage: true,
                minValue: 0,
                maxValue: 0.05,
                tooltip: 'Prozentsatz der Notargebühren',
              ),
              CustomInputField(
                label: 'Grundbuchgebührenrate',
                suffix: '%',
                initialValue: mortgage.landRegistryFeesRate,
                onChanged: (value) =>
                    mortgage.updateLandRegistryFeesRate(value),
                isPercentage: true,
                minValue: 0,
                maxValue: 0.3,
                tooltip: 'Prozentsatz der Grundbuchgebühren',
              ),
              CustomInputField(
                label: 'Maklerprovisionrate',
                suffix: '%',
                initialValue: mortgage.brokerCommissionRate,
                onChanged: (value) =>
                    mortgage.updateBrokerCommissionRate(value),
                isPercentage: true,
                minValue: 0,
                maxValue: 0.3,
                tooltip: 'Prozentsatz der Maklerprovision',
              ),
              CustomInputField(
                label: 'Max. Sonderzahlungsprozentsatz',
                suffix: '%',
                initialValue: mortgage.maxSpecialPaymentPercent,
                onChanged: (value) =>
                    mortgage.updateMaxSpecialPaymentPercent(value),
                isPercentage: true,
                minValue: 0,
                maxValue: 0.5,
                tooltip: 'Maximaler Prozentsatz für jährliche Sondertilgungen',
              ),
              CustomInputField(
                label: 'Mietanteil',
                suffix: '%',
                initialValue: mortgage.rentalShare,
                onChanged: (value) => mortgage.updateRentalShare(value),
                isPercentage: true,
                minValue: 0,
                maxValue: 1,
                tooltip: 'Anteil der vermieteten Fläche',
              ),
              CustomInputField(
                label: 'Spitzensteuersatz',
                suffix: '%',
                initialValue: mortgage.topTaxRate,
                onChanged: (value) => mortgage.updateTopTaxRate(value),
                isPercentage: true,
                minValue: 0,
                maxValue: 0.45,
                tooltip: 'Ihr persönlicher Spitzensteuersatz',
              ),
              CustomInputField(
                label: 'Jährliche Abschreibung',
                suffix: '%',
                initialValue: mortgage.annualDepreciationRate,
                onChanged: (value) =>
                    mortgage.updateAnnualDepreciationRate(value),
                isPercentage: true,
                minValue: 0,
                maxValue: 0.03,
                tooltip: 'Jährliche Abschreibungsrate für die Immobilie',
              ),
              CustomInputField(
                label: 'Quadratmeter',
                suffix: 'm²',
                initialValue: mortgage.squareMeters,
                onChanged: (value) => mortgage.updateSquareMeters(value),
                decimalPlaces: 1,
                minValue: 0,
                maxValue: 1000,
                tooltip: 'Gesamte Wohnfläche der Immobilie',
              ),
              CustomInputField(
                label: 'Vermietete Quadratmeter',
                suffix: 'm²',
                initialValue: mortgage.letSquareMeters,
                onChanged: (value) => mortgage.updateLetSquareMeters(value),
                decimalPlaces: 1,
                minValue: 0,
                maxValue: mortgage.squareMeters,
                tooltip: 'Vermietete Wohnfläche der Immobilie',
              ),
            ],
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
    );
  }
}
