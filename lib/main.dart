import 'package:flutter/material.dart';
import 'calculations/annuität.dart';
import 'calculations/house.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hypothekenrechner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MortgageCalculatorPage(),
    );
  }
}

class MortgageCalculatorPage extends StatefulWidget {
  @override
  _MortgageCalculatorPageState createState() => _MortgageCalculatorPageState();
}

class _MortgageCalculatorPageState extends State<MortgageCalculatorPage> {
  // Default values
  double annualInterestRate = 3.61;
  double initialPayment = 3200.00;
  double monthlySpecialPayment = 1185;
  double maxSpecialPaymentPercent = 5;
  double rentalShare = 580000 / 544000;
  double topTaxRate = 0.42;
  double purchasePrice = 800000;
  double annualDepreciationRate = 0.03;
  double equity = 100000;

  // Default rates
  double notaryFeesRate = 0.015;
  double landRegistryFeesRate = 0.005;
  double brokerCommissionRate = 0.035;

  double principal = 0.0;

  CalculationResult? calculationResult;
  HousePriceOutput? housePriceOutput;
  bool showAnnual = false;

  // Method to calculate mortgage payments
  void calculatePayments() {
    final houseInput = HousePriceInput(
      squareMeters: 0,
      housePrice: purchasePrice,
      notaryFeesRate: notaryFeesRate,
      landRegistryFeesRate: landRegistryFeesRate,
      brokerCommissionRate: brokerCommissionRate,
    );

    setState(() {
      housePriceOutput = calculateTotalHousePrice(houseInput);
      principal = housePriceOutput!.totalHousePrice - equity;

      calculationResult = calculateMortgagePayments(
        principal: principal,
        annualInterestRate: annualInterestRate,
        initialPayment: initialPayment,
        monthlySpecialPayment: monthlySpecialPayment,
        maxSpecialPaymentPercent: maxSpecialPaymentPercent,
        rentalShare: rentalShare,
        topTaxRate: topTaxRate,
        purchasePrice: housePriceOutput!.totalHousePrice,
        annualDepreciationRate: annualDepreciationRate,
      );
    });
  }

