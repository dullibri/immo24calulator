import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/house.dart';
import 'package:immo24calculator/firestore_service.dart';
import 'package:immo24calculator/widgets/german_currency_converter.dart';
import 'package:immo24calculator/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/calculations/annuität.dart';

class ValuesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return AppScaffold(
      title: 'Rahmenwerte',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              child: Text('Hypothek speichern'),
              onPressed: () async {
                try {
                  await firestoreService.saveMortgage(mortgage);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hypothek erfolgreich gespeichert')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fehler beim Speichern: $e')),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            StreamBuilder<List<Mortgage>>(
              stream: firestoreService.getMortgages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final mortgages = snapshot.data!;
                return DropdownButton<Mortgage>(
                  hint: Text('Gespeicherte Hypotheken'),
                  items: mortgages.map((m) {
                    return DropdownMenuItem<Mortgage>(
                      value: m,
                      child: Text('Hypothek ${m.housePrice}€'),
                    );
                  }).toList(),
                  onChanged: (selectedMortgage) {
                    if (selectedMortgage != null) {
                      Provider.of<Mortgage>(context, listen: false)
                          .updateFromMortgage(selectedMortgage);
                    }
                  },
                );
              },
            ),
            SizedBox(height: 16),
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
                // ... (rest of the CustomInputFields remain the same)
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
      ),
    );
  }
}
