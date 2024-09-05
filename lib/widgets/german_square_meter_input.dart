import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GermanSquareMeterInput extends StatefulWidget {
  final String label;
  final double initialValue;
  final ValueChanged<double> onChanged;

  GermanSquareMeterInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _GermanSquareMeterInputState createState() => _GermanSquareMeterInputState();
}

class _GermanSquareMeterInputState extends State<GermanSquareMeterInput> {
  late TextEditingController _controller;
  final _numberFormat = NumberFormat('#,##0.0', 'de_DE');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _numberFormat.format(widget.initialValue) + ' m²',
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) {
            return newValue;
          }
          String cleanValue = newValue.text
              .replaceAll(' m²', '')
              .replaceAll('.', '')
              .replaceAll(',', '.');
          double? value = double.tryParse(cleanValue);
          if (value != null) {
            String formatted = _numberFormat.format(value) + ' m²';
            return TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length - 3),
            );
          }
          return oldValue;
        }),
      ],
      onChanged: (value) {
        String cleanValue = value
            .replaceAll(' m²', '')
            .replaceAll('.', '')
            .replaceAll(',', '.');
        double? parsedValue = double.tryParse(cleanValue);
        if (parsedValue != null) {
          widget.onChanged(parsedValue);
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
