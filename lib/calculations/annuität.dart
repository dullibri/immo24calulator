import 'package:flutter/foundation.dart';

import 'package:immo24calculator/calculations/house.dart';
import 'package:immo24calculator/firestore_service.dart';

class Payment {
  final int month;
  final double principalPayment;
  final double interestPayment;
  final double remainingBalance;
  final double specialPayment;
  final double remainingSpecialPayment;
  final double interestRebate;
  final double depreciation;
  final double excess; // New field

  Payment({
    required this.month,
    required this.principalPayment,
    required this.interestPayment,
    required this.remainingBalance,
    required this.specialPayment,
    required this.remainingSpecialPayment,
    required this.interestRebate,
    required this.depreciation,
    required this.excess, // New field
  });
}

class CalculationResult {
  final List<Payment> payments;
  final int totalMonths;
  final double totalSum;
  final double totalTaxRepayment;
  final double totalPrincipalPayment;
  final double totalInterestPayment;
  final double totalSpecialPayment;
  final double totalInterestRebate;
  final double totalDepreciation;
  final double totalExcess; // New field

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
    required this.totalExcess, // New field
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

class Mortgage with ChangeNotifier {
  // House price related properties
  double _squareMeters;
  double _housePrice;
  double _letSquareMeters;
  double _notaryFeesRate;
  double _landRegistryFeesRate;
  double _brokerCommissionRate;

  // Mortgage calculation related properties
  double _equity;
  double _principal;
  double _annualInterestRate;
  double _monthlyPayment;
  double _monthlySpecialPayment;
  double _maxSpecialPaymentPercent;
  double _rentalShare;
  double _topTaxRate;
  double _annualDepreciationRate;

  late HousePriceOutput _housePriceOutput;
  CalculationResult? _lastCalculationResult;

  Mortgage({
    double squareMeters = 291,
    double housePrice = 490800,
    double letSquareMeters = 155.5,
    double notaryFeesRate = 0.015,
    double landRegistryFeesRate = 0.065,
    double brokerCommissionRate = 0.0,
    double equity = 0,
    double annualInterestRate = 0.0365,
    double monthlyPayment = 2495,
    double monthlySpecialPayment = 1185,
    double maxSpecialPaymentPercent = 0.05,
    double rentalShare = 1.0,
    double topTaxRate = 0.42,
    double annualDepreciationRate = 0.03,
  })  : _squareMeters = squareMeters,
        _housePrice = housePrice,
        _letSquareMeters = letSquareMeters,
        _notaryFeesRate = notaryFeesRate,
        _landRegistryFeesRate = landRegistryFeesRate,
        _brokerCommissionRate = brokerCommissionRate,
        _equity = equity,
        _principal =
            housePrice * (1 + landRegistryFeesRate + brokerCommissionRate) -
                equity,
        _annualInterestRate = annualInterestRate,
        _monthlyPayment = monthlyPayment,
        _monthlySpecialPayment = monthlySpecialPayment,
        _maxSpecialPaymentPercent = maxSpecialPaymentPercent,
        _rentalShare = rentalShare,
        _topTaxRate = topTaxRate,
        _annualDepreciationRate = annualDepreciationRate {
    calculateTotalHousePrice();
    _updatePrincipal();
  }

  // Getters for all properties
  double get squareMeters => _squareMeters;
  double get housePrice => _housePrice;
  double get letSquareMeters => _letSquareMeters;
  double get notaryFeesRate => _notaryFeesRate;
  double get landRegistryFeesRate => _landRegistryFeesRate;
  double get brokerCommissionRate => _brokerCommissionRate;
  double get equity => _equity;
  double get principal => _principal;
  double get annualInterestRate => _annualInterestRate;
  double get monthlyPayment => _monthlyPayment;
  double get monthlySpecialPayment => _monthlySpecialPayment;
  double get maxSpecialPaymentPercent => _maxSpecialPaymentPercent;
  double get rentalShare => _rentalShare;
  double get topTaxRate => _topTaxRate;
  double get annualDepreciationRate => _annualDepreciationRate;

  // House price output
  HousePriceOutput get housePriceOutput => _housePriceOutput;

  // Methods to update properties

  void updateEquity(double value) {
    if (_equity != value) {
      _equity = value;
      _updatePrincipal();
      notifyListeners();
    }
  }

  void _updatePrincipal() {
    _principal = _housePriceOutput.totalHousePrice - _equity;
    if (_principal < 0) _principal = 0;
    invalidateCalculations();
  }

  void updateNotaryFeesRate(double value) {
    if (_notaryFeesRate != value) {
      _notaryFeesRate = value;
      calculateTotalHousePrice();
      notifyListeners();
    }
  }

  void updateLandRegistryFeesRate(double value) {
    if (_landRegistryFeesRate != value) {
      _landRegistryFeesRate = value;
      calculateTotalHousePrice();
      notifyListeners();
    }
  }

  void updateBrokerCommissionRate(double value) {
    if (_brokerCommissionRate != value) {
      _brokerCommissionRate = value;
      calculateTotalHousePrice();
      notifyListeners();
    }
  }

