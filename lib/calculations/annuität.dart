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

  // Neue Summenfelder
  final double totalPrincipalPayment;
  final double totalInterestPayment;
  final double totalSpecialPayment;
  final double totalInterestRebate;
  final double totalDepreciation;

  CalculationResult({
    required this.payments,
    required this.totalMonths,
    required this.totalSum,
    required this.totalTaxRepayment,
    required this.totalPrincipalPayment,
    required this.totalInterestPayment,
    required this.totalSpecialPayment,
    required this.totalInterestRebate,
    required this.totalDepreciation,
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
  void initializeValues() {
    _purchasePrice = 300000.0;
    _equity = 60000.0;
    _housePriceProvider.updateHousePriceInput(
      housePrice: _purchasePrice,
      squareMeters:
          100, // Setzen Sie hier einen Standardwert für die Quadratmeter
    );
    _updatePrincipal();
    invalidateCalculations();
    notifyListeners();
  }

  // Angepasste und neue Startwerte
  double _purchasePrice = 300000.0;
  double _equity = 60000.0;
  double _principal = 240000.0;
  double _annualInterestRate = 2.5;
  double _monthlyPayment = 1000.0;
  double _monthlySpecialPayment = 100.0;
  double _maxSpecialPaymentPercent = 5.0;
  double _rentalShare = 0.5;
  double _topTaxRate = 0.42;
  double _annualDepreciationRate = 0.02;

  CalculationResult? _lastCalculationResult;
  bool _isCalculating = false;

  // Getters
  double get purchasePrice => _purchasePrice;
  double get equity => _equity;
  double get principal => _principal;
  double get annualInterestRate => _annualInterestRate;
  double get monthlyPayment => _monthlyPayment;
  double get monthlySpecialPayment => _monthlySpecialPayment;
  double get maxSpecialPaymentPercent => _maxSpecialPaymentPercent;
  double get rentalShare => _rentalShare;
  double get topTaxRate => _topTaxRate;
  double get annualDepreciationRate => _annualDepreciationRate;

  // Setters mit Aktualisierungslogik
  void updatePurchasePrice(double value) {
    if (_purchasePrice != value) {
      _purchasePrice = value;
      _updatePrincipal();
      _housePriceProvider.updateHousePriceInput(housePrice: value);
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateEquity(double value) {
    if (_equity != value) {
      _equity = value;
      _updatePrincipal();
      invalidateCalculations();
      notifyListeners();
    }
  }

  void _updatePrincipal() {
    _principal = _purchasePrice - _equity;
    if (_principal < 0) _principal = 0;
  }

  void updateAnnualInterestRate(double value) {
    if (_annualInterestRate != value) {
      _annualInterestRate = value;
      invalidateCalculations();
    }
  }

  void updateMonthlyPayment(double value) {
    if (_monthlyPayment != value) {
      _monthlyPayment = value;
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
    updatePurchasePrice(_housePriceProvider.housePriceInput.housePrice);
  }

  void invalidateCalculations() {
    _lastCalculationResult = null;
    notifyListeners();
  }

  CalculationResult calculateMortgagePayments() {
    if (_lastCalculationResult != null) {
      return _lastCalculationResult!;
    }

    _lastCalculationResult = calculateMortgagePaymentsFunction(
      purchasePrice: _purchasePrice,
      equity: _equity,
      principal: _principal,
      annualInterestRate: _annualInterestRate,
      monthlyPayment: _monthlyPayment,
      monthlySpecialPayment: _monthlySpecialPayment,
      maxSpecialPaymentPercent: _maxSpecialPaymentPercent,
      rentalShare: _rentalShare,
      topTaxRate: _topTaxRate,
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

CalculationResult calculateMortgagePaymentsFunction({
  required double purchasePrice,
  required double equity,
  required double principal,
  required double annualInterestRate,
  required double monthlyPayment,
  required double monthlySpecialPayment,
  required double maxSpecialPaymentPercent,
  required double rentalShare,
  required double topTaxRate,
  required double annualDepreciationRate,
}) {
  final double monthlyInterestRate = annualInterestRate / 12 / 100;
  final double maxAnnualSpecialPayment =
      principal * (maxSpecialPaymentPercent / 100);

  List<Payment> payments = [];
  double remainingBalance = principal;
  int month = 1;
  double totalSpecialPaymentsPerYear = 0;
  double totalSum = 0;
  double totalTaxRepayment = 0;

  // Neue Summen-Variablen
  double totalPrincipalPayment = 0;
  double totalInterestPayment = 0;
  double totalSpecialPayment = 0;
  double totalInterestRebate = 0;
  double totalDepreciation = 0;

  while (remainingBalance > 0) {
    if ((month - 1) % 12 == 0) {
      totalSpecialPaymentsPerYear = 0;
    }

    double interestPayment = remainingBalance * monthlyInterestRate;
    double principalPayment = monthlyPayment - interestPayment;

    if (principalPayment > remainingBalance) {
      principalPayment = remainingBalance;
    }

    double specialPayment = monthlySpecialPayment;
    if (totalSpecialPaymentsPerYear + specialPayment >
        maxAnnualSpecialPayment) {
      specialPayment = maxAnnualSpecialPayment - totalSpecialPaymentsPerYear;
      if (specialPayment < 0) specialPayment = 0;
    }

    totalSpecialPaymentsPerYear += specialPayment;

    double interestRebate = 0;
    double depreciation = 0;
    if (month > 12 && (month - 6) % 12 == 0) {
      interestRebate = calculateInterestRebate(
          interestPayment * 12, topTaxRate, rentalShare);
      depreciation = calculateDepreciation(
          purchasePrice, annualDepreciationRate, topTaxRate);
    }

    remainingBalance -=
        (principalPayment + specialPayment + interestRebate + depreciation);
    if (remainingBalance < 0) remainingBalance = 0;

    payments.add(Payment(
      month: month,
      principalPayment: principalPayment,
      interestPayment: interestPayment,
      remainingBalance: remainingBalance,
      specialPayment: specialPayment,
      remainingSpecialPayment:
          maxAnnualSpecialPayment - totalSpecialPaymentsPerYear,
      interestRebate: interestRebate,
      depreciation: depreciation,
    ));

    totalSum += principalPayment + interestPayment + specialPayment;
    totalTaxRepayment += interestRebate + depreciation;
    totalPrincipalPayment += principalPayment;
    totalInterestPayment += interestPayment;
    totalSpecialPayment += specialPayment;
    totalInterestRebate += interestRebate;
    totalDepreciation += depreciation;

    month++;

    if (remainingBalance < 0.01) break;
  }

  return CalculationResult(
    payments: payments,
    totalMonths: month - 1,
    totalSum: totalSum,
    totalTaxRepayment: totalTaxRepayment,
    totalPrincipalPayment: totalPrincipalPayment,
    totalInterestPayment: totalInterestPayment,
    totalSpecialPayment: totalSpecialPayment,
    totalInterestRebate: totalInterestRebate,
    totalDepreciation: totalDepreciation,
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
