import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

class GermanCurrencyFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 0,
  );

  static String format(num value) {
    return _currencyFormat.format(value);
  }
}

class MaskedInputScreen extends StatefulWidget {
  @override
  _MaskedInputScreenState createState() => _MaskedInputScreenState();
}

class _MaskedInputScreenState extends State<MaskedInputScreen> {
  var _controller = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: '€ ',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eingabe mit Formatierung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Betrag eingeben',
              ),
            ),
            SizedBox(height: 20),
            Text('Eingegebener Wert: ${_controller.text}'),
          ],
        ),
      ),
    );
  }
}
// Verwendungsbeispiel:
// String formattedValue = GermanCurrencyFormatter.format(1234567);
// Ausgabe: 1.234.567 €
