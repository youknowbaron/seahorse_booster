import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:seahorse_calculator/models.dart';

class ResultPage extends HookWidget {
  const ResultPage({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: const Duration(milliseconds: 500))
      ..forward()
      ..repeat();

    final mute = useValueNotifier(false);

    final audioPlayer = use(const _AudioPlayerHook('asset:assets/audio/maytuoigi.mp3'));

    useEffect(
      () {
        Hive.openBox('settings').then((box) {
          if (box.get('mute') == true) {
            mute.value = true;
          } else {
            audioPlayer.play();
          }
        });
        return null;
      },
      const [],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Kết quả'),
        actions: [
          IconButton(
            onPressed: () {
              mute.value = !mute.value;
              Hive.openBox('settings').then((box) {
                box.put('mute', mute.value);
              });
              if (mute.value) {
                audioPlayer.stop();
              } else {
                audioPlayer.play();
                audioPlayer.seek(Duration.zero);
              }
            },
            icon: Icon(
              useValueListenable(mute) ? Icons.volume_off : Icons.volume_up,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Chúc mừng chiến thắng ',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text: match.score.winnerName ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.33,
                height: MediaQuery.of(context).size.width * 0.33,
                child: Lottie.asset(
                  'assets/lottie/pepe_radio.json',
                  controller: controller,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
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
                  ...match.score.names.indexed.map(
                    (e) {
                      final index = e.$1;
                      final name = e.$2;
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${index == match.score.winner ? '👑' : ''} $name',
                              style: TextStyle(
                                fontWeight: index == match.score.winner
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${match.score.money[index]} VNĐ',
                              style: TextStyle(
                                fontWeight: index == match.score.winner
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Quay lại'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Hive.box('matches').add(jsonEncode(match));
                        if (context.mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                      child: const Text('Về trang chủ'),
                    ),
                  )
                ],
              )
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
