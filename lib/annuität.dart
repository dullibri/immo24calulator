import 'dart:math';

class SpecialPayment {
  final int month;
  final double amount;

  SpecialPayment({required this.month, required this.amount});
}

class MortgagePayment {
  final int month;
  final double principalPayment;
  final double interestPayment;
  final double remainingBalance;
  final double specialPayment;
  final double remainingSpecialPayment;
  final double interestRebate;
  final double depreciation;

  MortgagePayment({
    required this.month,
    required this.principalPayment,
    required this.interestPayment,
    required this.remainingBalance,
    required this.specialPayment,
    required this.remainingSpecialPayment,
    required this.interestRebate,
    required this.depreciation,
  });
}

double calculateInterestRebate(double interestForRebate, double topTaxRate) {
  return interestForRebate * topTaxRate;
}

List<MortgagePayment> calculateMortgagePayments({
  required double principal,
  required double annualInterestRate,
  required double initialPayment,
  required double monthlySpecialPayment,
  required double maxSpecialPaymentPercent,
}) {
  final double monthlyInterestRate = annualInterestRate / 12 / 100;
  final double maxAnnualSpecialPayment =
      principal * (maxSpecialPaymentPercent / 100);
  final double purchasePrice = 700000;
  final double annualDepreciationRate = 0.03;
  double topTaxRate = 0.42; // 42% Spitzensteuersatz
  double interestForRebate = 0;
  double totalInterestPaidLastYear = 0;

  List<MortgagePayment> payments = [];
  double remainingBalance = principal;
  int month = 1;
  double totalSpecialPaymentsPerYear = 0;
  double interestRebate = 0;
  double depreciation = 0;

  while (remainingBalance > 0) {
    // Calculate interest rebate and depreciation every 12 months starting from month 18
    if (month >= 18 && (month - 18) % 12 == 0) {
      interestRebate = calculateInterestRebate(interestForRebate, topTaxRate);
      depreciation = purchasePrice * annualDepreciationRate;
    }

    // Reset the annual special payments and interest rebate at the start of each year
    if ((month - 1) % 12 == 0) {
      totalSpecialPaymentsPerYear = 0;
      interestForRebate =
          totalInterestPaidLastYear; // Use interest paid in the previous year for rebate calculation
      totalInterestPaidLastYear = 0;
    }

    double specialPayment = monthlySpecialPayment + interestRebate;

    // Limit special payments to the specified percentage of the initial loan amount per year
    if (totalSpecialPaymentsPerYear + specialPayment >
        maxAnnualSpecialPayment) {
      specialPayment = maxAnnualSpecialPayment - totalSpecialPaymentsPerYear;
    }
    totalSpecialPaymentsPerYear += specialPayment;

    final double interestPayment = remainingBalance * monthlyInterestRate;
    final double totalPayment = initialPayment + specialPayment;
    final double principalPayment =
        min(totalPayment - interestPayment, remainingBalance);
    remainingBalance -= principalPayment;

    if (remainingBalance < 0) remainingBalance = 0;

    totalInterestPaidLastYear +=
        interestPayment; // Accumulate interest payments for rebate calculation

    double remainingSpecialPayment =
        maxAnnualSpecialPayment - totalSpecialPaymentsPerYear;

    payments.add(MortgagePayment(
      month: month,
      principalPayment: principalPayment,
      interestPayment: interestPayment,
      remainingBalance: remainingBalance,
      specialPayment: specialPayment,
      remainingSpecialPayment: remainingSpecialPayment,
      interestRebate: interestRebate,
      depreciation: depreciation,
    ));

    month++;
  }

  return payments;
}

void main() {
  // Test
  double principal = 544000;
  double annualInterestRate = 3.61;
  double initialPayment = 2617.67;
  double monthlySpecialPayment =
      0; // Keine zusätzlichen monatlichen Sonderzahlungen
  double maxSpecialPaymentPercent =
      5; // Maximal 5% der ursprünglichen Kreditsumme als zusätzliche Sonderzahlungen

  List<MortgagePayment> payments = calculateMortgagePayments(
    principal: principal,
    annualInterestRate: annualInterestRate,
    initialPayment: initialPayment,
    monthlySpecialPayment: monthlySpecialPayment,
    maxSpecialPaymentPercent: maxSpecialPaymentPercent,
  );

  // Ausgabe der Zahlungen
  for (var payment in payments) {
    print(
        'Month ${payment.month}: Principal Payment: ${payment.principalPayment.toStringAsFixed(2)} '
        '| Interest Payment: ${payment.interestPayment.toStringAsFixed(2)} '
        '| Remaining Balance: ${payment.remainingBalance.toStringAsFixed(2)} '
        '| Special Payment: ${payment.specialPayment.toStringAsFixed(2)} '
        '| Remaining Special Payment: ${payment.remainingSpecialPayment.toStringAsFixed(2)} '
        '| Interest Rebate: ${payment.interestRebate.toStringAsFixed(2)} '
        '| Depreciation: ${payment.depreciation.toStringAsFixed(2)}');
  }
}
