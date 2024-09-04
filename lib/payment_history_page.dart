import 'package:flutter/material.dart';
import 'package:immo_credit/calculations/annuität.dart';

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
      appBar: AppBar(
        title: Text('Zahlungsverlauf'),
      ),
      body: Column(
        children: [
          _buildViewToggle(),
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
