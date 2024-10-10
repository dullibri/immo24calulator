import 'package:flutter/material.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/german_currency_converter.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';

class PaymentHistoryPage extends StatefulWidget {
  final CalculationResult calculationResult;

  PaymentHistoryPage({required this.calculationResult});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  String _selectedView = 'summary';
  bool _isTaxesExpandedTable = false;
  bool _isTaxesExpandedSummary = false;
  bool _isRepaymentExpandedTable = false;
  bool _isRepaymentExpandedSummary = false;
  late double _irrValue;

  @override
  void initState() {
    super.initState();
    final mortgage = Provider.of<Mortgage>(context, listen: false);
    _irrValue = mortgage.calculateIRRWithoutNotifying();
  }

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
                  _buildInitialLoanInfo(),
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
        color: Colors.amber[100],
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

  Widget _buildInitialLoanInfo() {
    final mortgage = Provider.of<Mortgage>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Startkredit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                  'Anfängliche Kreditsumme: ${GermanCurrencyFormatter.format(mortgage.principal)}'),
              SizedBox(height: 8),
              Text(
                  'Hinweis: Die Restschuld in der Tabelle zeigt den Stand am Ende des jeweiligen ${_selectedView == 'yearly' ? 'Jahres' : 'Monats'}.',
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
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
    final columns = _buildColumns();
    final minWidth =
        _isTaxesExpandedTable || _isRepaymentExpandedTable ? 1200.0 : 800.0;

    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight - 200, // Adjust this value as needed
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: minWidth,
        columns: columns,
        rows: payments.map((payment) => _buildDataRow(payment)).toList(),
        fixedTopRows: 1,
        fixedLeftColumns: 1,
        smRatio: 0.4,
        lmRatio: 2.0,
      ),
    );
  }

  List<DataColumn2> _buildColumns() {
    List<DataColumn2> columns = [
      DataColumn2(
        label: Text(_selectedView == 'yearly' ? 'Jahr' : 'Monat'),
        size: ColumnSize.S,
        fixedWidth: 60,
      ),
      DataColumn2(label: Text('Restschuld'), size: ColumnSize.L),
      DataColumn2(label: Text('Zinsen'), size: ColumnSize.M),
      DataColumn2(
        label: Row(
          children: [
            Text('Tilgung'),
            SizedBox(width: 8),
            _buildExpandButton('repayment'),
          ],
        ),
        size: ColumnSize.L,
      ),
    ];

    if (_isRepaymentExpandedTable) {
      columns.addAll([
        DataColumn2(
          label: Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Reguläre Tilgung',
                style: TextStyle(color: Colors.blue[800])),
          ),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Sonderzahlung',
                style: TextStyle(color: Colors.blue[800])),
          ),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Steuerrückzahlungen',
                style: TextStyle(color: Colors.blue[800])),
          ),
          size: ColumnSize.M,
        ),
      ]);
    }

    columns.add(
      DataColumn2(
        label: Row(
          children: [
            Text('Steuerrückzahlungen'),
            SizedBox(width: 8),
            _buildExpandButton('taxes'),
          ],
        ),
        size: ColumnSize.L,
      ),
    );

    if (_isTaxesExpandedTable) {
      columns.addAll([
        DataColumn2(
          label: Container(
            color: Colors.green[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child:
                Text('Zinsvorteil', style: TextStyle(color: Colors.green[800])),
          ),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Container(
            color: Colors.green[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Abschreibung',
                style: TextStyle(color: Colors.green[800])),
          ),
          size: ColumnSize.M,
        ),
      ]);
    }

    columns.addAll([
      DataColumn2(label: Text('Mietersparnis'), size: ColumnSize.M),
      DataColumn2(label: Text('Mieteinnahmen'), size: ColumnSize.M),
      DataColumn2(label: Text('Verbl. Sonderzahlung'), size: ColumnSize.L),
      DataColumn2(label: Text('Überschuss'), size: ColumnSize.M),
    ]);

    return columns;
  }

  DataRow _buildDataRow(Payment payment) {
    double taxBenefits = payment.interestRebate + payment.depreciation;
    double totalRepayment =
        payment.principalPayment + payment.specialPayment + taxBenefits;

    List<DataCell> cells = [
      DataCell(Text(payment.month.toString())),
      DataCell(Text(GermanCurrencyFormatter.format(payment.remainingBalance))),
      DataCell(Text(GermanCurrencyFormatter.format(payment.interestPayment))),
      DataCell(Text(GermanCurrencyFormatter.format(totalRepayment))),
    ];

    if (_isRepaymentExpandedTable) {
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
        DataCell(Container(
            color: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(GermanCurrencyFormatter.format(taxBenefits)))),
      ]);
    }

    cells.add(DataCell(Text(GermanCurrencyFormatter.format(taxBenefits))));

    if (_isTaxesExpandedTable) {
      cells.addAll([
        DataCell(
          Container(
            color: Colors.green[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(GermanCurrencyFormatter.format(payment.interestRebate)),
          ),
        ),
        DataCell(
          Container(
            color: Colors.green[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(GermanCurrencyFormatter.format(payment.depreciation)),
          ),
        ),
      ]);
    }

    cells.addAll([
      DataCell(Text(GermanCurrencyFormatter.format(payment.rentSaved))),
      DataCell(Text(GermanCurrencyFormatter.format(payment.rentalIncome))),
      DataCell(Text(
          GermanCurrencyFormatter.format(payment.remainingSpecialPayment))),
      DataCell(Text(GermanCurrencyFormatter.format(payment.excess))),
    ]);

    return DataRow(cells: cells);
  }

  Widget _buildExpandButton(String expandableType) {
    bool isExpanded = expandableType == 'taxes'
        ? _isTaxesExpandedTable
        : _isRepaymentExpandedTable;
    return InkWell(
      onTap: () {
        setState(() {
          if (expandableType == 'taxes') {
            _isTaxesExpandedTable = !_isTaxesExpandedTable;
          } else {
            _isRepaymentExpandedTable = !_isRepaymentExpandedTable;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue),
        ),
        child: Icon(
          isExpanded ? Icons.remove : Icons.add,
          size: 16,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSummary(CalculationResult result) {
    final mortgage = Provider.of<Mortgage>(context, listen: false);
    double totalRegularRepayment = result.totalPrincipalPayment;
    double totalSpecialPayment = result.totalSpecialPayment;
    double totalTaxBenefits =
        result.totalInterestRebate + result.totalDepreciation;

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
            _buildSummaryRowWithPercentage(
                'Eigenkapital', result.equity, result.totalSum),
            _buildExpandableRepaymentRow(
              'Gesamttilgung',
              totalRegularRepayment + totalSpecialPayment,
              result.totalSum,
              [
                ('Reguläre Tilgung', totalRegularRepayment),
                ('Sonderzahlungen', totalSpecialPayment),
              ],
              'repayment',
            ),
            _buildExpandableRepaymentRow(
              'Steuerliche Vorteile',
              totalTaxBenefits,
              result.totalSum,
              [
                ('Zinsvorteil', result.totalInterestRebate),
                ('Abschreibung', result.totalDepreciation),
              ],
              'taxes',
            ),
            _buildSummaryRowWithPercentage(
                'Zinszahlungen', result.totalInterestPayment, result.totalSum),
            _buildSummaryRowWithPercentage(
                'Überschuss', result.totalExcess, result.totalSum),
            Divider(),
            _buildSummaryRow('Summe aller Zahlungen', result.totalSum),
            Divider(),
            _buildSummaryRow('Interne Rendite (IRR)',
                '${(_irrValue * 100).toStringAsFixed(2)}%'),
            _buildSummaryRowWithPercentage(
                'Mietersparnis', result.totalRentSaved, result.totalSum),
            _buildSummaryRowWithPercentage(
                'Mieteinnahmen', result.totalRentalIncome, result.totalSum),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableRepaymentRow(String label, double value, double total,
      List<(String, double)> details, String expandableType) {
    bool isExpanded = expandableType == 'taxes'
        ? _isTaxesExpandedSummary
        : _isRepaymentExpandedSummary;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (expandableType == 'repayment') {
                        _isRepaymentExpandedSummary =
                            !_isRepaymentExpandedSummary;
                      } else if (expandableType == 'taxes') {
                        _isTaxesExpandedSummary = !_isTaxesExpandedSummary;
                      }
                    });
                  },
                  child: Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
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
              ],
            ),
          ],
        ),
        if (isExpanded)
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
