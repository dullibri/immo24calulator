import 'dart:math';

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

double calculateInterestRebate(
    double interestForRebate, double topTaxRate, double rentalShare) {
  return interestForRebate * topTaxRate * rentalShare;
}

double calculateDepreciation(
    double purchasePrice, double annualDepreciationRate, double topTaxRate) {
  return purchasePrice * annualDepreciationRate * topTaxRate;
}

List<MortgagePayment> calculateMortgagePayments({
  required double principal,
  required double annualInterestRate,
  required double initialPayment,
  required double monthlySpecialPayment,
  required double maxSpecialPaymentPercent,
  required double rentalShare,
  required double topTaxRate,
  required double purchasePrice,
  required double annualDepreciationRate,
}) {
  final double monthlyInterestRate = annualInterestRate / 12 / 100;
  final double maxAnnualSpecialPayment =
      principal * (maxSpecialPaymentPercent / 100);
  double totalInterestPaidLastYear = 0;

  List<MortgagePayment> payments = [];
  double remainingBalance = principal;
  int month = 1;
  double totalSpecialPaymentsPerYear = 0;
  double interestRebate = 0;
  double depreciation = 0;

  while (remainingBalance > 0) {
    // Reset the annual special payments and interest rebate at the start of each year
    if ((month - 1) % 12 == 0) {
      totalSpecialPaymentsPerYear = 0;
      totalInterestPaidLastYear = 0;
    }

    // Calculate interest rebate and depreciation every 12 months starting from month 18
    if (month > 12 && (month - 6) % 12 == 0) {
      interestRebate = calculateInterestRebate(
          totalInterestPaidLastYear, topTaxRate, rentalShare);
      depreciation = calculateDepreciation(
          purchasePrice, annualDepreciationRate, topTaxRate);
    }

    double specialPayment = monthlySpecialPayment;

    // Limit special payments to the specified percentage of the initial loan amount per year
    double totalExtraPayments = specialPayment + interestRebate + depreciation;
    if (totalSpecialPaymentsPerYear + totalExtraPayments >
        maxAnnualSpecialPayment) {
      double remainingAllowedPayment =
          maxAnnualSpecialPayment - totalSpecialPaymentsPerYear;
      if (remainingAllowedPayment > 0) {
        specialPayment = min(specialPayment, remainingAllowedPayment);
        remainingAllowedPayment -= specialPayment;
        interestRebate = min(interestRebate, remainingAllowedPayment);
        remainingAllowedPayment -= interestRebate;
        depreciation = min(depreciation, remainingAllowedPayment);
      } else {
        specialPayment = 0;
        interestRebate = 0;
        depreciation = 0;
      }
    }

    totalSpecialPaymentsPerYear +=
        (specialPayment + interestRebate + depreciation);

    final double interestPayment = remainingBalance * monthlyInterestRate;
    final double totalPayment = initialPayment + specialPayment;
    final double principalPayment =
        min(totalPayment - interestPayment, remainingBalance);
    remainingBalance -= principalPayment;

    if (month > 12 && (month - 6) % 12 == 0) {
      remainingBalance -= (interestRebate + depreciation);
    }

    if (remainingBalance < 0) remainingBalance = 0;

    totalInterestPaidLastYear += interestPayment;

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
    // Reset interest rebate and depreciation after it has been applied
    if (month > 18 && (month - 6) % 12 == 1) {
      interestRebate = 0;
      depreciation = 0;
    }
  }

  return payments;
}

void main() {
  // Test
  double principal = 544000;
  double annualInterestRate = 3.61;
  double initialPayment = 2617.67;
  double monthlySpecialPayment = 1185; // Zusätzliche monatliche Sonderzahlungen
  double maxSpecialPaymentPercent =
      5; // Maximal 5% der ursprünglichen Kreditsumme als zusätzliche Sonderzahlungen
  double rentalShare = 530063 /
      544000; // Verhältnis von vermietetem/gewerblichem Anteil zu Gesamtkredit
  double topTaxRate = 0.42; // 42% Spitzensteuersatz
  double purchasePrice = 700000;
  double annualDepreciationRate = 0.03;

  List<MortgagePayment> payments = calculateMortgagePayments(
    principal: principal,
    annualInterestRate: annualInterestRate,
    initialPayment: initialPayment,
    monthlySpecialPayment: monthlySpecialPayment,
    maxSpecialPaymentPercent: maxSpecialPaymentPercent,
    rentalShare: rentalShare,
    topTaxRate: topTaxRate,
    purchasePrice: purchasePrice,
    annualDepreciationRate: annualDepreciationRate,
  );

  // Print table header
  print(
      'Month | Principal Payment | Interest Payment | Remaining Balance | Special Payment | Remaining Special Payment | Interest Rebate | Depreciation');

  // Print each payment
  for (var payment in payments) {
    print('${payment.month.toString().padLeft(5)} '
        '| ${payment.principalPayment.toStringAsFixed(2).padLeft(17)} '
        '| ${payment.interestPayment.toStringAsFixed(2).padLeft(16)} '
        '| ${payment.remainingBalance.toStringAsFixed(2).padLeft(17)} '
        '| ${payment.specialPayment.toStringAsFixed(2).padLeft(14)} '
        '| ${payment.remainingSpecialPayment.toStringAsFixed(2).padLeft(25)} '
        '| ${payment.interestRebate.toStringAsFixed(2).padLeft(14)} '
        '| ${payment.depreciation.toStringAsFixed(2).padLeft(11)}');
  }
}