  void updateMaxSpecialPaymentPercent(double value) {
    if (_maxSpecialPaymentPercent != value) {
      _maxSpecialPaymentPercent = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateRentalShare(double value) {
    if (_rentalShare != value) {
      _rentalShare = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateTopTaxRate(double value) {
    if (_topTaxRate != value) {
      _topTaxRate = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateAnnualDepreciationRate(double value) {
    if (_annualDepreciationRate != value) {
      _annualDepreciationRate = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateSquareMeters(double value) {
    if (_squareMeters != value) {
      _squareMeters = value;
      notifyListeners();
    }
  }

  void updateLetSquareMeters(double value) {
    if (_letSquareMeters != value) {
      _letSquareMeters = value;
      notifyListeners();
    }
  }

  void updateHousePrice(double value) {
    if (_housePrice != value) {
      _housePrice = value;
      calculateTotalHousePrice();
      notifyListeners();
    }
  }

  void updateMonthlyPayment(double value) {
    if (_monthlyPayment != value) {
      _monthlyPayment = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateAnnualInterestRate(double value) {
    if (_annualInterestRate != value) {
      _annualInterestRate = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateMonthlySpecialPayment(double value) {
    if (_monthlySpecialPayment != value) {
      _monthlySpecialPayment = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateFromMortgage(Mortgage other) {
    print('updateFromMortgage called with housePrice: ${other.housePrice}');
    _housePrice = other.housePrice;
    _equity = other.equity;
    _annualInterestRate = other.annualInterestRate;
    _monthlyPayment = other.monthlyPayment;
    _monthlySpecialPayment = other.monthlySpecialPayment;
    _maxSpecialPaymentPercent = other.maxSpecialPaymentPercent;
    _rentalShare = other.rentalShare;
    _topTaxRate = other.topTaxRate;
    _annualDepreciationRate = other.annualDepreciationRate;
    _squareMeters = other.squareMeters;
    _letSquareMeters = other.letSquareMeters;
    _notaryFeesRate = other.notaryFeesRate;
    _landRegistryFeesRate = other.landRegistryFeesRate;
    _brokerCommissionRate = other.brokerCommissionRate;

    calculateTotalHousePrice();
    _updatePrincipal();
    print('After update, current housePrice: $_housePrice');
    notifyListeners();
  }

  void calculateTotalHousePrice() {
    double notaryFees = _notaryFeesRate * _housePrice;
    double landRegistryFees = _landRegistryFeesRate * _housePrice;
    double brokerCommission = _brokerCommissionRate * _housePrice;
    double totalHousePrice =
        _housePrice + notaryFees + landRegistryFees + brokerCommission;

    _housePriceOutput = HousePriceOutput(
      totalHousePrice: totalHousePrice,
      notaryFees: notaryFees,
      landRegistryFees: landRegistryFees,
      brokerCommission: brokerCommission,
    );
    _updatePrincipal();
    notifyListeners();
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
      purchasePrice: _housePriceOutput.totalHousePrice,
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

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> save() async {
    try {
      await _firestoreService.saveMortgage(this);
    } catch (e) {
      print('Error saving mortgage: $e');
      rethrow;
    }
  }

  static Stream<List<Mortgage>> getAll() {
    return FirestoreService().getMortgages();
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
  final double monthlyInterestRate = annualInterestRate / 12;
  final double maxAnnualSpecialPayment = principal * (maxSpecialPaymentPercent);

  List<Payment> payments = [];
  double remainingBalance = principal;
  int month = 1;
  double totalSpecialPaymentsPerYear = 0;
  double totalSum = 0;
  double totalTaxRepayment = 0;

  double totalPrincipalPayment = 0;
  double totalInterestPayment = 0;
  double totalSpecialPayment = 0;
  double totalInterestRebate = 0;
  double totalDepreciation = 0;
  double totalExcess = 0;

  while (remainingBalance > 0) {
    if ((month - 1) % 12 == 0) {
      totalSpecialPaymentsPerYear = 0;
    }

    double interestPayment = remainingBalance * monthlyInterestRate;
    double principalPayment = monthlyPayment - interestPayment;

    if (principalPayment > remainingBalance) {
      principalPayment = remainingBalance;
    }

    double interestRebate = 0;
    double depreciation = 0;
    if (month > 12 && (month - 6) % 12 == 0) {
      interestRebate = calculateInterestRebate(
          interestPayment * 12, topTaxRate, rentalShare);
      depreciation = calculateDepreciation(
          purchasePrice, annualDepreciationRate, topTaxRate);
    }

    double specialPayment = monthlySpecialPayment;
    double totalSpecialWithRebateAndDepreciation =
        specialPayment + interestRebate + depreciation;
    double excess = 0;

    if (totalSpecialPaymentsPerYear + totalSpecialWithRebateAndDepreciation >
        maxAnnualSpecialPayment) {
      excess = totalSpecialPaymentsPerYear +
          totalSpecialWithRebateAndDepreciation -
          maxAnnualSpecialPayment;
      totalSpecialWithRebateAndDepreciation =
          maxAnnualSpecialPayment - totalSpecialPaymentsPerYear;
    }

    totalSpecialPaymentsPerYear += totalSpecialWithRebateAndDepreciation;

    remainingBalance -=
        (principalPayment + totalSpecialWithRebateAndDepreciation);
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
      excess: excess,
    ));

    totalSum += principalPayment + interestPayment + specialPayment;
    totalTaxRepayment += interestRebate + depreciation;
    totalPrincipalPayment += principalPayment;
    totalInterestPayment += interestPayment;
    totalSpecialPayment += specialPayment;
    totalInterestRebate += interestRebate;
    totalDepreciation += depreciation;
    totalExcess += excess;

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
    totalExcess: totalExcess,
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
    double totalExcess = 0;

    for (int j = i; j < i + 12 && j < payments.length; j++) {
      totalRemainingBalance = payments[j].remainingBalance;
      totalPrincipalPayment += payments[j].principalPayment;
      totalInterestPayment += payments[j].interestPayment;
      totalSpecialPayment += payments[j].specialPayment;
      totalRemainingSpecialPayment = payments[j].remainingSpecialPayment;
      totalInterestRebate += payments[j].interestRebate;
      totalDepreciation += payments[j].depreciation;
      totalExcess += payments[j].excess;
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
      excess: totalExcess,
    ));
  }

  return annualPayments;
}
