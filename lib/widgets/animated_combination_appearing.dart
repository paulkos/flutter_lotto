import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedCombinationAppearing extends StatefulWidget {
  final List<int> combination;
  final int superNum;

  final Function? onCompleted;
  final Duration interval;

  const AnimatedCombinationAppearing({
    super.key,
    required this.combination,
    required this.superNum,
    this.onCompleted,
    this.interval = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedCombinationAppearing> createState() =>
      _AnimatedCombinationAppearingState();
}

class _AnimatedCombinationAppearingState
    extends State<AnimatedCombinationAppearing> {
  final List<int> _visibleNumbers = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    int index = 0;
    _timer = Timer.periodic(widget.interval, (timer) {
      if (index < widget.combination.length) {
        setState(() {
          _visibleNumbers.add(widget.combination[index]);
        });
      } else if (index == widget.combination.length) {
        setState(() {
          _visibleNumbers.add(widget.superNum);
        });
      } else {
        timer.cancel();
        setState(() {
          widget.onCompleted?.call();
        });
      }
      index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          _visibleNumbers.asMap().entries.map((entry) {
            int index = entry.key;
            int number = entry.value;
            bool isSuperNumber = index == widget.combination.length;
            return _buildNumberBox(number, isSuperNumber);
          }).toList(),
    );
  }

  Widget _buildNumberBox(int number, bool isSuperNumber) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 45,
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          right: 5.0,
          left: isSuperNumber ? 20.0 : 3.0, // Отступ для супер числа
        ),
        padding: const EdgeInsets.all(10.0),
        decoration: _getBoxDecoration(isSuperNumber),
        child: Text('$number', style: _getTextStyle(isSuperNumber)),
      ),
    );
  }

  BoxDecoration _getBoxDecoration(bool isSuperNumber) {
    return BoxDecoration(
      color: isSuperNumber ? Colors.orange : Colors.blue,
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  TextStyle _getTextStyle(bool isSuperNumber) {
    return TextStyle(
      fontSize: isSuperNumber ? 20 : 18,
      color: Colors.white,
      fontWeight: isSuperNumber ? FontWeight.bold : FontWeight.normal,
    );
  }
}
