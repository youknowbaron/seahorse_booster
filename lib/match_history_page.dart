import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:seahorse_calculator/calculating_page.dart';
import 'package:seahorse_calculator/models.dart';

class MatchHistoryPage extends HookWidget {
  const MatchHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = useValueNotifier<List<Match>>([]);
    final isCalculating = useValueNotifier(false);
    final calculatingMatches = useValueNotifier<List<Match>>([]);

    useEffect(
      () {
        final box = Hive.box('matches');
        matches.value = box.values.map((e) => Match.fromJson(jsonDecode(e))).toList();
        return null;
      },
      const [],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Lịch sử đấu'),
        leading: useValueListenable(isCalculating)
            ? IconButton(
                onPressed: () => isCalculating.value = false,
                icon: const Icon(Icons.close),
              )
            : const BackButton(),
        actions: useValueListenable(isCalculating)
            ? [
                IconButton(
                  onPressed: () {
                    if (calculatingMatches.value.isEmpty) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CalculatingPage(matches: calculatingMatches.value),
                      ),
                    );
                  },
                  icon: const Icon(Icons.done),
                ),
              ]
            : [
                IconButton(
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xóa hết lịch sử đấu?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('No 🙅'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('OK 👌'),
                          ),
                        ],
                      ),
                    );
                    if (result == true) {
                      Hive.box('matches').clear();
                      matches.value = [];
                    }
                  },
                  icon: const Icon(Icons.delete_sweep),
                ),
                IconButton(
                  onPressed: () async {
                    isCalculating.value = true;
                  },
                  icon: const Icon(Icons.calculate),
                ),
              ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final match = matches.value[index];
            return HookBuilder(
              builder: (context) => ListTile(
                title: Text(match.createdAt),
                subtitle: Text(match.score.summary),
                leading: useValueListenable(isCalculating)
                    ? Checkbox(
                        value: useValueListenable(calculatingMatches).contains(match),
                        onChanged: (value) {
                          if (value == true) {
                            final newList = calculatingMatches.value..add(match);
                            calculatingMatches.value = [...newList];
                          } else {
                            final newList = calculatingMatches.value
                              ..removeWhere((element) => element.id == match.id);
                            calculatingMatches.value = [...newList];
                          }
                        },
                      )
                    : null,
              ),
            );
          },
          itemCount: useValueListenable(matches).length,
          reverse: true,
        ),
      ),
    );
  }
}
