// Import the necessary Flutter package
import 'package:flutter/material.dart';

// Define a stateful widget for the values page
class ValuesPage extends StatefulWidget {
  @override
  _ValuesPageState createState() => _ValuesPageState();
}

// Define the state class for the values page
class _ValuesPageState extends State<ValuesPage> {
  // Initialize variables to store the rates and percentages
  double notaryFeesRate = 0.015; // Notary fees rate
  double landRegistryFeesRate = 0.005; // Land registry fees rate
  double brokerCommissionRate = 0.035; // Broker commission rate
  double maxSpecialPaymentPercent = 5; // Maximum special payment percentage
  double rentalShare = 580000 / 544000; // Rental share
  double topTaxRate = 0.42; // Top tax rate
  double annualDepreciationRate = 0.03; // Annual depreciation rate

  // Function to handle text field changes
  void handleTextFieldChange(String value, Function(double) updateFunction) {
    // Check if the input value can be parsed to a double
    if (double.tryParse(value) != null) {
      // Update the corresponding rate or percentage
      updateFunction(double.parse(value));
    }
  }

  // Function to build an input field
  Widget buildInputField(String label, String initialValue,
      Function(String)? onChanged, bool positiveOnly) {
    // Return a text form field with the specified label and initial value
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: initialValue,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged != null
          ? (value) {
              // Check if the input value is negative and show a snackbar if necessary
              if (positiveOnly &&
                  double.tryParse(value) != null &&
                  double.parse(value) < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Wert darf nicht negativ sein')),
                );
              } else {
                // Call the onChanged function with the input value
                onChanged(value);
              }
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Return a scaffold with an app bar and a scrollable body
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rahmenwerte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display a header text
            const Text('Voreingestellte Rahmenwerte:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Build input fields for each rate and percentage
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
