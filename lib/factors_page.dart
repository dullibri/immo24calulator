import 'package:flutter/material.dart';
import 'package:immo24calculator/app_scaffold.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/firestore_service.dart';
import 'package:immo24calculator/widgets/custom_input_field.dart';
import 'package:immo24calculator/widgets/mortgage_dropdown.dart';
import 'package:immo24calculator/widgets/german_currency_converter.dart';
import 'package:provider/provider.dart';

class FactorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Mortgage>(
      builder: (context, mortgage, child) {
        return _buildContent(context, mortgage);
      },
    );
  }

  Widget _buildContent(BuildContext context, Mortgage mortgage) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return AppScaffold(
      title: 'Hypothekenfaktoren',
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
            MortgageDropdown(),
            SizedBox(height: 16),
            Text('Aktuelle Hypothek: ${mortgage.mortgageName}'),
            SizedBox(height: 24),

            // Hauptfaktoren
            _buildSectionTitle('Hauptfaktoren'),
            _buildFactorsGrid(context, mortgage,
                factorsList: _buildMainFactors(context, mortgage)),
            SizedBox(height: 24),

            // Rahmenfaktoren
            _buildSectionTitle('Rahmenfaktoren'),
            _buildFactorsGrid(context, mortgage,
                factorsList: _buildFrameFactors(context, mortgage)),
            SizedBox(height: 24),

            _buildSectionTitle('Wirtschaftliche Nutzung'),
            _buildFactorsGrid(context, mortgage,
                factorsList: _buildCommercialFactors(context, mortgage)),

            SizedBox(height: 20),
            _buildSummary(mortgage),

            // IRR Berechnung und Anzeige
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('IRR berechnen'),
              onPressed: () {
                mortgage.calculateIRR();
              },
            ),
            SizedBox(height: 10),
            Text(
              'Interne Rendite (IRR): ${(mortgage.irrValue * 100).toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFactorsGrid(BuildContext context, Mortgage mortgage,
      {required List<Widget> factorsList}) {
    List<Widget> factors = factorsList;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: factors,
    );
  }

  List<Widget> _buildMainFactors(BuildContext context, Mortgage mortgage) {
    return [
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
        onChanged: (value) => mortgage.updateAnnualInterestRate(value),
        isPercentage: true,
        minValue: 0.001,
        maxValue: 0.20,
        tooltip: 'Der jährliche Zinssatz des Kredits',
      ),
      CustomInputField(
        label: 'Monatliche Sonderzahlung',
        suffix: '€',
        initialValue: mortgage.monthlySpecialPayment,
        onChanged: (value) => mortgage.updateMonthlySpecialPayment(value),
        decimalPlaces: 0,
        minValue: 0,
        maxValue: 5000,
        tooltip: 'Zusätzliche monatliche Sondertilgung',
      ),
      CustomInputField(
        label: 'Max. Sonderzahlung',
        suffix: '%',
        initialValue: mortgage.maxSpecialPaymentPercent,
        onChanged: (value) => mortgage.updateMaxSpecialPaymentPercent(value),
        isPercentage: true,
        minValue: 0,
        maxValue: 0.2,
        tooltip: 'Maximaler Prozentsatz für jährliche Sondertilgungen',
      ),
      CustomInputField(
        label: 'Monatliche Mieteinsparung',
        suffix: '€',
        initialValue: mortgage.monthlyRentSaved,
        onChanged: (value) => mortgage.updateMonthlyRentSaved(value),
        decimalPlaces: 0,
        minValue: 0,
        maxValue: 10000,
        tooltip: 'Monatliche Miete, die durch Eigennutzung gespart wird',
      ),
      CustomInputField(
        label: 'Jährliche Steigerung Mieteinsparung',
        suffix: '%',
        initialValue: mortgage.annualRentSavedIncrease,
        onChanged: (value) => mortgage.updateAnnualRentSavedIncrease(value),
        isPercentage: true,
        minValue: 0,
        maxValue: 0.10,
        tooltip: 'Jährliche prozentuale Steigerung der Mieteinsparung',
      ),
    ];
  }

  List<Widget> _buildFrameFactors(BuildContext context, Mortgage mortgage) {
    return [
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
        onChanged: (value) => mortgage.updateLandRegistryFeesRate(value),
        isPercentage: true,
        minValue: 0,
        maxValue: 0.3,
        tooltip: 'Prozentsatz der Grundbuchgebühren',
      ),
      CustomInputField(
        label: 'Maklerprovisionrate',
        suffix: '%',
        initialValue: mortgage.brokerCommissionRate,
        onChanged: (value) => mortgage.updateBrokerCommissionRate(value),
        isPercentage: true,
        minValue: 0,
        maxValue: 0.3,
        tooltip: 'Prozentsatz der Maklerprovision',
      ),
      CustomInputField(
        label: 'Max. Sonderzahlungsprozentsatz',
        suffix: '%',
        initialValue: mortgage.maxSpecialPaymentPercent,
        onChanged: (value) => mortgage.updateMaxSpecialPaymentPercent(value),
        isPercentage: true,
        minValue: 0,
        maxValue: 0.5,
        tooltip: 'Maximaler Prozentsatz für jährliche Sondertilgungen',
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

      // Fügen Sie hier die restlichen Rahmenfaktoren hinzu
    ];
  }

  List<Widget> _buildCommercialFactors(
      BuildContext context, Mortgage mortgage) {
    return [
      CustomInputField(
        label: 'Jährliche Abschreibung',
        suffix: '%',
        initialValue: mortgage.annualDepreciationRate,
        onChanged: (value) => mortgage.updateAnnualDepreciationRate(value),
        isPercentage: true,
        minValue: 0,
        maxValue: 0.05,
        tooltip: 'Jährliche Abschreibungsrate für die Immobilie',
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
        label: 'Monatliche Mieteinnahmen',
        suffix: '€',
        initialValue: mortgage.monthlyRentalIncome,
        onChanged: (value) => mortgage.updateMonthlyRentalIncome(value),
        decimalPlaces: 0,
        minValue: 0,
        maxValue: 10000,
        tooltip: 'Erwartete monatliche Mieteinnahmen bei Vermietung',
      ),
      CustomInputField(
        label: 'Jährliche Steigerung Mieteinnahmen',
        suffix: '%',
        initialValue: mortgage.annualRentalIncomeIncrease,
        onChanged: (value) => mortgage.updateAnnualRentalIncomeIncrease(value),
        isPercentage: true,
        minValue: 0,
        maxValue: 0.10,
        tooltip: 'Jährliche prozentuale Steigerung der Mieteinnahmen',
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
      CustomInputField(
        label: 'Sonstige geschäftlich genutzte Fläche',
        suffix: 'm²',
        initialValue: mortgage.otherBusinessUsedArea,
        onChanged: (value) => mortgage.updateOtherBusinessUsedArea(value),
        decimalPlaces: 1,
        minValue: 0,
        maxValue: mortgage.squareMeters,
        tooltip: 'Sonstige geschäftlich genutzte Fläche der Immobilie',
      ),
    ];
  }

  Widget _buildSummary(Mortgage mortgage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Gesamthauspreis: ${GermanCurrencyFormatter.format(mortgage.housePriceOutput.totalHousePrice as num)}'),
        Text(
            'Notargebühren: ${GermanCurrencyFormatter.format(mortgage.housePriceOutput.notaryFees as num)}'),
        Text(
            'Grundbuchgebühren: ${GermanCurrencyFormatter.format(mortgage.housePriceOutput.landRegistryFees as num)}'),
        Text(
            'Maklerprovision: ${GermanCurrencyFormatter.format(mortgage.housePriceOutput.brokerCommission as num)}'),
        Text(
            'Quadratmeterpreis: ${GermanCurrencyFormatter.format(mortgage.housePrice / mortgage.squareMeters as num)}'),
      ],
    );
  }

  double calculateMinimumMonthlyPayment(Mortgage mortgage) {
    return (mortgage.annualInterestRate * mortgage.principal / 12) + 1;
  }
}
