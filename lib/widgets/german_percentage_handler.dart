import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GermanPercentageHandler {
  static final NumberFormat _percentFormat =
      NumberFormat.percentPattern('de_DE');

  static String format(double value, {int decimalPlaces = 2}) {
    _percentFormat.minimumFractionDigits = decimalPlaces;
    _percentFormat.maximumFractionDigits = decimalPlaces;
    return _percentFormat.format(value /
        100); // Teilen durch 100, da der Wert bereits als Prozent vorliegt
  }

  static double? parse(String value) {
    if (value.isEmpty) return null;
    String cleanValue = value.replaceAll('%', '').trim().replaceAll(',', '.');
    return double.tryParse(
        cleanValue); // Nicht durch 100 teilen, da wir den Prozentwert direkt wollen
  }

  static TextInputFormatter getInputFormatter() {
    return _PercentageInputFormatter();
  }
}

class _PercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String cleanValue = newValue.text.replaceAll(RegExp(r'[^0-9,.]'), '');
    cleanValue = cleanValue.replaceAll('.', ',');

    if (cleanValue.split(',').length > 2) {
      cleanValue = cleanValue.replaceFirst(
          RegExp(r',.*$'), ',${cleanValue.split(',').last}');
    }

    List<String> parts = cleanValue.split(',');
    if (parts.length > 1 && parts[1].length > 2) {
      parts[1] = parts[1].substring(0, 2);
      cleanValue = parts.join(',');
    }

    return TextEditingValue(
      text: cleanValue,
      selection: TextSelection.collapsed(offset: cleanValue.length),
    );
  }
}

class GermanPercentageInput extends StatefulWidget {
  final String label;
  final double initialValue;
  final ValueChanged<double?> onChanged;

  GermanPercentageInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _GermanPercentageInputState createState() => _GermanPercentageInputState();
}

class _GermanPercentageInputState extends State<GermanPercentageInput> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: GermanPercentageHandler.format(widget.initialValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: '%',
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        GermanPercentageHandler.getInputFormatter(),
      ],
      onTap: () {
        if (!_isEditing) {
          setState(() {
            _controller.text = '';
            _isEditing = true;
          });
        }
      },
      onChanged: (value) {
        double? parsedValue = GermanPercentageHandler.parse(value);
        widget.onChanged(parsedValue);
      },
      onEditingComplete: () {
        setState(() {
          _isEditing = false;
          double? value = GermanPercentageHandler.parse(_controller.text);
          if (value != null) {
            _controller.text = GermanPercentageHandler.format(value);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
