import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HousePriceInput {
  final double squareMeters;
  final double housePrice;
  final double letSquareMeters;
  final double notaryFeesRate; // 1.5% of purchase price
  final double landRegistryFeesRate; // 0.5% of purchase price
  final double brokerCommissionRate; // 3.5% of purchase price

  HousePriceInput({
    required this.squareMeters,
    required this.housePrice,
    this.letSquareMeters = 0,
    this.notaryFeesRate = 0.015,
    this.landRegistryFeesRate = 0.005,
    this.brokerCommissionRate = 0.035,
  });
}

class HousePriceOutput {
  final double totalHousePrice;
  final double notaryFees;
  final double landRegistryFees;
  final double brokerCommission;

  HousePriceOutput({
    required this.totalHousePrice,
    required this.notaryFees,
    required this.landRegistryFees,
    required this.brokerCommission,
  });
}

class HousePriceCalculator extends ChangeNotifier {
  HousePriceInput _housePriceInput;
  HousePriceOutput? _housePriceOutput;

  HousePriceCalculator({required HousePriceInput initialInput})
      : _housePriceInput = initialInput {
    calculateTotalHousePrice();
  }

  HousePriceInput get housePriceInput => _housePriceInput;
  HousePriceOutput? get housePriceOutput => _housePriceOutput;

  void calculateTotalHousePrice() {
    double notaryFees =
        _housePriceInput.notaryFeesRate * _housePriceInput.housePrice;
    double landRegistryFees =
        _housePriceInput.landRegistryFeesRate * _housePriceInput.housePrice;
    double brokerCommission =
        _housePriceInput.brokerCommissionRate * _housePriceInput.housePrice;
    double totalHousePrice = _housePriceInput.housePrice +
        brokerCommission +
        notaryFees +
        landRegistryFees;

    _housePriceOutput = HousePriceOutput(
      totalHousePrice: totalHousePrice,
      notaryFees: notaryFees,
      landRegistryFees: landRegistryFees,
      brokerCommission: brokerCommission,
    );
    notifyListeners();
  }

  void updateHousePriceInput({
    double? squareMeters,
    double? housePrice,
    double? letSquareMeters,
    double? notaryFeesRate,
    double? landRegistryFeesRate,
    double? brokerCommissionRate,
  }) {
    if (housePrice != null && housePrice < 0) {
      // Handle the case when housePrice is negative
      throw ArgumentError('House price cannot be negative');
    } else {
      _housePriceInput = HousePriceInput(
        squareMeters: squareMeters ?? _housePriceInput.squareMeters,
        housePrice: housePrice ?? _housePriceInput.housePrice,
        letSquareMeters: letSquareMeters ?? _housePriceInput.letSquareMeters,
        notaryFeesRate: notaryFeesRate ?? _housePriceInput.notaryFeesRate,
        landRegistryFeesRate:
            landRegistryFeesRate ?? _housePriceInput.landRegistryFeesRate,
        brokerCommissionRate:
            brokerCommissionRate ?? _housePriceInput.brokerCommissionRate,
      );
      calculateTotalHousePrice();
    }
  }
}
