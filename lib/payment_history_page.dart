import 'package:flutter/material.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/german_currency_converter.dart';
import 'package:provider/provider.dart';

class PaymentHistoryPage extends StatefulWidget {
  final CalculationResult calculationResult;

  PaymentHistoryPage({required this.calculationResult});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  String _selectedView = 'summary';
  bool _isDetailsExpanded = false;
  bool _isRepaymentExpanded = false; // Add this line

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildViewToggle(),
                  _buildSelectedView(constraints),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.amber[100], // Heller, warmer Hintergrund
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.amber[200]!.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggleButton('Zusammenfassung', 'summary'),
          _buildToggleButton('Jährlich', 'yearly'),
          _buildToggleButton('Monatlich', 'monthly'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value) {
    bool isSelected = _selectedView == value;
    return ElevatedButton(
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.amber[400] : Colors.amber[50],
        foregroundColor: Colors.brown[800],
        elevation: isSelected ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber[400]!, width: 2),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () {
        setState(() {
          _selectedView = value;
        });
      },
    );
  }

  Widget _buildSelectedView(BoxConstraints constraints) {
    switch (_selectedView) {
      case 'monthly':
        return _buildDataTable(widget.calculationResult.payments, constraints);
      case 'yearly':
        return _buildDataTable(
            groupPaymentsByYear(widget.calculationResult.payments),
            constraints);
      case 'summary':
        return _buildSummary(widget.calculationResult);
      default:
        return Container();
    }
  }

  Widget _buildDataTable(List<Payment> payments, BoxConstraints constraints) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: _buildColumns(),
        rows: payments.map((payment) => _buildDataRow(payment)).toList(),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    List<DataColumn> columns = [
      DataColumn(
        label: Text(_selectedView == 'yearly' ? 'Jahr' : 'Monat'),
      ),
      DataColumn(label: Text('Restschuld')),
      DataColumn(label: Text('Zinsen')),
      DataColumn(
        label: Row(
          children: [
            Text('Gesamttilgung'),
            SizedBox(width: 8),
            _buildExpandButton(),
          ],
        ),
      ),
    ];

    if (_isDetailsExpanded) {
      columns.addAll([
        DataColumn(
          label: Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Tilgung', style: TextStyle(color: Colors.blue[800])),
          ),
        ),
        DataColumn(
          label: Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Sonderzahlung',
                style: TextStyle(color: Colors.blue[800])),
          ),
        ),
        DataColumn(
          label: Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child:
                Text('Zinsvorteil', style: TextStyle(color: Colors.blue[800])),
          ),
        ),
        DataColumn(
          label: Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child:
                Text('Abschreibung', style: TextStyle(color: Colors.blue[800])),
          ),
        ),
      ]);
    }

    columns.addAll([
      DataColumn(label: Text('Verbl. Sonderzahlung')),
      DataColumn(label: Text('Überschuss')),
    ]);

    return columns;
  }

  Widget _buildExpandButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isDetailsExpanded = !_isDetailsExpanded;
        });
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue),
        ),
        child: Icon(
          _isDetailsExpanded ? Icons.remove : Icons.add,
          size: 16,
          color: Colors.blue,
        ),
      ),
    );
  }

  DataRow _buildDataRow(Payment payment) {
    double totalRepayment = payment.principalPayment +
        payment.specialPayment +
        payment.interestRebate +
        payment.depreciation;

    List<DataCell> cells = [
      DataCell(Text(payment.month.toString())),
      DataCell(Text(GermanCurrencyFormatter.format(payment.remainingBalance))),
      DataCell(Text(GermanCurrencyFormatter.format(totalRepayment))),
      DataCell(Text(GermanCurrencyFormatter.format(payment.interestPayment))),
    ];

    if (_isDetailsExpanded) {
      cells.addAll([
        DataCell(
          Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child:
                Text(GermanCurrencyFormatter.format(payment.principalPayment)),
          ),
        ),
        DataCell(
          Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(GermanCurrencyFormatter.format(payment.specialPayment)),
          ),
        ),
        DataCell(
          Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(GermanCurrencyFormatter.format(payment.interestRebate)),
          ),
        ),
        DataCell(
          Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(GermanCurrencyFormatter.format(payment.depreciation)),
          ),
        ),
      ]);
    }

    cells.addAll([
      DataCell(Text(
          GermanCurrencyFormatter.format(payment.remainingSpecialPayment))),
      DataCell(Text(GermanCurrencyFormatter.format(payment.excess))),
    ]);

    return DataRow(cells: cells);
  }

  Widget _buildSummary(CalculationResult result) {
    final mortgage = Provider.of<Mortgage>(context, listen: false);
    double totalRepayment = result.totalPrincipalPayment +
        result.totalSpecialPayment +
        result.totalInterestRebate +
        result.totalDepreciation;

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gesamtzusammenfassung:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildSummaryRow('Gesamtlaufzeit', '${result.totalMonths} Monate'),
            _buildExpandableRepaymentRow(
                'Gesamttilgung', totalRepayment, result.totalSum, [
              ('Tilgung', result.totalPrincipalPayment),
              ('Sonderzahlungen', result.totalSpecialPayment),
              ('Zinsvorteil', result.totalInterestRebate),
              ('Abschreibung', result.totalDepreciation),
            ]),
            _buildSummaryRowWithPercentage(
                'Zinszahlungen', result.totalInterestPayment, result.totalSum),
            _buildSummaryRowWithPercentage(
                'Überschuss', result.totalExcess, result.totalSum),
            _buildSummaryRowWithPercentage(
                'Eigenkapital', mortgage.equity, result.totalSum),
            Divider(),
            _buildSummaryRow('Summe aller Zahlungen', result.totalSum),
            _buildSummaryRowWithPercentage('Gesamte Steuerrückzahlung',
                result.totalTaxRepayment, result.totalSum),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableRepaymentRow(String label, double value, double total,
      List<(String, double)> details) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(GermanCurrencyFormatter.format(value)),
                    Text('${((value / total) * 100).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isRepaymentExpanded = !_isRepaymentExpanded;
                    });
                  },
                  child: Icon(
                    _isRepaymentExpanded ? Icons.remove : Icons.add,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (_isRepaymentExpanded)
          Padding(
            padding: EdgeInsets.only(left: 16, top: 8),
            child: Column(
              children: details
                  .map((detail) => _buildDetailRow(detail.$1, detail.$2, total))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, double value, double total) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.blue[800])),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(GermanCurrencyFormatter.format(value),
                  style: TextStyle(color: Colors.blue[800])),
              Text('${((value / total) * 100).toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 10, color: Colors.blue[400])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic value) {
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
