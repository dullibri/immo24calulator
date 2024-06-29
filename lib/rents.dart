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

RentResults calculateRent({
  required double totalSquareMeters,
  required double letSquareMeters,
  required double rentPerSquareMeter,
  required int numMonths,
  required double topTaxRate,
}) {
  final rentMonthly = rentPerSquareMeter * letSquareMeters;
  final rentMonthlyNet = rentMonthly * (1 - topTaxRate);
  final rentTotal = rentMonthly * numMonths;
  final rentTotalNet = rentTotal * (1 - topTaxRate);

  final potentialRentMonthly = rentPerSquareMeter * totalSquareMeters;
  final potentialRentMonthlyNet = potentialRentMonthly * (1 - topTaxRate);
  final potentialRentTotal = potentialRentMonthly * numMonths;
  final potentialRentTotalNet = potentialRentTotal * (1 - topTaxRate);

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
