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

// Verwendungsbeispiel:
// String formattedValue = GermanCurrencyFormatter.format(1234567);
// Ausgabe: 1.234.567 €
