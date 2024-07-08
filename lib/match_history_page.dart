import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:seahorse_calculator/models.dart';

class MatchHistoryPage extends HookWidget {
  const MatchHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = useValueNotifier<List<Match>>([]);

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
        actions: [
          IconButton(
            onPressed: () {
              Hive.box('matches').clear();
              matches.value = [];
            },
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => ListTile(
            title: Text(matches.value[index].id),
            subtitle: Text(matches.value[index].score.summary),
          ),
          itemCount: useValueListenable(matches).length,
        ),
      ),
    );
  }
}
