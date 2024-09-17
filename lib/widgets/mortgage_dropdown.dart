import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/firestore_service.dart';

class MortgageDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return StreamBuilder<List<Mortgage>>(
      stream: firestoreService.getMortgages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final mortgages = snapshot.data!;

        return DropdownButton<Mortgage>(
          hint: Text('Gespeicherte Hypotheken'),
          value: null,
          items: mortgages.map((m) {
            return DropdownMenuItem<Mortgage>(
              value: m,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hypothek ${m.housePrice.toStringAsFixed(0)}€'),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        // Note: This will need to be implemented in FirestoreService
                        await firestoreService.deleteMortgage(m);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Hypothek gelöscht')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fehler beim Löschen: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (selectedMortgage) {
            if (selectedMortgage != null) {
              Provider.of<Mortgage>(context, listen: false)
                  .updateFromMortgage(selectedMortgage);
            }
          },
        );
      },
    );
  }
}