  // Method to build input fields
  Widget buildInputField(String label, String initialValue,
      Function(String)? onChanged, bool positiveOnly) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: initialValue,
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged != null
          ? (value) {
              if (positiveOnly &&
                  double.tryParse(value) != null &&
                  double.parse(value) < 0) {
                // Handle negative input (show error or prevent change)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Wert darf nicht negativ sein')),
                );
              } else {
                onChanged(value);
              }
            }
          : null,
    );
  }

  // Method to handle text field changes and validation
  void handleTextFieldChange(String value, Function(double) updateFunction) {
    if (double.tryParse(value) != null) {
      updateFunction(double.parse(value));
    }
  }

  // Method to build summary widget
  Widget buildSummary() {
    if (calculationResult == null || housePriceOutput == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Zusammenfassung:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
            'Gesamtkosten: ${housePriceOutput!.totalHousePrice.toStringAsFixed(0)} €'),
        Text('Kreditsumme: ${principal.toStringAsFixed(0)} €'),
        Text(
            'Dauer bis zur Rückzahlung: ${calculationResult!.totalMonths} Monate'),
        Text(
            'Gesamtsumme über alle Zahlungen: ${calculationResult!.totalSum.toStringAsFixed(0)} €'),
        const SizedBox(height: 16.0),
        const Text('Zusätzliche Kosten:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
            'Notargebühren: ${housePriceOutput!.notaryFees.toStringAsFixed(0)} €'),
        Text(
            'Grundbuchgebühren: ${housePriceOutput!.landRegistryFees.toStringAsFixed(0)} €'),
        Text(
            'Maklerprovision: ${housePriceOutput!.brockerCommision.toStringAsFixed(0)} €'),
        const SizedBox(height: 16.0),
        SwitchListTile(
          title: const Text('Jährliche Werte anzeigen'),
          value: showAnnual,
          onChanged: (value) {
            setState(() {
              showAnnual = value;
            });
          },
        ),
        buildDataTable(),
      ],
    );
  }

  // Method to build data table widget
  Widget buildDataTable() {
    final payments = showAnnual
        ? groupPaymentsByYear(calculationResult!.payments)
        : calculationResult!.payments;

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
        final periodLabel = showAnnual
            ? '${payment.month ~/ 12 + 1}'
            : '${payment.month % 12 == 0 ? 12 : payment.month % 12}';

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

  // Method to group payments by year
  List<Payment> groupPaymentsByYear(List<Payment> payments) {
    List<Payment> annualPayments = [];
    for (int i = 0; i < payments.length; i += 12) {
      double totalPrincipalPayment = 0;
      double totalInterestPayment = 0;
      double totalSpecialPayment = 0;
      double totalRemainingSpecialPayment = 0;
      double totalInterestRebate = 0;
      double totalDepreciation = 0;

      for (int j = i; j < i + 12 && j < payments.length; j++) {
        totalPrincipalPayment += payments[j].principalPayment;
        totalInterestPayment += payments[j].interestPayment;
        totalSpecialPayment += payments[j].specialPayment;
        totalRemainingSpecialPayment += payments[j].remainingSpecialPayment;
        totalInterestRebate += payments[j].interestRebate;
        totalDepreciation += payments[j].depreciation;
      }

      annualPayments.add(
        Payment(
          month: i,
          remainingBalance: payments[i].remainingBalance,
          principalPayment: totalPrincipalPayment,
          interestPayment: totalInterestPayment,
          specialPayment: totalSpecialPayment,
          remainingSpecialPayment: totalRemainingSpecialPayment,
          interestRebate: totalInterestRebate,
          depreciation: totalDepreciation,
        ),
      );
    }
    return annualPayments;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hypothekenrechner'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Hauptfaktoren'),
              Tab(text: 'Rahmenwerte'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Hauptfaktoren Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Hauptfaktoren:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  buildInputField(
                    'Kaufpreis',
                    purchasePrice.toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        purchasePrice = newValue;
                        if (equity > purchasePrice) {
                          equity = purchasePrice;
                        }
                      });
                    }),
                    true, // Positive only
                  ),
                  buildInputField(
                    'Eigenkapital',
                    equity.toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        equity = newValue;
                        if (equity > purchasePrice) {
                          purchasePrice = equity;
                        }
                      });
                    }),
                    true, // Positive only
                  ),
                  buildInputField(
                    'Jährlicher Zinssatz',
                    annualInterestRate.toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        annualInterestRate = newValue;
                      });
                    }),
                    false, // Allow negative values
                  ),
                  buildInputField(
                    'Anfangszahlung',
                    initialPayment.toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        initialPayment = newValue;
                      });
                    }),
                    true, // Positive only
                  ),
                  buildInputField(
                    'Monatliche Sonderzahlung',
                    monthlySpecialPayment.toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        monthlySpecialPayment = newValue;
                      });
                    }),
                    true, // Positive only
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (equity >= purchasePrice) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Eigenkapital muss kleiner als Kaufpreis sein')),
                        );
                      } else {
                        calculatePayments();
                      }
                    },
                    child: const Text('Berechnen'),
                  ),
                  const SizedBox(height: 16.0),
                  buildSummary(),
                ],
              ),
            ),
            // Rahmenwerte Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Voreingestellte Rahmenwerte:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  buildInputField(
                    'Notargebührenrate (%)',
                    (notaryFeesRate * 100).toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        notaryFeesRate = newValue / 100;
                      });
                    }),
                    true, // Positive only
                  ),
                  buildInputField(
                    'Grundbuchgebührenrate (%)',
                    (landRegistryFeesRate * 100).toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        landRegistryFeesRate = newValue / 100;
                      });
                    }),
                    true, // Positive only
                  ),
                  buildInputField(
                    'Maklerprovisionrate (%)',
                    (brokerCommissionRate * 100).toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        brokerCommissionRate = newValue / 100;
                      });
                    }),
                    true, // Positive only
                  ),
                  buildInputField(
                    'Max. Sonderzahlungsprozentsatz (%)',
                    maxSpecialPaymentPercent.toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        maxSpecialPaymentPercent = newValue;
                      });
                    }),
                    true, // Positive only
                  ),
                  buildInputField(
                    'Mietanteil',
                    rentalShare.toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        rentalShare = newValue;
                      });
                    }),
                    false, // Allow negative values for rental share
                  ),
                  buildInputField(
                    'Spitzensteuersatz',
                    topTaxRate.toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        topTaxRate = newValue;
                      });
                    }),
                    false, // Allow negative values for tax rate
                  ),
                  buildInputField(
                    'Jährliche Abschreibung',
                    annualDepreciationRate.toString(),
                    (value) => handleTextFieldChange(value, (newValue) {
                      setState(() {
                        annualDepreciationRate = newValue;
                      });
                    }),
                    false, // Allow negative values for depreciation rate
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
