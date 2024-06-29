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
  final double brockerCommision;

  HousePriceOutput({
    required this.totalHousePrice,
    required this.notaryFees,
    required this.landRegistryFees,
    required this.brockerCommision,
  });
}

HousePriceOutput calculateTotalHousePrice(HousePriceInput house) {
  double notaryFees = house.notaryFeesRate * house.housePrice;
  double landRegistryFees = house.landRegistryFeesRate * house.housePrice;
  double brockerCommission = house.brokerCommissionRate * house.housePrice;
  double totalHousePrice = house.housePrice * (1 + totalChargesRate);
  double totalChargesRate =
      house.housePrice + brockerCommission + notaryFees + landRegistryFees;
  return HousePriceOutput(
      totalHousePrice: totalHousePrice,
      notaryFees: notaryFees,
      landRegistryFees: landRegistryFees,
      brockerCommision: brockerCommission);
}
