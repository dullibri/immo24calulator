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

  double maxWidth;

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
    this.maxWidth = 600.0,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;
  late NumberFormat _formatter;
<<<<<<< HEAD
  String _errorText = ' ';
=======
  String? _errorText;
>>>>>>> 7586ef7 (fixed customInputField)

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

  double _getValidValue(double value) {
    if (widget.minValue != null && value < widget.minValue!) {
      return widget.minValue!;
    }
    if (widget.maxValue != null && value > widget.maxValue!) {
      return widget.maxValue!;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        if (width > 600) {
          width = (width - 16) / 2;
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
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
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
                  setState(() {
                    _errorText = ' ';
                  });
                  widget.onChanged(parsedValue);
                } else {
                  setState(() {
                    _errorText =
                        'Erlaubter Bereich: ${_formatHelperValue(widget.minValue ?? 0)} - ${_formatHelperValue(widget.maxValue ?? double.infinity)} ${widget.suffix}';
                  });
                }
              } catch (e) {
                setState(() {
                  _errorText = 'Ungültige Eingabe';
                });
              }
            } else {
              setState(() {
                _errorText = ' ';
              });
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
              double validValue = _getValidValue(parsedValue);
              _controller.text = _formatter
                  .format(widget.isPercentage ? validValue * 100 : validValue);
              widget.onChanged(validValue);
              setState(() {
                _errorText = ' ';
              });
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
    return value >= (widget.minValue ?? double.negativeInfinity) &&
        value <= (widget.maxValue ?? double.infinity);
  }

  String _formatHelperValue(double value) {
    return _formatter.format(widget.isPercentage ? value * 100 : value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
