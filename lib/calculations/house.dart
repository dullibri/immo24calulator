import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

class HousePriceInput extends ChangeNotifier {
  double _squareMeters;
  double _housePrice;
  double _letSquareMeters;
  double _notaryFeesRate;
  double _landRegistryFeesRate;
  double _brokerCommissionRate;

  HousePriceInput({
    required double squareMeters,
    required double housePrice,
    double letSquareMeters = 0,
    double notaryFeesRate = 0.015,
    double landRegistryFeesRate = 0.005,
    double brokerCommissionRate = 0.035,
  })  : _squareMeters = squareMeters,
        _housePrice = housePrice,
        _letSquareMeters = letSquareMeters,
        _notaryFeesRate = notaryFeesRate,
        _landRegistryFeesRate = landRegistryFeesRate,
        _brokerCommissionRate = brokerCommissionRate;

  // Getters
  double get squareMeters => _squareMeters;
  double get housePrice => _housePrice;
  double get letSquareMeters => _letSquareMeters;
  double get notaryFeesRate => _notaryFeesRate;
  double get landRegistryFeesRate => _landRegistryFeesRate;
  double get brokerCommissionRate => _brokerCommissionRate;

  // Setters
  set squareMeters(double value) {
    if (_squareMeters != value) {
      _squareMeters = value;
      notifyListeners();
    }
  }

  set housePrice(double value) {
    if (_housePrice != value) {
      _housePrice = value;
      notifyListeners();
    }
  }

  set letSquareMeters(double value) {
    if (_letSquareMeters != value) {
      _letSquareMeters = value;
      notifyListeners();
    }
  }

  set notaryFeesRate(double value) {
    if (_notaryFeesRate != value) {
      _notaryFeesRate = value;
      notifyListeners();
    }
  }

  set landRegistryFeesRate(double value) {
    if (_landRegistryFeesRate != value) {
      _landRegistryFeesRate = value;
      notifyListeners();
    }
  }

  set brokerCommissionRate(double value) {
    if (_brokerCommissionRate != value) {
      _brokerCommissionRate = value;
      notifyListeners();
    }
  }

  // Method to update multiple properties at once
  void updateProperties({
    double? squareMeters,
    double? housePrice,
    double? letSquareMeters,
    double? notaryFeesRate,
    double? landRegistryFeesRate,
    double? brokerCommissionRate,
  }) {
    bool shouldNotify = false;

    if (squareMeters != null && _squareMeters != squareMeters) {
      _squareMeters = squareMeters;
      shouldNotify = true;
    }
    if (housePrice != null && _housePrice != housePrice) {
      _housePrice = housePrice;
      shouldNotify = true;
    }
    if (letSquareMeters != null && _letSquareMeters != letSquareMeters) {
      _letSquareMeters = letSquareMeters;
      shouldNotify = true;
    }
    if (notaryFeesRate != null && _notaryFeesRate != notaryFeesRate) {
      _notaryFeesRate = notaryFeesRate;
      shouldNotify = true;
    }
    if (landRegistryFeesRate != null &&
        _landRegistryFeesRate != landRegistryFeesRate) {
      _landRegistryFeesRate = landRegistryFeesRate;
      shouldNotify = true;
    }
    if (brokerCommissionRate != null &&
        _brokerCommissionRate != brokerCommissionRate) {
      _brokerCommissionRate = brokerCommissionRate;
      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }
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
