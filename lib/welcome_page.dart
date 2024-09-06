import 'package:flutter/material.dart';
import 'app_scaffold.dart';
import 'factors_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Willkommen',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Willkommen zum Hypothekenrechner',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Text(
              'Diese App hilft Ihnen bei der Berechnung und Planung Ihrer Hypothek. Sie können:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            _buildFeatureItem(context, 'Hauptfaktoren eingeben',
                'Geben Sie wichtige Details wie Kaufpreis, Eigenkapital und Zinssatz ein.'),
            _buildFeatureItem(context, 'Rahmenwerte anpassen',
                'Passen Sie zusätzliche Faktoren wie Notargebühren und Grundbuchkosten an.'),
            _buildFeatureItem(context, 'Ergebnis anzeigen',
                'Überblicken Sie die Summen und den gesamten Verlauf Ihrer Hypothekenzahlungen.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(description,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
