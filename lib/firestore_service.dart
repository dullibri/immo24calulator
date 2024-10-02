import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/naming.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreService()
      : _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance {
    if (kDebugMode) {
      _firestore.useFirestoreEmulator('localhost', 8080);
      _auth.useAuthEmulator('localhost', 9099);
    }
  }

  Future<String> generateUniqueMortgageName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userMortgages =
          _firestore.collection('users').doc(user.uid).collection('mortgages');

      String newName;
      bool isUnique = false;

      do {
        newName = naming();
        final existingMortgage =
            await userMortgages.where('mortgageName', isEqualTo: newName).get();
        isUnique = existingMortgage.docs.isEmpty;
      } while (!isUnique);

      return newName;
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<void> saveMortgage(Mortgage mortgage) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userMortgages = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mortgages');

        if (mortgage.mortgageName.isEmpty) {
          mortgage.updateMortgageName(await generateUniqueMortgageName());
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
          'mortgageName': mortgage.mortgageName,
        });
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error saving mortgage: $e');
      rethrow;
    }
  }

  Stream<List<MortgageWithId>> get mortgagesStream {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mortgages')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                return MortgageWithId(
                  id: doc.id,
                  mortgage: Mortgage(
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
                    mortgageName: data['mortgageName'] ?? naming(),
                  ),
                );
              }).toList());
    }
    return Stream.value([]);
  }

  Future<void> deleteMortgage(String id) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mortgages')
            .doc(id)
            .delete();
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error deleting mortgage: $e');
      rethrow;
    }
  }
}

class MortgageWithId {
  final String id;
  final Mortgage mortgage;

  MortgageWithId({required this.id, required this.mortgage});
}
