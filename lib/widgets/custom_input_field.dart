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
  final double maxWidth;
  final double? minValue;
  final double? maxValue;
  final String? tooltip;

  CustomInputField({
    required this.label,
    required this.suffix,
    required this.initialValue,
    required this.onChanged,
    this.isPercentage = false,
    this.decimalPlaces = 2,
    this.maxWidth = 400,
    this.minValue,
    this.maxValue,
    this.tooltip,
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

    double initialValue = widget.initialValue;
    if (widget.isPercentage) {
      initialValue *= 100;
    }
    _controller = TextEditingController(
      text: _formatter.format(initialValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        if (width > 600) {
          width = (width - 16) / 2; // Two columns with 16px spacing
        }
        if (width > widget.maxWidth) {
          width = widget.maxWidth;
        }

        Widget inputField = TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            suffixIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.suffix, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            helperText: _getHelperText(),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
          ],
          onTap: () {
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
                if (_isValueInRange(parsedValue)) {
                  widget.onChanged(parsedValue);
                } else {
                  // Zeige eine Fehlermeldung an, wenn der Wert außerhalb des erlaubten Bereichs liegt
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Wert außerhalb des erlaubten Bereichs')),
                  );
                }
              } catch (e) {
                // Ungültige Eingabe - nichts tun
              }
            }
          },
          onEditingComplete: () {
            String cleanValue =
                _controller.text.replaceAll('.', '').replaceAll(',', '.');
            double? parsedValue = double.tryParse(cleanValue);
            if (parsedValue != null) {
              if (widget.isPercentage) {
                parsedValue /= 100;
              }
              if (_isValueInRange(parsedValue)) {
                _controller.text = _formatter.format(
                    widget.isPercentage ? parsedValue * 100 : parsedValue);
              } else {
                // Setze den Wert auf den nächstgelegenen gültigen Wert
                double validValue = _getValidValue(parsedValue);
                _controller.text = _formatter.format(
                    widget.isPercentage ? validValue * 100 : validValue);
                widget.onChanged(validValue);
              }
            }
          },
        );

        if (widget.tooltip != null) {
          inputField = Tooltip(
            message: widget.tooltip!,
            child: inputField,
          );
        }

        return Container(
          width: width,
          child: inputField,
        );
      },
    );
  }

  bool _isValueInRange(double value) {
    if (widget.minValue != null && value < widget.minValue!) {
      return false;
    }
    if (widget.maxValue != null && value > widget.maxValue!) {
      return false;
    }
    return true;
  }

  double _getValidValue(double value) {
    if (widget.minValue != null && value < widget.minValue!) {
      return widget.minValue!;
    }
    if (widget.maxValue != null && value > widget.maxValue!) {
      return widget.maxValue!;
    }
    return value;
  }

  String? _getHelperText() {
    if (widget.minValue != null && widget.maxValue != null) {
      return 'Von ${_formatHelperValue(widget.minValue!)} bis ${_formatHelperValue(widget.maxValue!)} ${widget.suffix}';
    } else if (widget.minValue != null) {
      return 'Min: ${_formatHelperValue(widget.minValue!)} ${widget.suffix}';
    } else if (widget.maxValue != null) {
      return 'Max: ${_formatHelperValue(widget.maxValue!)} ${widget.suffix}';
    }
    return null;
  }

  String _formatHelperValue(double value) {
    if (widget.isPercentage) {
      value *= 100;
    }
    return _formatter.format(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
