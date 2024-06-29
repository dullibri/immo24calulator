class RentIncome {
  final double totalSquareMeters;
  final double letSquareMeters;
  final double rentPerSquareMeter;
  final int numMonths;
  final double topTaxRate;

  RentIncome({
    required this.totalSquareMeters,
    required this.letSquareMeters,
    required this.rentPerSquareMeter,
    required this.numMonths,
    required this.topTaxRate,
  });
}

class RentResults {
  final double rentTotal;
  final double rentTotalNet;
  final double rentMonthly;
  final double rentMonthlyNet;
  final double potentialRentTotal;
  final double potentialRentTotalNet;
  final double potentialRentMonthly;
  final double potentialRentMonthlyNet;

  RentResults({
    required this.rentTotal,
    required this.rentTotalNet,
    required this.rentMonthly,
    required this.rentMonthlyNet,
    required this.potentialRentTotal,
    required this.potentialRentTotalNet,
    required this.potentialRentMonthly,
    required this.potentialRentMonthlyNet,
  });
}

RentResults calculateRent(RentIncome income) {
  final rentMonthly = income.rentPerSquareMeter * income.letSquareMeters;
  final rentMonthlyNet = rentMonthly * (1 - income.topTaxRate);
  final rentTotal = rentMonthly * income.numMonths;
  final rentTotalNet = rentTotal * (1 - income.topTaxRate);

  final potentialRentMonthly =
      income.rentPerSquareMeter * income.totalSquareMeters;
  final potentialRentMonthlyNet =
      potentialRentMonthly * (1 - income.topTaxRate);
  final potentialRentTotal = potentialRentMonthly * income.numMonths;
  final potentialRentTotalNet = potentialRentTotal * (1 - income.topTaxRate);

  return RentResults(
    rentTotal: rentTotal,
    rentTotalNet: rentTotalNet,
    rentMonthly: rentMonthly,
    rentMonthlyNet: rentMonthlyNet,
    potentialRentTotal: potentialRentTotal,
    potentialRentTotalNet: potentialRentTotalNet,
    potentialRentMonthly: potentialRentMonthly,
    potentialRentMonthlyNet: potentialRentMonthlyNet,
  );
}
