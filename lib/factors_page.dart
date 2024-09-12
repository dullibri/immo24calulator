import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/firestore_service.dart';
import 'package:immo24calculator/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';

class FactorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Mortgage>(
      builder: (context, mortgage, child) {
        print('Rebuilding FactorsPage with housePrice: ${mortgage.housePrice}');
        return _buildContent(context, mortgage);
      },
    );
  }

  Widget _buildContent(BuildContext context, Mortgage mortgage) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    double calculateMinimumMonthlyPayment(Mortgage mortgage) {
      return (mortgage.annualInterestRate * mortgage.principal / 12) + 1;
    }

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
                  value: null,
                  items: mortgages.map((m) {
                    return DropdownMenuItem<Mortgage>(
                      value: m,
                      child: Text('Hypothek ${m.housePrice}€'),
                    );
                  }).toList(),
                  onChanged: (selectedMortgage) {
                    if (selectedMortgage != null) {
                      print(
                          'Selected mortgage with housePrice: ${selectedMortgage.housePrice}');
                      Provider.of<Mortgage>(context, listen: false)
                          .updateFromMortgage(selectedMortgage);
                      print(
                          'After update, current mortgage housePrice: ${mortgage.housePrice}');
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
                CustomInputField(
                  label: 'Quadratmeter',
                  suffix: 'm²',
                  initialValue: mortgage.squareMeters,
                  onChanged: (value) => mortgage.updateSquareMeters(value),
                  decimalPlaces: 1,
                  minValue: 20,
                  maxValue: 1000,
                  tooltip: 'Die Wohnfläche der Immobilie',
                ),
                CustomInputField(
                  label: 'Eigenkapital',
                  suffix: '€',
                  initialValue: mortgage.equity,
                  onChanged: (value) => mortgage.updateEquity(value),
                  decimalPlaces: 0,
                  minValue: 0,
                  maxValue: mortgage.housePrice,
                  tooltip: 'Das eingesetzte Eigenkapital',
                ),
                CustomInputField(
                  label: 'Monatliche Rate',
                  suffix: '€',
                  initialValue: mortgage.monthlyPayment,
                  onChanged: (value) => mortgage.updateMonthlyPayment(value),
                  decimalPlaces: 0,
                  minValue: calculateMinimumMonthlyPayment(mortgage),
                  maxValue: mortgage.principal / 12,
                  tooltip: 'Die monatliche Kreditrate',
                ),
                CustomInputField(
                  label: 'Jährlicher Zinssatz',
                  suffix: '%',
                  initialValue: mortgage.annualInterestRate,
                  onChanged: (value) =>
                      mortgage.updateAnnualInterestRate(value),
                  isPercentage: true,
                  minValue: 0.001,
                  maxValue: 0.20,
                  tooltip: 'Der jährliche Zinssatz des Kredits',
                ),
                CustomInputField(
                  label: 'Monatliche Sonderzahlung',
                  suffix: '€',
                  initialValue: mortgage.monthlySpecialPayment,
                  onChanged: (value) =>
                      mortgage.updateMonthlySpecialPayment(value),
                  decimalPlaces: 0,
                  minValue: 0,
                  maxValue: 5000,
                  tooltip: 'Zusätzliche monatliche Sondertilgung',
                ),
                CustomInputField(
                  label: 'Max. Sonderzahlung',
                  suffix: '%',
                  initialValue: mortgage.maxSpecialPaymentPercent,
                  onChanged: (value) =>
                      mortgage.updateMaxSpecialPaymentPercent(value),
                  isPercentage: true,
                  minValue: 0,
                  maxValue: 0.2,
                  tooltip:
                      'Maximaler Prozentsatz für jährliche Sondertilgungen',
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
                  maxValue: 0.05,
                  tooltip: 'Jährliche Abschreibungsrate für die Immobilie',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
