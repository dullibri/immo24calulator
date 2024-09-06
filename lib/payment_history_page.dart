import 'package:flutter/material.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/german_currency_converter.dart';

class PaymentHistoryPage extends StatefulWidget {
  final CalculationResult calculationResult;

  PaymentHistoryPage({required this.calculationResult});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  bool _showAnnualView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildViewToggle(),
          _buildSummary(widget.calculationResult),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _showAnnualView
                    ? _buildDataTable(
                        groupPaymentsByYear(widget.calculationResult.payments))
                    : _buildDataTable(widget.calculationResult.payments),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Monatliche Ansicht'),
          Switch(
            value: _showAnnualView,
            onChanged: (value) {
              setState(() {
                _showAnnualView = value;
              });
            },
          ),
          Text('Jährliche Ansicht'),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Payment> payments) {
    return DataTable(
      columns: [
        DataColumn(label: Text(_showAnnualView ? 'Jahr' : 'Monat')),
        DataColumn(label: Text('Restschuld')),
        DataColumn(label: Text('Tilgung')),
        DataColumn(label: Text('Zinsen')),
        DataColumn(label: Text('Sonderzahlung')),
        DataColumn(label: Text('Verbleibende Sonderzahlung')),
        DataColumn(label: Text('Zinsvorteil')),
        DataColumn(label: Text('Abschreibung')),
      ],
      rows: payments.map((payment) {
        return DataRow(cells: [
          DataCell(Text(payment.month.toString())),
          DataCell(
              Text(GermanCurrencyFormatter.format(payment.remainingBalance))),
          DataCell(
              Text(GermanCurrencyFormatter.format(payment.principalPayment))),
          DataCell(
              Text(GermanCurrencyFormatter.format(payment.interestPayment))),
          DataCell(
              Text(GermanCurrencyFormatter.format(payment.specialPayment))),
          DataCell(Text(
              GermanCurrencyFormatter.format(payment.remainingSpecialPayment))),
          DataCell(
              Text(GermanCurrencyFormatter.format(payment.interestRebate))),
          DataCell(Text(GermanCurrencyFormatter.format(payment.depreciation))),
        ]);
      }).toList(),
    );
  }

  Widget _buildSummary(CalculationResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gesamtzusammenfassung:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildSummaryRow('Tilgung', result.totalPrincipalPayment),
            _buildSummaryRow('Zinszahlungen', result.totalInterestPayment),
            _buildSummaryRow('Sonderzahlungen', result.totalSpecialPayment),
            _buildSummaryRow('Zinsvorteil', result.totalInterestRebate),
            _buildSummaryRow('Abschreibung', result.totalDepreciation),
            _buildSummaryRow('Summe aller Zahlungen', result.totalSum),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double? value) {
    return Text(
        '$label: ${GermanCurrencyFormatter.format(value as num) ?? 'N/A'}');
  }
}
