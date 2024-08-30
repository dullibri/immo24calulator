import 'package:flutter/material.dart';
import 'calculations/annuität.dart';

class AnnualValuesPage extends StatelessWidget {
  final CalculationResult? calculationResult;

  AnnualValuesPage({this.calculationResult});

  Widget buildDataTable() {
    if (calculationResult == null) {
      return const SizedBox();
    }

    // Beispiel für Tabelleninhalt
    final payments = calculationResult!.payments;

    return DataTable(
      columns: [
        DataColumn(label: Text('Periode')),
        DataColumn(label: Text('Restschuld')),
        DataColumn(label: Text('Tilgung')),
        DataColumn(label: Text('Zinsen')),
        DataColumn(label: Text('Sonderzahlung')),
        DataColumn(label: Text('Verbleibende Sonderzahlung')),
        DataColumn(label: Text('Zinsvorteil')),
        DataColumn(label: Text('Abschreibung')),
      ],
      rows: payments.map((payment) {
        final periodLabel = '${payment.month ~/ 12 + 1}';

        return DataRow(cells: [
          DataCell(Text(periodLabel)),
          DataCell(Text(payment.remainingBalance.toStringAsFixed(0))),
          DataCell(Text(payment.principalPayment.toStringAsFixed(0))),
          DataCell(Text(payment.interestPayment.toStringAsFixed(0))),
          DataCell(Text(payment.specialPayment.toStringAsFixed(0))),
          DataCell(Text(payment.remainingSpecialPayment.toStringAsFixed(0))),
          DataCell(Text(payment.interestRebate.toStringAsFixed(0))),
          DataCell(Text(payment.depreciation.toStringAsFixed(0))),
        ]);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jährliche Werte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: buildDataTable(),
      ),
    );
  }
}
