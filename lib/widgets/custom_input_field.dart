import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String suffix;
  final double initialValue;
  final Function(double) onChanged;
  final int? decimalPlaces;
  final double minValue;
  final double maxValue;
  final String tooltip;
  final bool isPercentage;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.suffix,
    required this.initialValue,
    required this.onChanged,
    this.decimalPlaces,
    required this.minValue,
    required this.maxValue,
    required this.tooltip,
    this.isPercentage = false,
  }) : super(key: key);

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late double _lastValidValue;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _lastValidValue = widget.initialValue;
    _controller = TextEditingController(text: _formatValue(_lastValidValue));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndUpdateValue(_controller.text);
    } else {
      _controller.clear();
    }
  }

  String _formatValue(double value) {
    if (widget.isPercentage) {
      return (value * 100)
              .toStringAsFixed(widget.decimalPlaces ?? 2)
              .replaceAll('.', ',') +
          '%';
    }
    return value
        .toStringAsFixed(widget.decimalPlaces ?? 2)
        .replaceAll('.', ',');
  }

  double? _parseValue(String value) {
    final cleanedValue =
        value.replaceAll('.', '').replaceAll(',', '.').replaceAll('%', '');
    return double.tryParse(cleanedValue);
  }

  void _validateAndUpdateValue(String input) {
    final parsedValue = _parseValue(input);
    if (parsedValue != null) {
      double valueToValidate =
          widget.isPercentage ? parsedValue / 100 : parsedValue;
      if (valueToValidate >= widget.minValue &&
          valueToValidate <= widget.maxValue) {
        setState(() {
          _lastValidValue = valueToValidate;
          _controller.text = _formatValue(_lastValidValue);
          _hasError = false;
        });
        widget.onChanged(_lastValidValue);
      } else {
        _setError();
      }
    } else {
      _setError();
    }
  }

  void _setError() {
    setState(() {
      _controller.text = _formatValue(_lastValidValue);
      _hasError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        width: 200,
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixText: widget.isPercentage
                ? null
                : widget.suffix, // Entfernen Sie das Suffix für Prozentfelder
            border: OutlineInputBorder(),
            errorText: _hasError ? 'Ungültige Eingabe' : null,
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\%]')),
          ],
          onChanged: (value) {
            // Wir warten hier mit der Validierung, bis der Fokus verloren geht
          },
        ),
      ),
    );
  }
}
