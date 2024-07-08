import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:seahorse_calculator/match_page.dart';
import 'package:seahorse_calculator/models.dart';

class SelectPlayersPage extends HookWidget {
  const SelectPlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final players = useValueNotifier<List<Player>>([]);
    final values = useValueNotifier<List<bool>>([]);

    useEffect(
      () {
        final box = Hive.box('players');
        players.value = box.values.map((e) => Player.fromJson(jsonDecode(e))).toList();

        final last = Hive.box('matches').values.lastOrNull;
        if (last != null) {
          final lastMatch = Match.fromJson(jsonDecode(last));

          values.value = List.generate(
            players.value.length,
            (i) => lastMatch.score.names.contains(players.value[i].name),
          );
        } else {
          values.value = List.generate(players.value.length, (i) => i < 4);
        }

        return null;
      },
      const [],
    );

    showMessage(String message) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            message,
            style: const TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearMaterialBanners();
              },
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      return;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Danh sách người chơi'),
        actions: [
          IconButton(
            onPressed: () {
              if (values.value.where((element) => element).length < 2) {
                showMessage('Chọn ít nhất 2 người chơi');
                return;
              }

              final pickedPlayers = <Player>[];
              for (var i = 0; i < players.value.length; ++i) {
                if (values.value[i]) pickedPlayers.add(players.value[i]);
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MatchPage(players: pickedPlayers),
                ),
              );
            },
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => HookBuilder(
            builder: (context) => ListTile(
              leading: Checkbox(
                value: useValueListenable(values)[index],
                onChanged: (value) {
                  if (value == true && values.value.where((element) => element).length >= 4) {
                    showMessage('Chỉ chọn tối đa 4 người chơi');
                    return;
                  }
                  values.value[index] = value ?? false;
                  values.value = [...values.value];
                },
              ),
              title: Text(players.value[index].name),
            ),
          ),
          itemCount: useValueListenable(players).length,
        ),
      ),
    );
  }
}
