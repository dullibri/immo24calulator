import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/services/firestore_service.dart';
import 'summary_page.dart';

class FactorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mortgage = Provider.of<Mortgage>(context);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return AppScaffold(
      title: 'Hauptfaktoren',
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
            const Text('Hauptfaktoren:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                CustomInputField(
                  label: 'Kaufpreis',
                  suffix: '€',
                  initialValue: mortgage.housePrice,
                  onChanged: (value) => mortgage.updateHousePrice(value),
                  decimalPlaces: 0,
                  minValue: 10000,
                  maxValue: 10000000,
                  tooltip: 'Der Gesamtkaufpreis der Immobilie',
                ),
                // ... (rest of the CustomInputFields remain the same)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
