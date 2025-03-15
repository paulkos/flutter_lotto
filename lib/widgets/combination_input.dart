import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lotto/widgets/number_input.dart';
import 'dart:math';

class CombinationInput extends StatelessWidget {
  final int index;
  final List<int> combination;
  final bool isLastCombination;
  final Function(List<int>) onCombinationChanged;
  final Function() onRemoveCombination;

  const CombinationInput({
    super.key,
    required this.index,
    required this.combination,
    required this.isLastCombination,
    required this.onCombinationChanged,
    required this.onRemoveCombination,
  }) : assert(combination.length == 6 && index >= 0);

  bool isValid(int value, List<int> unavailable) {
    return value >= 0 && value <= 50 && !unavailable.contains(value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.combination_li(index + 1)),
            Row(
              children: [
                ...List.generate(6, (ix) {
                  List<int> used = [
                    ...combination.sublist(0, ix),
                    ...combination.sublist(min(combination.length, ix + 1)),
                  ];
                  return NumberInput(
                    number: combination[ix],
                    isValid: isValid(combination[ix], used),
                    onChanged: (String string) {
                      final combi = List<int>.from(combination);
                      combi[ix] = int.tryParse(string) ?? 0;
                      onCombinationChanged(combi);
                    },
                  );
                }),
                if (index != 0) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.delete),
                    tooltip: AppLocalizations.of(context)!.remove,
                    onPressed: onRemoveCombination,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static List<int> empty() => List.generate(6, (_) => -1);
}
