import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/annuit%C3%A4t.dart';
import 'package:provider/provider.dart';

class ValuesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MortgageCalculatorProvider>(context);

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
              (provider.notaryFeesRate * 100).toString(),
              (value) => handleTextFieldChange(context, value,
                  (newValue) => provider.updateNotaryFeesRate(newValue / 100)),
              true,
            ),
            buildInputField(
              context,
              'Grundbuchgebührenrate (%)',
              (provider.landRegistryFeesRate * 100).toString(),
              (value) => handleTextFieldChange(
                  context,
                  value,
                  (newValue) =>
                      provider.updateLandRegistryFeesRate(newValue / 100)),
              true,
            ),
            buildInputField(
              context,
              'Maklerprovisionrate (%)',
              (provider.brokerCommissionRate * 100).toString(),
              (value) => handleTextFieldChange(
                  context,
                  value,
                  (newValue) =>
                      provider.updateBrokerCommissionRate(newValue / 100)),
              true,
            ),
            buildInputField(
              context,
              'Max. Sonderzahlungsprozentsatz (%)',
              provider.maxSpecialPaymentPercent.toString(),
              (value) => handleTextFieldChange(
                  context, value, provider.updateMaxSpecialPaymentPercent),
              true,
            ),
            buildInputField(
              context,
              'Mietanteil',
              provider.rentalShare.toString(),
              (value) => handleTextFieldChange(
                  context, value, provider.updateRentalShare),
              false,
            ),
            buildInputField(
              context,
              'Spitzensteuersatz',
              provider.topTaxRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, provider.updateTopTaxRate),
              false,
            ),
            buildInputField(
              context,
              'Jährliche Abschreibung',
              provider.annualDepreciationRate.toString(),
              (value) => handleTextFieldChange(
                  context, value, provider.updateAnnualDepreciationRate),
              false,
            ),
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
