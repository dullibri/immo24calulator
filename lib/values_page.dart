import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/house.dart';
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
            buildInputField(
              context,
              'Notargebührenrate (%)',
              (mortgage.notaryFeesRate * 100).toString(),
              (value) {
                handleTextFieldChange(context, value, (newValue) {
                  mortgage.updateNotaryFeesRate(newValue / 100);
                });
              },
              true,
            ),
            buildInputField(
              context,
              'Grundbuchgebührenrate (%)',
              (mortgage.landRegistryFeesRate * 100).toString(),
              (value) {
                handleTextFieldChange(context, value, (newValue) {
                  mortgage.updateLandRegistryFeesRate(newValue / 100);
                });
              },
              true,
            ),
            buildInputField(
              context,
              'Maklerprovisionrate (%)',
              (mortgage.brokerCommissionRate * 100).toString(),
              (value) {
                handleTextFieldChange(context, value, (newValue) {
                  mortgage.updateBrokerCommissionRate(newValue / 100);
                });
              },
              true,
            ),
            buildInputField(
              context,
              'Max. Sonderzahlungsprozentsatz (%)',
              mortgage.maxSpecialPaymentPercent.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgage.updateMaxSpecialPaymentPercent),
              true,
            ),
            buildInputField(
              context,
              'Mietanteil',
              mortgage.rentalShare.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgage.updateRentalShare),
              false,
            ),
            buildInputField(
              context,
              'Spitzensteuersatz',
              mortgage.topTaxRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgage.updateTopTaxRate),
              false,
            ),
            buildInputField(
              context,
              'Jährliche Abschreibung',
              mortgage.annualDepreciationRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, mortgage.updateAnnualDepreciationRate),
              false,
            ),
            buildInputField(
              context,
              'Quadratmeter',
              mortgage.squareMeters.toString(),
              (value) => handleTextFieldChange(context, value,
                  (newValue) => mortgage.updateSquareMeters(newValue)),
              true,
            ),
            buildInputField(
              context,
              'Vermietete Quadratmeter',
              mortgage.letSquareMeters.toString(),
              (value) => handleTextFieldChange(context, value,
                  (newValue) => mortgage.updateLetSquareMeters(newValue)),
              true,
            ),
            buildInputField(
              context,
              'Hauspreis',
              mortgage.housePrice.toString(),
              (value) => handleTextFieldChange(context, value,
                  (newValue) => mortgage.updateHousePrice(newValue)),
              true,
            ),
            SizedBox(height: 20),
            Text(
                'Gesamthauspreis: ${mortgage.housePriceOutput?.totalHousePrice.toStringAsFixed(2) ?? 'N/A'}'),
            Text(
                'Notargebühren: ${mortgage.housePriceOutput?.notaryFees.toStringAsFixed(2) ?? 'N/A'}'),
            Text(
                'Grundbuchgebühren: ${mortgage.housePriceOutput?.landRegistryFees.toStringAsFixed(2) ?? 'N/A'}'),
            Text(
                'Maklerprovision: ${mortgage.housePriceOutput?.brokerCommission.toStringAsFixed(2) ?? 'N/A'}'),
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
