import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/house.dart';
import 'package:provider/provider.dart';
import 'package:immo_credit/calculations/annuität.dart';
import 'house_price_provider.dart';

class ValuesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgageProvider = Provider.of<MortgageCalculatorProvider>(context);
    final housePriceProvider = Provider.of<HousePriceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rahmenwerte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Voreingestellte Rahmenwerte:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildInputField(
              context,
              'Notargebührenrate (%)',
              (mortgageProvider.notaryFeesRate * 100).toString(),
              (value) {
                handleTextFieldChange(context, value, (newValue) {
                  mortgageProvider.updateNotaryFeesRate(newValue / 100);
                  housePriceProvider.updateHousePriceInput(
                      notaryFeesRate: newValue / 100);
                });
              },
              true,
            ),
            buildInputField(
              context,
              'Grundbuchgebührenrate (%)',
              (mortgageProvider.landRegistryFeesRate * 100).toString(),
              (value) {
                handleTextFieldChange(context, value, (newValue) {
                  mortgageProvider.updateLandRegistryFeesRate(newValue / 100);
                  housePriceProvider.updateHousePriceInput(
                      landRegistryFeesRate: newValue / 100);
                });
              },
              true,
            ),
            buildInputField(
              context,
              'Maklerprovisionrate (%)',
              (mortgageProvider.brokerCommissionRate * 100).toString(),
              (value) {
                handleTextFieldChange(context, value, (newValue) {
                  mortgageProvider.updateBrokerCommissionRate(newValue / 100);
                  housePriceProvider.updateHousePriceInput(
                      brokerCommissionRate: newValue / 100);
                });
              },
              true,
            ),
            buildInputField(
              context,
              'Max. Sonderzahlungsprozentsatz (%)',
              mortgageProvider.maxSpecialPaymentPercent.toString(),
              (value) => handleTextFieldChange(context, value,
                  mortgageProvider.updateMaxSpecialPaymentPercent),
              true,
            ),
            buildInputField(
              context,
              'Mietanteil',
              mortgageProvider.rentalShare.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updateRentalShare),
              false,
            ),
            buildInputField(
              context,
              'Spitzensteuersatz',
              mortgageProvider.topTaxRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgageProvider.updateTopTaxRate),
              false,
            ),
            buildInputField(
              context,
              'Jährliche Abschreibung',
              mortgageProvider.annualDepreciationRate.toString(),
              (value) => handleTextFieldChange(context, value,
                  mortgageProvider.updateAnnualDepreciationRate),
              false,
            ),
            buildInputField(
              context,
              'Quadratmeter',
              housePriceProvider.housePriceInput.squareMeters.toString(),
              (value) => handleTextFieldChange(
                  context,
                  value,
                  (newValue) => housePriceProvider.updateHousePriceInput(
                      squareMeters: newValue)),
              true,
            ),
            buildInputField(
              context,
              'Vermietete Quadratmeter',
              housePriceProvider.housePriceInput.letSquareMeters.toString(),
              (value) => handleTextFieldChange(
                  context,
                  value,
                  (newValue) => housePriceProvider.updateHousePriceInput(
                      letSquareMeters: newValue)),
              true,
            ),
            buildInputField(
              context,
              'Hauspreis',
              housePriceProvider.housePriceInput.housePrice.toString(),
              (value) => handleTextFieldChange(
                  context,
                  value,
                  (newValue) => housePriceProvider.updateHousePriceInput(
                      housePrice: newValue)),
              true,
            ),
            SizedBox(height: 20),
            Text(
                'Gesamthauspreis: ${housePriceProvider.housePriceOutput?.totalHousePrice.toStringAsFixed(2) ?? 'N/A'}'),
            Text(
                'Notargebühren: ${housePriceProvider.housePriceOutput?.notaryFees.toStringAsFixed(2) ?? 'N/A'}'),
            Text(
                'Grundbuchgebühren: ${housePriceProvider.housePriceOutput?.landRegistryFees.toStringAsFixed(2) ?? 'N/A'}'),
            Text(
                'Maklerprovision: ${housePriceProvider.housePriceOutput?.brokerCommission.toStringAsFixed(2) ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(BuildContext context, String label,
      String initialValue, Function(String)? onChanged, bool positiveOnly) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: initialValue,
      ),
      keyboardType: TextInputType.number,
      initialValue: initialValue,
      onChanged: onChanged != null
          ? (value) {
              if (positiveOnly &&
                  double.tryParse(value) != null &&
                  double.parse(value) < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Wert darf nicht negativ sein')),
                );
              } else {
                onChanged(value);
              }
            }
          : null,
    );
  }

  void handleTextFieldChange(
      BuildContext context, String value, Function(double) updateFunction) {
    if (double.tryParse(value) != null) {
      updateFunction(double.parse(value));
    }
  }
}
