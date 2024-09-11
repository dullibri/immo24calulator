import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:immo24calculator/calculations/annuität.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveMortgage(Mortgage mortgage) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userMortgages = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mortgages');

        // Check if user has less than 10 mortgages
        final querySnapshot = await userMortgages.get();
        if (querySnapshot.size >= 10) {
          throw Exception('Maximum number of mortgages reached');
        }

        await userMortgages.add({
          'housePrice': mortgage.housePrice,
          'equity': mortgage.equity,
          'annualInterestRate': mortgage.annualInterestRate,
          'monthlyPayment': mortgage.monthlyPayment,
          'monthlySpecialPayment': mortgage.monthlySpecialPayment,
          'maxSpecialPaymentPercent': mortgage.maxSpecialPaymentPercent,
          'rentalShare': mortgage.rentalShare,
          'topTaxRate': mortgage.topTaxRate,
          'annualDepreciationRate': mortgage.annualDepreciationRate,
          'squareMeters': mortgage.squareMeters,
          'letSquareMeters': mortgage.letSquareMeters,
          'notaryFeesRate': mortgage.notaryFeesRate,
          'landRegistryFeesRate': mortgage.landRegistryFeesRate,
          'brokerCommissionRate': mortgage.brokerCommissionRate,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error saving mortgage: $e');
      rethrow;
    }
  }

  Stream<List<Mortgage>> getMortgages() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mortgages')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                return Mortgage(
                  housePrice: data['housePrice'] ?? 0,
                  equity: data['equity'] ?? 0,
                  annualInterestRate: data['annualInterestRate'] ?? 0,
                  monthlyPayment: data['monthlyPayment'] ?? 0,
                  monthlySpecialPayment: data['monthlySpecialPayment'] ?? 0,
                  maxSpecialPaymentPercent:
                      data['maxSpecialPaymentPercent'] ?? 0,
                  rentalShare: data['rentalShare'] ?? 0,
                  topTaxRate: data['topTaxRate'] ?? 0,
                  annualDepreciationRate: data['annualDepreciationRate'] ?? 0,
                  squareMeters: data['squareMeters'] ?? 0,
                  letSquareMeters: data['letSquareMeters'] ?? 0,
                  notaryFeesRate: data['notaryFeesRate'] ?? 0,
                  landRegistryFeesRate: data['landRegistryFeesRate'] ?? 0,
                  brokerCommissionRate: data['brokerCommissionRate'] ?? 0,
                );
              }).toList());
    }
    return Stream.value([]);
  }
}
