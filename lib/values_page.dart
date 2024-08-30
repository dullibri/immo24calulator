import 'package:flutter/material.dart';

class ValuesPage extends StatefulWidget {
  @override
  _ValuesPageState createState() => _ValuesPageState();
}

class _ValuesPageState extends State<ValuesPage> {
  double notaryFeesRate = 0.015;
  double landRegistryFeesRate = 0.005;
  double brokerCommissionRate = 0.035;
  double maxSpecialPaymentPercent = 5;
  double rentalShare = 580000 / 544000;
  double topTaxRate = 0.42;
  double annualDepreciationRate = 0.03;

  void handleTextFieldChange(String value, Function(double) updateFunction) {
    if (double.tryParse(value) != null) {
      updateFunction(double.parse(value));
    }
  }

  Widget buildInputField(String label, String initialValue,
      Function(String)? onChanged, bool positiveOnly) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: initialValue,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged != null
          ? (value) {
              if (positiveOnly &&
                  double.tryParse(value) != null &&
                  double.parse(value) < 0) {
                // Negative Eingabe verhindern
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

  @override
  Widget build(BuildContext context) {
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
              'Notargebührenrate (%)',
              (notaryFeesRate * 100).toString(),
              (value) => handleTextFieldChange(value, (newValue) {
                setState(() {
                  notaryFeesRate = newValue / 100;
                });
              }),
              true,
            ),
            buildInputField(
              'Grundbuchgebührenrate (%)',
              (landRegistryFeesRate * 100).toString(),
              (value) => handleTextFieldChange(value, (newValue) {
                setState(() {
                  landRegistryFeesRate = newValue / 100;
                });
              }),
              true,
            ),
            buildInputField(
              'Maklerprovisionrate (%)',
              (brokerCommissionRate * 100).toString(),
              (value) => handleTextFieldChange(value, (newValue) {
                setState(() {
                  brokerCommissionRate = newValue / 100;
                });
              }),
              true,
            ),
            buildInputField(
              'Max. Sonderzahlungsprozentsatz (%)',
              maxSpecialPaymentPercent.toString(),
              (value) => handleTextFieldChange(value, (newValue) {
                setState(() {
                  maxSpecialPaymentPercent = newValue;
                });
              }),
              true,
            ),
            buildInputField(
              'Mietanteil',
              rentalShare.toString(),
              (value) => handleTextFieldChange(value, (newValue) {
                setState(() {
                  rentalShare = newValue;
                });
              }),
              false,
            ),
            buildInputField(
              'Spitzensteuersatz',
              topTaxRate.toString(),
              (value) => handleTextFieldChange(value, (newValue) {
                setState(() {
                  topTaxRate = newValue;
                });
              }),
              false,
            ),
            buildInputField(
              'Jährliche Abschreibung',
              annualDepreciationRate.toString(),
              (value) => handleTextFieldChange(value, (newValue) {
                setState(() {
                  annualDepreciationRate = newValue;
                });
              }),
              false,
            ),
          ],
        ),
      ),
    );
  }
}
