import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:seahorse_calculator/counter.dart';
import 'package:seahorse_calculator/history_page.dart';
import 'package:seahorse_calculator/models.dart';

class MatchPage extends StatefulHookWidget {
  const MatchPage({super.key, required this.players});

  final List<Player> players;

  @override
  State<StatefulWidget> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late Match match;

  bool saved = false;

  @override
  void initState() {
    match = Match.fromNames(widget.players.map((e) => e.name).toList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final kickingIndex = useValueNotifier<int?>(null);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (match.score.finished) {
          if (!saved) {
            await Hive.box('matches').add(jsonEncode(match));
            saved = true;
          }

          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          return;
        }
        final result = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thoát ra ngoài?'),
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
        if (result == true && context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Chiến đấu'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(history: match.score.history),
                  ),
                );
              },
              icon: const Icon(Icons.history),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: useValueListenable(kickingIndex) == null
                ? match.score.names.indexed.map(
                    (e) {
                      final index = e.$1;
                      final name = e.$2;
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: match.score.winner == index ? 28 : 20,
                                      fontWeight: FontWeight.w600,
                                      color: match.score.winner == index
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${match.score.money[index]}',
                                    style: TextStyle(
                                        fontSize: 20, color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Đá'),
                                      const SizedBox(width: 8),
                                      CustomizableCounter(
                                        count: match.score.kickes[index].toDouble(),
                                        onIncrement: (c) {
                                          kickingIndex.value = index;
                                        },
                                        canDecrement: false,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Lên ngựa'),
                                      const SizedBox(width: 8),
                                      CustomizableCounter(
                                        count: match.score.horses[index].toDouble(),
                                        maxCount: 4,
                                        onIncrement: (c) {
                                          match.score.onStage(index);
                                          setState(() {});
                                        },
                                        onDecrement: (c) {
                                          match.score.offStage(index);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                  if (match.score.horses[index] == 4) ...[
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: index == match.score.winner,
                                          onChanged: (value) {
                                            if (value == true) {
                                              match.score.win(index);
                                            } else {
                                              match.score.undoWin(index);
                                            }
                                            setState(() {});
                                          },
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            match.score.win(index);
                                            setState(() {});
                                          },
                                          child: const Text('Chiến thắng'),
                                        ),
                                      ],
                                    )
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList()
                : match.score.names.indexed.map(
                    (e) {
                      final index = e.$1;
                      final name = e.$2;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (index != kickingIndex.value) {
                              match.score.kick(kickingIndex.value!, index);
                              setState(() {});
                            }
                            kickingIndex.value = null;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              border: Border(
                                bottom: BorderSide(color: Colors.black45),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              kickingIndex.value == index ? 'Chọn người bị đá' : name,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight:
                                    kickingIndex.value == index ? FontWeight.w500 : FontWeight.w700,
                                color: kickingIndex.value == index ? Colors.white70 : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
          ),
        ),
      ),
    );
  }
}
