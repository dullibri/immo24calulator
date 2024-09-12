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
    _controller =
        TextEditingController(text: _formatValue(widget.initialValue));
  }

  @override
  void didUpdateWidget(CustomInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = _formatValue(widget.initialValue);
    }
  }

  String _formatValue(double value) {
    if (widget.isPercentage) {
      return _formatter.format(value * 100);
    }
    return _formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
      onChanged: (value) {
        final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
        double? parsedValue = double.tryParse(cleanValue);
        if (parsedValue != null) {
          if (widget.isPercentage) {
            parsedValue /= 100;
          }
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
