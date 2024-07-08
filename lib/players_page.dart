import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:seahorse_calculator/models.dart';

class PlayersPage extends HookWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final players = useValueNotifier<List<Player>>([]);

    useEffect(
      () {
        final box = Hive.box('players');
        players.value = box.values.map((e) => Player.fromJson(jsonDecode(e))).toList();
        return null;
      },
      const [],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Danh sách người chơi'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => Dismissible(
            key: ValueKey(index),
            background: Container(
              color: Colors.red,
              child: const Row(
                children: [
                  Spacer(),
                  Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ),
            direction: DismissDirection.endToStart,
            child: ListTile(
              title: Text(players.value[index].name),
            ),
            onDismissed: (direction) {
              final box = Hive.box('players');
              box.delete(players.value[index].name);
            },
          ),
          itemCount: useValueListenable(players).length,
        ),
      ),
    );
  }
}
