import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lotto/widgets/animated_combination_appearing.dart';
import 'package:lotto/utils/lotto_6of48.dart';
import 'dart:math';

class DrawEvaluator extends StatefulWidget {
  final int superNum;
  final List<List<int>> combinations;

  const DrawEvaluator({
    super.key,
    required this.combinations,
    required this.superNum,
  });

  @override
  State<DrawEvaluator> createState() => _DrawEvaluatorState();
}

class _DrawEvaluatorState extends State<DrawEvaluator> {
  late final List<Map<String, dynamic>> details = [];
  late final Map<String, dynamic> result;
  late List<int> winCombination;
  late int winSuperNum;
  bool resultShown = false;
  bool detailShown = false;

  @override
  void initState() {
    super.initState();
    winCombination = generateCombination();
    winSuperNum = Random().nextInt(9);
    _evaluate();
  }

  void _evaluate() {
    int maxGroup = 0, maxWin = 0;
    String totalCategory = 'none';
    for (List<int> combination in widget.combinations) {
      Map<String, dynamic> result = evaluateCombination(
        combination,
        widget.superNum,
        winCombination,
        winSuperNum,
      );

      details.add(result);

      if (maxGroup <= result['amount']) {
        maxGroup = result['amount'];
        totalCategory = result['category'];
      }
      maxWin += (result['amount'] as int);
      print(
        "Win: ${combination.join(',')} => ${result['category']} / ${result['amount']}",
      );
    }
    this.result = {'category': totalCategory, 'amount': maxWin};
  }

  void setDetailShown() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        detailShown = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.results)),
      body: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.win_combination,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          AnimatedCombinationAppearing(
            combination: winCombination,
            superNum: winSuperNum,
            onCompleted:
                () => setState(() {
                  resultShown = true;
                  setDetailShown();
                }),
          ),
          if (resultShown) ...[
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(
                context,
              )!.win_category(result['category'], result['amount']),
            ),
            result['category'] != '0'
                ? Text(
                  AppLocalizations.of(context)!.congratulation,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 146, 132, 12),
                  ),
                )
                : Text(
                  AppLocalizations.of(context)!.condolences,
                  style: TextStyle(fontSize: 14),
                ),
          ],
          if (detailShown) ...[
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: DynamicTable(
                  items:
                      widget.combinations.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final List<int> combination = entry.value;
                        int amount = details[index]['amount'];
                        bool isWinner = (amount > 0);
                        String category = details[index]['category'];
                        String result =
                            isWinner
                                ? AppLocalizations.of(
                                  context,
                                )!.evaluation_details(category, amount)
                                : AppLocalizations.of(context)!.evaluation_nil;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.combination_li(index + 1),
                                ),
                                if (isWinner)
                                  Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                              ],
                            ),
                            Text(combination.join(',')),
                            Text(result),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DynamicTable extends StatelessWidget {
  final List<Widget> items;

  DynamicTable({required this.items});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double minColumnWidth = 200;
    const int maxColumnCount = 5;

    final int columnCount = (screenWidth / minColumnWidth).floor().clamp(
      1,
      maxColumnCount,
    );

    final rows = <TableRow>[];
    for (int i = 0; i < items.length; i += columnCount) {
      final rowItems = items.sublist(
        i,
        (i + columnCount).clamp(0, items.length),
      );

      while (rowItems.length < columnCount) {
        rowItems.add(Column(children: []));
      }

      rows.add(
        TableRow(
          children:
              rowItems.map((item) {
                return Padding(padding: const EdgeInsets.all(10), child: item);
              }).toList(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Table(defaultColumnWidth: const FlexColumnWidth(), children: rows),
    );
  }
}
