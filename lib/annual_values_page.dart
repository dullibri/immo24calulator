import 'package:flutter/material.dart';
import 'package:immo24calculator/calculations/annuität.dart';

class AnnualValuesPage extends StatelessWidget {
  final CalculationResult calculationResult;

  AnnualValuesPage({required this.calculationResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jährliche Werte'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: buildDataTable(),
        ),
      ),
    );
  }

  Widget buildDataTable() {
    final annualPayments = groupPaymentsByYear(calculationResult.payments);

    return DataTable(
      columns: [
        DataColumn(label: Text('Jahr')),
        DataColumn(label: Text('Restschuld')),
        DataColumn(label: Text('Tilgung')),
        DataColumn(label: Text('Zinsen')),
        DataColumn(label: Text('Sonderzahlung')),
        DataColumn(label: Text('Verbleibende Sonderzahlung')),
        DataColumn(label: Text('Zinsvorteil')),
        DataColumn(label: Text('Abschreibung')),
      ],
      rows: annualPayments.map((payment) {
        return DataRow(cells: [
          DataCell(Text(payment.month.toString())),
          DataCell(Text(payment.remainingBalance.toStringAsFixed(2))),
          DataCell(Text(payment.principalPayment.toStringAsFixed(2))),
          DataCell(Text(payment.interestPayment.toStringAsFixed(2))),
          DataCell(Text(payment.specialPayment.toStringAsFixed(2))),
          DataCell(Text(payment.remainingSpecialPayment.toStringAsFixed(2))),
          DataCell(Text(payment.interestRebate.toStringAsFixed(2))),
          DataCell(Text(payment.depreciation.toStringAsFixed(2))),
        ]);
      }).toList(),
    );
  }
}
