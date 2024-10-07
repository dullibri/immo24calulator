import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:immo24calculator/calculations/house.dart';
import 'package:immo24calculator/firestore_service.dart';
import 'package:immo24calculator/naming.dart';

class Payment {
  final int month;
  final double principalPayment;
  final double interestPayment;
  final double remainingBalance;
  final double specialPayment;
  final double remainingSpecialPayment;
  final double interestRebate;
  final double depreciation;
  final double excess;
  final double rentSaved;
  final double rentalIncome;

  Payment({
    required this.month,
    required this.principalPayment,
    required this.interestPayment,
    required this.remainingBalance,
    required this.specialPayment,
    required this.remainingSpecialPayment,
    required this.interestRebate,
    required this.depreciation,
    required this.excess,
    required this.rentSaved,
    required this.rentalIncome,
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
  final double totalExcess;
  final double totalRentSaved;
  final double totalRentalIncome;
  final double equity;
  final double taxDeductibleShare;
  final double taxDeductibleShare;

  CalculationResult({
    required this.payments,
    required this.equity,
    required this.totalMonths,
    required this.totalSum,
    required this.totalTaxRepayment,
    required this.totalPrincipalPayment,
    required this.totalInterestPayment,
    required this.totalSpecialPayment,
    required this.totalInterestRebate,
    required this.totalDepreciation,
    required this.totalExcess,
    required this.totalRentSaved,
    required this.totalRentalIncome,
    required this.taxDeductibleShare,
    required this.taxDeductibleShare,
  });
}

double calculateInterestRebate(
    double interestForRebate, double topTaxRate, double taxDeductibleShare) {
  return interestForRebate * topTaxRate * taxDeductibleShare;
    double interestForRebate, double topTaxRate, double taxDeductibleShare) {
  return interestForRebate * topTaxRate * taxDeductibleShare;
}

double calculateDepreciation(
    double purchasePrice,
    double annualDepreciationRate,
    double topTaxRate,
    double taxDeductibleShare) {
  return purchasePrice *
      annualDepreciationRate *
      topTaxRate *
      taxDeductibleShare;
}

class Mortgage with ChangeNotifier {
  // House price related properties
  double _squareMeters;
  double _housePrice;
  double _letSquareMeters;
  double _notaryFeesRate;
  double _landRegistryFeesRate;
  double _brokerCommissionRate;
  double _monthlyRentSaved;
  double _monthlyRentalIncome;
  double _annualRentSavedIncrease;
  double _annualRentalIncomeIncrease;

  // Mortgage calculation related properties
  double _equity;
  double _principal;
  double _annualInterestRate;
  double _monthlyPayment;
  double _monthlySpecialPayment;
  double _maxSpecialPaymentPercent;
  double _otherBusinessUsedArea;
  double _taxDeductibleShare;
  double _otherBusinessUsedArea;
  double _taxDeductibleShare;
  double _topTaxRate;
  double _annualDepreciationRate;
  String _mortgageName;
  double _bodenrichtwert;
  double _grundstuecksflaeche;

  double _irrValue = 0.0;
  double get irrValue => _irrValue;

  late HousePriceOutput _housePriceOutput;
  CalculationResult? _lastCalculationResult;

  Mortgage({
    double squareMeters = 291,
    double housePrice = 695000.0,
    double letSquareMeters = 155.5,
    double otherBusinessUsedArea = 55.0,
    double otherBusinessUsedArea = 55.0,
    double notaryFeesRate = 0.015,
    double landRegistryFeesRate = 0.065,
    double brokerCommissionRate = 0.0,
    double equity = 194600.0,
    double annualInterestRate = 0.0365,
    double monthlyPayment = 2618,
    double monthlySpecialPayment = 1185,
    double maxSpecialPaymentPercent = 0.05,
    double taxDeductibleShare = 155 / 291,
    double taxDeductibleShare = 155 / 291,
    double topTaxRate = 0.42,
    double annualDepreciationRate = 0.03,
    double monthlyRentSaved = 1450,
    double monthlyRentalIncome = 1471,
    double annualRentSavedIncrease = 0.01,
    double annualRentalIncomeIncrease = 0.01,
    double bodenrichtwert = 134.0,
    double grundstuecksflaeche = 190.0,
    String? mortgageName,
  })  : _bodenrichtwert = bodenrichtwert,
        _grundstuecksflaeche = grundstuecksflaeche,
        _squareMeters = squareMeters,
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
        _otherBusinessUsedArea = otherBusinessUsedArea,
        _taxDeductibleShare = taxDeductibleShare,
        _otherBusinessUsedArea = otherBusinessUsedArea,
        _taxDeductibleShare = taxDeductibleShare,
        _topTaxRate = topTaxRate,
        _mortgageName = mortgageName ?? naming(),
        _annualDepreciationRate = annualDepreciationRate,
        _monthlyRentSaved = monthlyRentSaved,
        _monthlyRentalIncome = monthlyRentalIncome,
        _annualRentSavedIncrease = annualRentSavedIncrease,
        _annualRentalIncomeIncrease = annualRentalIncomeIncrease {
    _calculateTaxDeductibleShare();
    _calculateTaxDeductibleShare();
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
  double get otherBusinessUsedArea => _otherBusinessUsedArea;
  double get taxDeductibleShare => _taxDeductibleShare;
  double get otherBusinessUsedArea => _otherBusinessUsedArea;
  double get taxDeductibleShare => _taxDeductibleShare;
  double get topTaxRate => _topTaxRate;
  double get annualDepreciationRate => _annualDepreciationRate;
  String get mortgageName => _mortgageName;

  // House price output
  HousePriceOutput get housePriceOutput => _housePriceOutput;
  double get monthlyRentSaved => _monthlyRentSaved;
  double get monthlyRentalIncome => _monthlyRentalIncome;

  double get annualRentSavedIncrease => _annualRentSavedIncrease;
  double get annualRentalIncomeIncrease => _annualRentalIncomeIncrease;
  double get bodenrichtwert => _bodenrichtwert;
  double get grundstuecksflaeche => _grundstuecksflaeche;

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
      _calculateTaxDeductibleShare();
      _calculateTaxDeductibleShare();
      notifyListeners();
    }
  }

  void updateLetSquareMeters(double value) {
    if (_letSquareMeters != value) {
      _letSquareMeters = value;
      _calculateTaxDeductibleShare();
      notifyListeners();
    }
  }

  void updateOtherBusinessUsedArea(double value) {
    if (_otherBusinessUsedArea != value) {
      _otherBusinessUsedArea = value;
      _calculateTaxDeductibleShare();
      _calculateTaxDeductibleShare();
      notifyListeners();
    }
  }

  void updateOtherBusinessUsedArea(double value) {
    if (_otherBusinessUsedArea != value) {
      _otherBusinessUsedArea = value;
      _calculateTaxDeductibleShare();
      notifyListeners();
    }
  }

  void _calculateTaxDeductibleShare() {
    if (_squareMeters > 0) {
      _taxDeductibleShare =
          (_letSquareMeters + _otherBusinessUsedArea) / _squareMeters;
      if (_taxDeductibleShare > 1) _taxDeductibleShare = 1;
    } else {
      _taxDeductibleShare = 0;
    }
    invalidateCalculations();
  }

  void _calculateTaxDeductibleShare() {
    if (_squareMeters > 0) {
      _taxDeductibleShare =
          (_letSquareMeters + _otherBusinessUsedArea) / _squareMeters;
      if (_taxDeductibleShare > 1) _taxDeductibleShare = 1;
    } else {
      _taxDeductibleShare = 0;
    }
    invalidateCalculations();
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

  void updateMonthlyRentSaved(double value) {
    if (_monthlyRentSaved != value) {
      _monthlyRentSaved = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateMonthlyRentalIncome(double value) {
    if (_monthlyRentalIncome != value) {
      _monthlyRentalIncome = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateAnnualRentSavedIncrease(double value) {
    if (_annualRentSavedIncrease != value) {
      _annualRentSavedIncrease = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateAnnualRentalIncomeIncrease(double value) {
    if (_annualRentalIncomeIncrease != value) {
      _annualRentalIncomeIncrease = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateMortgageName(String newName) {
    if (_mortgageName != newName) {
      _mortgageName = newName;
      notifyListeners();
    }
  }

  void updateBodenrichtwert(double value) {
    if (_bodenrichtwert != value) {
      _bodenrichtwert = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  void updateGrundstuecksflaeche(double value) {
    if (_grundstuecksflaeche != value) {
      _grundstuecksflaeche = value;
      invalidateCalculations();
      notifyListeners();
    }
  }

  double calculateBodenwert() {
    return _bodenrichtwert * _grundstuecksflaeche;
  }

  // Methode zur Berechnung des abschreibungsfähigen Gebäudewerts
  double calculateAbschreibungsfaehigerGebaeudewert() {
    double bodenwert = calculateBodenwert();
    return _housePrice - bodenwert > 0 ? _housePrice - bodenwert : 0;
  }

  // Aktualisierte Methode zur Berechnung der Abschreibung
  double calculateDepreciation(double topTaxRate, double taxDeductibleShare) {
    double abschreibungsfaehigerWert =
        calculateAbschreibungsfaehigerGebaeudewert();
    return abschreibungsfaehigerWert *
        _annualDepreciationRate *
        topTaxRate *
        taxDeductibleShare;
  }

  void updateFromMortgage(Mortgage other) {
    print('updateFromMortgage called with housePrice: ${other.housePrice}');
    _housePrice = other.housePrice;
    _equity = other.equity;
    _annualInterestRate = other.annualInterestRate;
    _monthlyPayment = other.monthlyPayment;
    _monthlySpecialPayment = other.monthlySpecialPayment;
    _maxSpecialPaymentPercent = other.maxSpecialPaymentPercent;
    _taxDeductibleShare = other.taxDeductibleShare;
    _taxDeductibleShare = other.taxDeductibleShare;
    _topTaxRate = other.topTaxRate;
    _annualDepreciationRate = other.annualDepreciationRate;
    _squareMeters = other.squareMeters;
    _letSquareMeters = other.letSquareMeters;
    _notaryFeesRate = other.notaryFeesRate;
    _landRegistryFeesRate = other.landRegistryFeesRate;
    _brokerCommissionRate = other.brokerCommissionRate;
    _mortgageName = other.mortgageName;

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
      taxDeductibleShare: _taxDeductibleShare,
      taxDeductibleShare: _taxDeductibleShare,
      topTaxRate: _topTaxRate,
      annualDepreciationRate: _annualDepreciationRate,
      monthlyRentSaved: _monthlyRentSaved,
      monthlyRentalIncome: _monthlyRentalIncome,
      annualRentSavedIncrease: _annualRentSavedIncrease,
      annualRentalIncomeIncrease: _annualRentalIncomeIncrease,
      abschreibungsfaehigerGebaeudewert:
          calculateAbschreibungsfaehigerGebaeudewert(),
    );

    return _lastCalculationResult!;
  }

  void calculateIRR() {
    _irrValue = calculateIRRWithoutNotifying();
    notifyListeners();
  }

  double calculateIRRWithoutNotifying() {
    List<double> cashFlows = [-_housePriceOutput.totalHousePrice];
    CalculationResult result = calculateMortgagePayments();

    for (var payment in groupPaymentsByYear(result.payments)) {
      double yearlyInflow = payment.rentSaved + payment.rentalIncome;
      double yearlyOutflow = payment.principalPayment +
          payment.interestPayment +
          payment.specialPayment;
      double yearlyTaxBenefits = payment.interestRebate + payment.depreciation;

      double netCashFlow = yearlyInflow - yearlyOutflow + yearlyTaxBenefits;
      cashFlows.add(netCashFlow);
    }

    // Add final year's inflow (assuming property is sold at the original price)
    cashFlows[cashFlows.length - 1] += _housePriceOutput.totalHousePrice;

    return _calculateIRR(cashFlows);
  }

  double _calculateIRR(List<double> cashFlows, {double precision = 0.00001}) {
    double low = -1.0;
    double high = 1.0;
    double guess = (low + high) / 2;

    while ((high - low) > precision) {
      double npv = _calculateNPV(cashFlows, guess);
      if (npv > 0) {
        low = guess;
      } else {
        high = guess;
      }
      guess = (low + high) / 2;
    }

    return guess;
  }

  double _calculateNPV(List<double> cashFlows, double rate) {
    double npv = 0;
    for (int i = 0; i < cashFlows.length; i++) {
      npv += cashFlows[i] / pow(1 + rate, i);
    }
    return npv;
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

  static Stream<List<MortgageWithId>> getAll() {
    return FirestoreService().mortgagesStream;
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
  required double taxDeductibleShare,
  required double taxDeductibleShare,
  required double topTaxRate,
  required double annualDepreciationRate,
  required double monthlyRentSaved,
  required double monthlyRentalIncome,
  required double annualRentSavedIncrease,
  required double annualRentalIncomeIncrease,
  required double abschreibungsfaehigerGebaeudewert,
}) {
  final double monthlyInterestRate = annualInterestRate / 12;
  final double maxAnnualSpecialPayment = principal * maxSpecialPaymentPercent;

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
  double totalRentSaved = 0;
  double totalRentalIncome = 0;
  double currentMonthlyRentSaved = monthlyRentSaved;
  double currentMonthlyRentalIncome = monthlyRentalIncome;
  double depreciation = abschreibungsfaehigerGebaeudewert *
      annualDepreciationRate *
      topTaxRate *
      taxDeductibleShare;

  int currentYear = 1;

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
          interestPayment * 12, topTaxRate, taxDeductibleShare);
      depreciation = calculateDepreciation(purchasePrice,
          annualDepreciationRate, topTaxRate, taxDeductibleShare);
    }
    if (month % 12 == 1 && month > 1) {
      // Jährliche Steigerung zum 1. Monat eines neuen Jahres
      currentMonthlyRentSaved *= (1 + annualRentSavedIncrease);
      currentMonthlyRentalIncome *= (1 + annualRentalIncomeIncrease);
      currentYear++;
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

    // Adjust the remaining balance reduction
    double balanceReduction = principalPayment + specialPayment;
    if (balanceReduction > remainingBalance) {
      balanceReduction = remainingBalance;
    }
    remainingBalance -= balanceReduction;

    double rentSaved = currentMonthlyRentSaved;
    double rentalIncome = currentMonthlyRentalIncome;

    totalRentSaved += rentSaved;
    totalRentalIncome += rentalIncome;

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
      rentSaved: rentSaved,
      rentalIncome: rentalIncome,
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
  totalSum += equity;

  return CalculationResult(
    payments: payments,
    equity: equity,
    totalMonths: month - 1,
    totalSum: totalSum,
    totalTaxRepayment: totalTaxRepayment,
    totalPrincipalPayment: totalPrincipalPayment,
    totalInterestPayment: totalInterestPayment,
    totalSpecialPayment: totalSpecialPayment,
    totalInterestRebate: totalInterestRebate,
    totalDepreciation: totalDepreciation,
    totalExcess: totalExcess,
    totalRentSaved: totalRentSaved,
    totalRentalIncome: totalRentalIncome,
    taxDeductibleShare: taxDeductibleShare,
    taxDeductibleShare: taxDeductibleShare,
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
    double totalRentSaved = 0;
    double totalRentalIncome = 0;

    for (int j = i; j < i + 12 && j < payments.length; j++) {
      totalRemainingBalance = payments[j].remainingBalance;
      totalPrincipalPayment += payments[j].principalPayment;
      totalInterestPayment += payments[j].interestPayment;
      totalSpecialPayment += payments[j].specialPayment;
      totalRemainingSpecialPayment = payments[j].remainingSpecialPayment;
      totalInterestRebate += payments[j].interestRebate;
      totalDepreciation += payments[j].depreciation;
      totalExcess += payments[j].excess;
      totalRentSaved += payments[j].rentSaved;
      totalRentalIncome += payments[j].rentalIncome;
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
      rentSaved: totalRentSaved,
      rentalIncome: totalRentalIncome,
    ));
  }

  return annualPayments;
}
