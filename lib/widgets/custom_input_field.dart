// File: custom_input_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String suffix;
  final double initialValue;
  final ValueChanged<double> onSubmitted;
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
    required this.onSubmitted,
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
  String? _errorText;

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
            errorText: _errorText,
            helperText: _getHelperText(),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
          ],
          onFieldSubmitted: (value) {
            String cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
            double? parsedValue = double.tryParse(cleanValue);
            if (parsedValue != null) {
              if (widget.isPercentage) {
                parsedValue /= 100;
              }
              double validValue = _getValidValue(parsedValue);
              _controller.text = _formatter
                  .format(widget.isPercentage ? validValue * 100 : validValue);
              setState(() {
                _errorText = null;
              });
              widget.onSubmitted(validValue);
            } else {
              setState(() {
                _errorText = 'Ungültige Eingabe';
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
    return _formatter.format(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
