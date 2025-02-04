import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seahorse_calculator/constants.dart';
import 'package:seahorse_calculator/match_history_page.dart';
import 'package:seahorse_calculator/models.dart';
import 'package:seahorse_calculator/players_page.dart';
import 'package:seahorse_calculator/select_players_page.dart';
import 'package:seahorse_calculator/settings_page.dart';
import 'package:seahorse_calculator/splash_page.dart';
import 'package:uuid/uuid.dart';

void main() async {
  Hive.init(kIsWeb ? null : (await getApplicationDocumentsDirectory()).path);
  await Hive.openBox('players');
  await Hive.openBox('matches');
  final settingsBox = await Hive.openBox('settings');

  final kick = await settingsBox.get('kickPrice') as int?;
  final onStage = await settingsBox.get('onStagePrice') as int?;
  final win = await settingsBox.get('winPrice') as int?;
  if (kick != null) Constants.kickPrice = kick;
  if (onStage != null) Constants.onStagePrice = onStage;
  if (win != null) Constants.winPrice = win;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seahorse Booster',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final errorText = useValueNotifier<String?>(null);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Đá đầu heo'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (useValueListenable(errorText) != null) ...[
                Text(
                  errorText.value!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 40),
              ],
              ElevatedButton(
                onPressed: () {
                  final box = Hive.box('players');
                  if (box.values.length < 2) {
                    errorText.value = 'Phải thêm ít nhất 2 người chơi trước';
                    return;
                  }
                  errorText.value = null;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SelectPlayersPage(),
                    ),
                  );
                },
                child: const Text('Ván mới'),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Nhập tên người chơi'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    errorText.value = 'Nhập tên người chơi trước';
                    return;
                  }
                  final box = Hive.box('players');
                  if (box.get(name) != null) {
                    errorText.value = 'Người chơi đã tồn tại, đăng ký tên khác';
                    return;
                  }
                  final id = const Uuid().v4();
                  final player = Player(id: id, name: name);
                  await box.put(name, jsonEncode(player));
                  errorText.value = null;
                  nameController.text = '';
                },
                child: const Text('Thêm người chơi'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PlayersPage(),
                    ),
                  );
                },
                child: const Text('Danh sách người chơi'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MatchHistoryPage(),
                    ),
                  );
                },
                child: const Text('Lịch sử đấu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
