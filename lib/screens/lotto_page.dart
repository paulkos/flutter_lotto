import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotto/screens/draw_evaluator.dart';
import 'package:lotto/widgets/combination_input.dart';
import 'package:lotto/utils/lotto_6of48.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LottoPage extends StatefulWidget {
  const LottoPage({super.key});

  @override
  State<LottoPage> createState() => _LottoPageState();
}

class _LottoPageState extends State<LottoPage> {
  static const int maxCombinationCount = 30;
  final ScrollController scroller = ScrollController();
  final textController = TextEditingController(text: '');
  List<List<int>> combinations = [generateCombination()];
  int superNum = -1;
  bool _addingAllowed = true;

  @override
  void dispose() {
    scroller.dispose();
    super.dispose();
  }

  void _addNewCombination(AppLocalizations? l10n) {
    if (combinations.length > maxCombinationCount && _addingAllowed) {
      _addingAllowed = false;
      final snackBar = SnackBar(
        content: Text(l10n!.combination_limit_exceeded),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_) {
        setState(() {
          _addingAllowed = true;
        });
      });
    } else if (_addingAllowed) {
      setState(() {
        combinations.add(generateCombination());
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scroller.hasClients &&
            scroller.position.pixels < scroller.position.maxScrollExtent) {
          scroller.animateTo(
            scroller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _removeCombinations() {
    setState(() {
      combinations = [CombinationInput.empty()];
      superNum = -1;
    });
  }

  void _removeCombination(int index) {
    if (combinations.length > 1) {
      setState(() {
        combinations.removeAt(index);
      });
    }
  }

  bool _checkSuperNum(AppLocalizations? l10n) {
    if (superNum < 0) {
      final snackBar = SnackBar(
        content: Text(l10n!.super_num_missing),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    } else {
      return true;
    }
  }

  void _checkResults(AppLocalizations? l10n) {
    if (!_checkSuperNum(l10n)) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                DrawEvaluator(combinations: combinations, superNum: superNum),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    textController.text = superNum >= 0 ? superNum.toString() : '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n!.lotto_6_49)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n!.input_combination, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: scroller,
                itemCount: combinations.length,
                itemBuilder: (context, index) {
                  return CombinationInput(
                    index: index,
                    combination: combinations[index],
                    onCombinationChanged: (newCombination) {
                      setState(() {
                        combinations[index] = newCombination;
                      });
                    },
                    onRemoveCombination: () => _removeCombination(index),
                    isLastCombination: index == combinations.length - 1,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            superNumberInput(l10n),
            const SizedBox(height: 20),
            buttonBar(l10n),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget superNumberInput(AppLocalizations? l10n) {
    return Row(
      children: [
        Text(l10n!.input_super_num, style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        SizedBox(
          width: 35,
          child: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            maxLength: 2,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: '0-9',
              counterText: '',
              border: OutlineInputBorder(),
              fillColor: Color.fromARGB(255, 177, 214, 245),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            ),
            onChanged: (String value) {
              if (value.isEmpty) {
                setState(() {
                  superNum = -1;
                });
                return;
              }
              setState(() {
                int tmp = int.tryParse(value.split('').last) ?? 0;
                superNum = (tmp >= 0 && tmp <= 9) ? tmp : 0;
                textController.text = superNum.toString();
                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: 1),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buttonBar(AppLocalizations? l10n) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _addNewCombination(l10n),
          child: Text(l10n!.add_combination),
        ),
        ElevatedButton(
          onPressed: () => _checkResults(l10n),
          child: Text(l10n!.evaluate),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _removeCombinations,
          child: Text(l10n!.reset),
        ),
      ],
    );
  }
}
