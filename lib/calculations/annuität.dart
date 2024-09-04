import 'package:flutter/foundation.dart';
import 'dart:math';

import 'package:immo_credit/calculations/house.dart';

class Payment {
  final int month;
  final double principalPayment;
  final double interestPayment;
  final double remainingBalance;
  final double specialPayment;
  final double remainingSpecialPayment;
  final double interestRebate;
  final double depreciation;

  Payment({
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

class CalculationResult {
  final List<Payment> payments;
  final int totalMonths;
  final double totalSum;
  final double totalTaxRepayment;

  CalculationResult({
    required this.payments,
    required this.totalMonths,
    required this.totalSum,
    required this.totalTaxRepayment,
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

class MortgageCalculatorProvider extends ChangeNotifier {
  final HousePriceProvider _housePriceProvider;

  MortgageCalculatorProvider(this._housePriceProvider) {
    _housePriceProvider.addListener(_onHousePriceChanged);
  }

  // Angepasste Startwerte
  double _principal = 300000.0; // Reduziert von 500000
  double _annualInterestRate = 2.5; // Realistischer Zinssatz (in Prozent)
  double _initialPayment = 60000.0; // 20% Anzahlung
  double _monthlySpecialPayment = 100.0; // Kleine monatliche Sonderzahlung
  double _maxSpecialPaymentPercent =
      5.0; // Maximale jährliche Sondertilgung in Prozent
  double _rentalShare = 0.5; // 50% Mietanteil
  double _topTaxRate = 0.42; // Beispiel für einen Spitzensteuersatz
  double _annualDepreciationRate = 0.02; // 2% jährliche Abschreibung

  CalculationResult? _lastCalculationResult;
  bool _isCalculating = false;

  // Getters
  double get principal => _principal;
  double get annualInterestRate => _annualInterestRate;
  double get initialPayment => _initialPayment;
  double get monthlySpecialPayment => _monthlySpecialPayment;
  double get maxSpecialPaymentPercent => _maxSpecialPaymentPercent;
  double get rentalShare => _rentalShare;
  double get topTaxRate => _topTaxRate;
  double get annualDepreciationRate => _annualDepreciationRate;

  // Use housePrice from HousePriceProvider
  double get purchasePrice => _housePriceProvider.housePriceInput.housePrice;

  // Setters with invalidation
  void updatePrincipal(double value) {
    if (_principal != value) {
      _principal = value;
      invalidateCalculations();
    }
  }

  void updateAnnualInterestRate(double value) {
    if (_annualInterestRate != value) {
      _annualInterestRate = value;
      invalidateCalculations();
    }
  }

  void updateInitialPayment(double value) {
    if (_initialPayment != value) {
      _initialPayment = value;
      invalidateCalculations();
    }
  }

  void updateMonthlySpecialPayment(double value) {
    if (_monthlySpecialPayment != value) {
      _monthlySpecialPayment = value;
      invalidateCalculations();
    }
  }

  void updateMaxSpecialPaymentPercent(double value) {
    if (_maxSpecialPaymentPercent != value) {
      _maxSpecialPaymentPercent = value;
      invalidateCalculations();
    }
  }

  void updateRentalShare(double value) {
    if (_rentalShare != value) {
      _rentalShare = value;
      invalidateCalculations();
    }
  }

  void updateTopTaxRate(double value) {
    if (_topTaxRate != value) {
      _topTaxRate = value;
      invalidateCalculations();
    }
  }

  void updateAnnualDepreciationRate(double value) {
    if (_annualDepreciationRate != value) {
      _annualDepreciationRate = value;
      invalidateCalculations();
    }
  }

  void _onHousePriceChanged() {
    invalidateCalculations();
  }

  void invalidateCalculations() {
    _lastCalculationResult = null;
    notifyListeners();
  }

  // Calculate mortgage payments
  CalculationResult calculateMortgagePayments() {
    if (_lastCalculationResult != null) {
      return _lastCalculationResult!;
    }

    _lastCalculationResult = calculateMortgagePaymentsFunction(
      principal: _principal,
      annualInterestRate: _annualInterestRate,
      initialPayment: _initialPayment,
      monthlySpecialPayment: _monthlySpecialPayment,
      maxSpecialPaymentPercent: _maxSpecialPaymentPercent,
      rentalShare: _rentalShare,
      topTaxRate: _topTaxRate,
      purchasePrice: purchasePrice,
      annualDepreciationRate: _annualDepreciationRate,
    );

    return _lastCalculationResult!;
  }

  @override
  void dispose() {
    _housePriceProvider.removeListener(_onHousePriceChanged);
    super.dispose();
  }
}

// Renamed the original function to avoid confusion
CalculationResult calculateMortgagePaymentsFunction({
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

  List<Payment> payments = [];
  double remainingBalance = principal;
  int month = 1;
  double totalSpecialPaymentsPerYear = 0;
  double interestRebate = 0;
  double depreciation = 0;
  double totalSum = 0;
  double totalTaxRepayment = 0;

  while (remainingBalance > 0) {
    // Reset annual special payments and interest rebate at the start of each year
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

    payments.add(Payment(
      month: month,
      principalPayment: principalPayment,
      interestPayment: interestPayment,
      remainingBalance: remainingBalance,
      specialPayment: specialPayment,
      remainingSpecialPayment: remainingSpecialPayment,
      interestRebate: interestRebate,
      depreciation: depreciation,
    ));

    totalSum += principalPayment +
        interestPayment +
        specialPayment +
        interestRebate +
        depreciation;

    totalTaxRepayment += interestRebate + depreciation;

    month++;

    // Reset interest rebate and depreciation after application
    if (month > 18 && (month - 6) % 12 == 1) {
      interestRebate = 0;
      depreciation = 0;
    }
  }

  return CalculationResult(
    payments: payments,
    totalMonths: month - 1,
    totalSum: totalSum,
    totalTaxRepayment: totalTaxRepayment,
  );
}

// Function to group payments by year
List<Payment> groupPaymentsByYear(List<Payment> payments) {
  List<Payment> annualPayments = [];

  for (int i = 0; i < payments.length; i += 12) {
    double totalRemainingBalance = 0;
    double totalPrincipalPayment = 0;
    double totalInterestPayment = 0;
    double totalSpecialPayment = 0;
    double totalRemainingSpecialPayment = 0;
    double totalInterestRebate = 0;
    double totalDepreciation = 0;

    for (int j = i; j < i + 12 && j < payments.length; j++) {
      totalRemainingBalance = payments[j].remainingBalance;
      totalPrincipalPayment += payments[j].principalPayment;
      totalInterestPayment += payments[j].interestPayment;
      totalSpecialPayment += payments[j].specialPayment;
      totalRemainingSpecialPayment = payments[j].remainingSpecialPayment;
      totalInterestRebate += payments[j].interestRebate;
      totalDepreciation += payments[j].depreciation;
    }

    annualPayments.add(Payment(
      month: (i ~/ 12) + 1,
      remainingBalance: totalRemainingBalance,
      principalPayment: totalPrincipalPayment,
      interestPayment: totalInterestPayment,
      specialPayment: totalSpecialPayment,
      remainingSpecialPayment: totalRemainingSpecialPayment,
      interestRebate: totalInterestRebate,
      depreciation: totalDepreciation,
    ));
  }

  return annualPayments;
}
