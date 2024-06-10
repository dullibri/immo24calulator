import 'dart:math';

class MortgagePayment {
  final int month;
  final double principalPayment;
  final double interestPayment;
  final double remainingBalance;
  final double specialPayment;
  final double remainingSpecialPayment;

  MortgagePayment({
    required this.month,
    required this.principalPayment,
    required this.interestPayment,
    required this.remainingBalance,
    required this.specialPayment,
    required this.remainingSpecialPayment,
  });

  @override
  String toString() {
    return 'Month $month: Principal Payment: €${principalPayment.toStringAsFixed(2)}, Interest Payment: €${interestPayment.toStringAsFixed(2)}, Special Payment: €${specialPayment.toStringAsFixed(2)}, Remaining Special Payment: €${remainingSpecialPayment.toStringAsFixed(2)}, Remaining Balance: €${remainingBalance.toStringAsFixed(2)}';
  }
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

  List<MortgagePayment> payments = [];
  double remainingBalance = principal;
  int month = 1;
  double totalSpecialPaymentsPerYear = 0;

  while (remainingBalance > 0) {
    // Reset the annual special payments at the start of each year
    if ((month - 1) % 12 == 0) {
      totalSpecialPaymentsPerYear = 0;
    }

    double specialPayment = monthlySpecialPayment;

    // Begrenzung der Sonderzahlungen auf den festgelegten Prozentsatz der anfänglichen Kreditsumme pro Jahr
    if (totalSpecialPaymentsPerYear + specialPayment >
        maxAnnualSpecialPayment) {
      specialPayment = maxAnnualSpecialPayment - totalSpecialPaymentsPerYear;
    }
    totalSpecialPaymentsPerYear += specialPayment;

    final double interestPayment = remainingBalance * monthlyInterestRate;
    final double principalPayment =
        initialPayment - interestPayment + specialPayment;
    remainingBalance -= principalPayment;

    if (remainingBalance < 0) remainingBalance = 0;

    double remainingSpecialPayment =
        maxAnnualSpecialPayment - totalSpecialPaymentsPerYear;

    payments.add(MortgagePayment(
      month: month,
      principalPayment: principalPayment,
      interestPayment: interestPayment,
      remainingBalance: remainingBalance,
      specialPayment: specialPayment,
      remainingSpecialPayment: remainingSpecialPayment,
    ));

    month++;
  }

  return payments;
}

void main() {
  double principal = 544000; // Darlehensbetrag
  double annualInterestRate = 3.61; // Jahreszinssatz in Prozent
  double initialPayment = 2617.67; // Erste monatliche Zahlung
  double monthlySpecialPayment = 1185; // Monatliche Sonderzahlung
  double maxSpecialPaymentPercent =
      5.0; // Maximale jährliche Sonderzahlung in Prozent der anfänglichen Kreditsumme

  List<MortgagePayment> payments = calculateMortgagePayments(
    principal: principal,
    annualInterestRate: annualInterestRate,
    initialPayment: initialPayment,
    monthlySpecialPayment: monthlySpecialPayment,
    maxSpecialPaymentPercent: maxSpecialPaymentPercent,
  );

  for (var payment in payments) {
    print(payment);
  }
}
