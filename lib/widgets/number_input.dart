import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInput extends StatefulWidget {
  final int number;
  final bool isValid;
  final Function(String) onChanged;

  const NumberInput({
    super.key,
    required this.number,
    required this.onChanged,
    this.isValid = true,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

String _convertNumber2String(int number) {
  return number > -1 ? number.toString() : '';
}

class _NumberInputState extends State<NumberInput> {
  late TextEditingController controller = TextEditingController(
    text: _convertNumber2String(widget.number),
  );

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.number.toString());
  }

  @override
  void didUpdateWidget(covariant NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.number.toString() != controller.text) {
      final cursorPosition = controller.selection;
      controller.text = _convertNumber2String(widget.number);
      controller.selection = cursorPosition;

      final validOffset = cursorPosition.baseOffset.clamp(
        0,
        controller.text.length,
      );
      controller.selection = TextSelection.collapsed(offset: validOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
        style: TextStyle(color: widget.isValid ? Colors.black : Colors.red),
        maxLength: 2,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.isValid ? Colors.blue : Colors.red,
              width: 2,
            ),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
