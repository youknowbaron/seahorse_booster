import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:seahorse_calculator/extensions.dart';
import 'package:seahorse_calculator/models.dart';

class CalculatingPage extends HookWidget {
  const CalculatingPage({super.key, required this.matches});

  final List<Match> matches;

  @override
  Widget build(BuildContext context) {
    final data = useValueNotifier(<String, double>{});

    useEffect(
      () {
        var map = <String, double>{};
        for (var i = 0; i < matches.length; ++i) {
          for (var j = 0; j < matches[i].score.numberOfPlayers; ++j) {
            final name = matches[i].score.names[j];
            final money = matches[i].score.money[j];
            map.update(name, (value) => value + money, ifAbsent: () => money);
          }
        }

        data.value = map;

        return null;
      },
      const [],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tính tiền'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Table(
                border: TableBorder.all(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(4),
                  ),
                  color: Colors.black12,
                ),
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(200),
                  1: FixedColumnWidth(80),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Tên',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Tiền',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...useValueListenable(data).entries.map(
                    (e) {
                      final name = e.key;
                      final money = e.value;
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(name),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('$money VNĐ'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioPlayerHook extends Hook<AudioPlayer> {
  const _AudioPlayerHook(this.url);

  final String url;

  @override
  _AudioPlayerHookState createState() => _AudioPlayerHookState();
}

class _AudioPlayerHookState extends HookState<AudioPlayer, _AudioPlayerHook> {
  late AudioPlayer player;

  @override
  void initHook() {
    super.initHook();
    player = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setUrl(hook.url);
    });
  }

  @override
  AudioPlayer build(BuildContext context) {
    return player;
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
