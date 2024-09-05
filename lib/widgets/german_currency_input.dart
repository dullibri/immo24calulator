import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GermanCurrencyInput extends StatefulWidget {
  final String label;
  final int initialValue;
  final ValueChanged<int> onChanged;
  final bool allowNegative;

  GermanCurrencyInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.allowNegative = false,
  });

  @override
  _GermanCurrencyInputState createState() => _GermanCurrencyInputState();
}

class _GermanCurrencyInputState extends State<GermanCurrencyInput> {
  late TextEditingController _controller;
  final _currencyFormat =
      NumberFormat.currency(locale: 'de_DE', symbol: '€', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _currencyFormat.format(widget.initialValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: '€',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) {
            return newValue;
          }
          final intValue = int.parse(newValue.text);
          final formattedValue = _currencyFormat.format(intValue);
          return TextEditingValue(
            text: formattedValue,
            selection:
                TextSelection.collapsed(offset: formattedValue.length - 2),
          );
        }),
      ],
      onChanged: (value) {
        final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanValue.isNotEmpty) {
          final intValue = int.parse(cleanValue);
          widget.onChanged(intValue);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
