import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String suffix;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final bool isPercentage;
  final int decimalPlaces;

  CustomInputField({
    required this.label,
    required this.suffix,
    required this.initialValue,
    required this.onChanged,
    this.isPercentage = false,
    this.decimalPlaces = 2,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;
  late NumberFormat _formatter;

  @override
  void initState() {
    super.initState();
    _formatter = NumberFormat.decimalPattern('de_DE');
    _formatter.minimumFractionDigits = widget.decimalPlaces;
    _formatter.maximumFractionDigits = widget.decimalPlaces;

    if (widget.isPercentage) {
      _controller = TextEditingController(
        text: _formatter.format(widget.initialValue * 100),
      );
    } else {
      _controller = TextEditingController(
        text: _formatter.format(widget.initialValue),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: widget.suffix,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
        ],
        onTap: () {
          // Selektiere den gesamten Text beim Antippen des Feldes
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        },
        onChanged: (value) {
          if (value.isNotEmpty) {
            try {
              String cleanValue =
                  value.replaceAll('.', '').replaceAll(',', '.');
              double parsedValue = double.parse(cleanValue);
              if (widget.isPercentage) {
                parsedValue /= 100;
              }
              widget.onChanged(parsedValue);
            } catch (e) {
              // Ungültige Eingabe - nichts tun
            }
          }
        },
        onEditingComplete: () {
          // Formatiere den Wert neu, wenn die Bearbeitung abgeschlossen ist
          String cleanValue =
              _controller.text.replaceAll('.', '').replaceAll(',', '.');
          double? parsedValue = double.tryParse(cleanValue);
          if (parsedValue != null) {
            if (widget.isPercentage) {
              _controller.text = _formatter.format(parsedValue);
            } else {
              _controller.text = _formatter.format(parsedValue);
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
