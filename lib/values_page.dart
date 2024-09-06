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
                onSubmitted: (value) {
                  mortgage.updateNotaryFeesRate(value / 100);
                  _showUpdateNotification(context);
                },
                isPercentage: true,
                minValue: 0,
                maxValue: 0.05,
                tooltip: 'Prozentsatz der Notargebühren',
              ),
              CustomInputField(
                label: 'Grundbuchgebührenrate',
                suffix: '%',
                initialValue: mortgage.landRegistryFeesRate,
                onSubmitted: (value) {
                  mortgage.updateLandRegistryFeesRate(value / 100);
                  _showUpdateNotification(context);
                },
                isPercentage: true,
                minValue: 0,
                maxValue: 0.3,
                tooltip: 'Prozentsatz der Grundbuchgebühren',
              ),
              CustomInputField(
                label: 'Maklerprovisionrate',
                suffix: '%',
                initialValue: mortgage.brokerCommissionRate,
                onSubmitted: (value) {
                  mortgage.updateBrokerCommissionRate(value / 100);
                  _showUpdateNotification(context);
                },
                isPercentage: true,
                minValue: 0,
                maxValue: 0.30,
                tooltip: 'Prozentsatz der Maklerprovision',
              ),
              CustomInputField(
                label: 'Max. Sonderzahlungsprozentsatz',
                suffix: '%',
                initialValue: mortgage.maxSpecialPaymentPercent,
                onSubmitted: (value) {
                  mortgage.updateMaxSpecialPaymentPercent(value / 100);
                  _showUpdateNotification(context);
                },
                isPercentage: true,
                minValue: 0,
                maxValue: 0.05,
                tooltip: 'Maximaler Prozentsatz für jährliche Sondertilgungen',
              ),
              CustomInputField(
                label: 'Mietanteil',
                suffix: '%',
                initialValue: mortgage.rentalShare,
                onSubmitted: (value) {
                  mortgage.updateRentalShare(value / 100);
                  _showUpdateNotification(context);
                },
                isPercentage: true,
                minValue: 0,
                maxValue: 1,
                tooltip: 'Anteil der vermieteten Fläche',
              ),
              CustomInputField(
                label: 'Spitzensteuersatz',
                suffix: '%',
                initialValue: mortgage.topTaxRate,
                onSubmitted: (value) {
                  mortgage.updateTopTaxRate(value / 100);
                  _showUpdateNotification(context);
                },
                isPercentage: true,
                minValue: 0,
                maxValue: 0.45,
                tooltip: 'Ihr persönlicher Spitzensteuersatz',
              ),
              CustomInputField(
                label: 'Jährliche Abschreibung',
                suffix: '%',
                initialValue: mortgage.annualDepreciationRate,
                onSubmitted: (value) {
                  mortgage.updateAnnualDepreciationRate(value / 100);
                  _showUpdateNotification(context);
                },
                isPercentage: true,
                minValue: 0,
                maxValue: 0.03,
                tooltip: 'Jährliche Abschreibungsrate für die Immobilie',
              ),
              CustomInputField(
                label: 'Quadratmeter',
                suffix: 'm²',
                initialValue: mortgage.squareMeters,
                onSubmitted: (value) {
                  mortgage.updateSquareMeters(value);
                  _showUpdateNotification(context);
                },
                decimalPlaces: 1,
                minValue: 0,
                maxValue: 1000,
                tooltip: 'Gesamte Wohnfläche der Immobilie',
              ),
              CustomInputField(
                label: 'Vermietete Quadratmeter',
                suffix: 'm²',
                initialValue: mortgage.letSquareMeters,
                onSubmitted: (value) {
                  mortgage.updateLetSquareMeters(value);
                  _showUpdateNotification(context);
                },
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

  void _showUpdateNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rahmenwerte wurden aktualisiert'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
