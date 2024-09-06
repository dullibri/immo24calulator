import 'package:flutter/material.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/german_currency_converter.dart';
import 'package:immo24calculator/app_scaffold.dart';

class PaymentHistoryPage extends StatefulWidget {
  final CalculationResult calculationResult;

  PaymentHistoryPage({required this.calculationResult});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  String _selectedView = 'monthly';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Zahlungsverlauf',
      body: Column(
        children: [
          _buildViewToggle(),
          Expanded(
            child: _buildSelectedView(),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggleButton('Monatlich', 'monthly'),
          _buildToggleButton('Jährlich', 'yearly'),
          _buildToggleButton('Gesamtzusammenfassung', 'summary'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value) {
    return ElevatedButton(
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedView == value ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        setState(() {
          _selectedView = value;
        });
      },
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedView) {
      case 'monthly':
        return _buildDataTable(widget.calculationResult.payments);
      case 'yearly':
        return _buildDataTable(
            groupPaymentsByYear(widget.calculationResult.payments));
      case 'summary':
        return _buildSummary(widget.calculationResult);
      default:
        return Container();
    }
  }

  Widget _buildDataTable(List<Payment> payments) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
                label: Text(_selectedView == 'yearly' ? 'Jahr' : 'Monat')),
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
              DataCell(Text(
                  GermanCurrencyFormatter.format(payment.remainingBalance))),
              DataCell(Text(
                  GermanCurrencyFormatter.format(payment.principalPayment))),
              DataCell(Text(
                  GermanCurrencyFormatter.format(payment.interestPayment))),
              DataCell(
                  Text(GermanCurrencyFormatter.format(payment.specialPayment))),
              DataCell(Text(GermanCurrencyFormatter.format(
                  payment.remainingSpecialPayment))),
              DataCell(
                  Text(GermanCurrencyFormatter.format(payment.interestRebate))),
              DataCell(
                  Text(GermanCurrencyFormatter.format(payment.depreciation))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummary(CalculationResult result) {
    return SingleChildScrollView(
      child: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gesamtzusammenfassung:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildSummaryRow(
                  'Gesamtlaufzeit', '${result.totalMonths} Monate', null),
              _buildSummaryRowWithPercentage(
                  'Tilgung', result.totalPrincipalPayment, result.totalSum),
              _buildSummaryRowWithPercentage('Zinszahlungen',
                  result.totalInterestPayment, result.totalSum),
              _buildSummaryRowWithPercentage('Sonderzahlungen',
                  result.totalSpecialPayment, result.totalSum),
              _buildSummaryRowWithPercentage(
                  'Zinsvorteil', result.totalInterestRebate, result.totalSum),
              _buildSummaryRowWithPercentage(
                  'Abschreibung', result.totalDepreciation, result.totalSum),
              Divider(),
              _buildSummaryRow('Summe aller Zahlungen', result.totalSum, null),
              _buildSummaryRowWithPercentage('Gesamte Steuerrückzahlung',
                  result.totalTaxRepayment, result.totalSum),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic value, double? percentage) {
    String formattedValue = value is double
        ? GermanCurrencyFormatter.format(value)
        : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(formattedValue),
        ],
      ),
    );
  }

  Widget _buildSummaryRowWithPercentage(
      String label, double value, double total) {
    double percentage = (value / total) * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(GermanCurrencyFormatter.format(value)),
              Text('${percentage.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
