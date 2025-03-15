import 'dart:math';

List<int> generateCombination() {
  Set<int> combination = <int>{};
  final int min = 1, max = 49;
  final random = Random();
  do {
    combination.add(random.nextInt(max) + min);
  } while (combination.length < 6);
  return combination.toList()..sort();
}

Map<String, dynamic> evaluateCombination(
  List<int> userCombination,
  int superNumber,
  List<int> winCombination,
  int winSuperNumber,
) {
  const winTable = {
    1: {'category': '6+', 'amount': 10000000}, // ~€10,000,000
    2: {'category': '6', 'amount': 1000000}, // ~€1,000,000
    3: {'category': '5+', 'amount': 50000}, // ~€50,000
    4: {'category': '5', 'amount': 5000}, // ~€5,000
    5: {'category': '4+', 'amount': 500}, // ~€500
    6: {'category': '4', 'amount': 50}, // ~€50
    7: {'category': '3+', 'amount': 20}, // ~€20
    8: {'category': '3', 'amount': 10}, // ~€10
  };

  final bool superMatch = superNumber == winSuperNumber;
  final int matchingNumbers =
      userCombination.where((int num) => winCombination.contains(num)).length;

  int category = 0;
  if (matchingNumbers == 6 && superMatch) {
    category = 1;
  } else if (matchingNumbers == 6) {
    category = 2;
  } else if (matchingNumbers == 5 && superMatch) {
    category = 3;
  } else if (matchingNumbers == 5) {
    category = 4;
  } else if (matchingNumbers == 4 && superMatch) {
    category = 5;
  } else if (matchingNumbers == 4) {
    category = 6;
  } else if (matchingNumbers == 3 && superMatch) {
    category = 7;
  } else if (matchingNumbers == 3) {
    category = 8;
  }

  return winTable[category] ?? {'category': '0', 'amount': 0};
}
