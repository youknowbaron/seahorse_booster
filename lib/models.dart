import 'package:json_annotation/json_annotation.dart';
import 'package:seahorse_calculator/constants.dart';
import 'package:uuid/uuid.dart';

part 'models.g.dart';

@JsonSerializable()
class Player {
  final String id;
  final String name;

  Player({required this.id, required this.name});

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

@JsonSerializable()
class Match {
  final String id;
  final String name;
  final Score score;

  Match({required this.id, required this.name, required this.score});

  factory Match.fromNames(List<String> names) {
    return Match(
      id: const Uuid().v4(),
      name: '',
      score: Score(
        id: const Uuid().v4(),
        names: names,
        kickes: List.filled(names.length, 0),
        horses: List.filled(names.length, 0),
        money: List.filled(names.length, 0),
      ),
    );
  }

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  Map<String, dynamic> toJson() => _$MatchToJson(this);
}

@JsonSerializable()
class Score {
  final String id;
  final List<String> names;
  final List<int> kickes;
  final List<int> horses;
  final List<double> money;
  int? winner;

  final List<String> history = [];

  int get numberOfPlayers => names.length;

  // bool get finished => horses.where((element) => element >= 4).isNotEmpty;
  bool get finished => winner != null;

  String get summary => names.indexed.map((e) {
        final index = e.$1;
        final name = e.$2;
        return '$name ${money[index]}';
      }).join(' | ');

  void kick(int kick, int victim) {
    ++kickes[kick];
    --kickes[victim];
    money[kick] += Constants.kickPrice;
    money[victim] -= Constants.kickPrice;
    history.add('${DateTime.now().toIso8601String()}: ${names[kick]} đá đầu heo ${names[victim]}');
  }

  void onStage(int index) {
    ++horses[index];
    for (var i = 0; i < numberOfPlayers; ++i) {
      money[i] +=
          index == i ? Constants.onStagePrice * (numberOfPlayers - 1) : -Constants.onStagePrice;
    }
    history.add('${DateTime.now().toIso8601String()}: ${names[index]} lên ngựa');
  }

  void offStage(int index) {
    --horses[index];
    for (var i = 0; i < numberOfPlayers; ++i) {
      money[i] +=
          index == i ? -Constants.onStagePrice * (numberOfPlayers - 1) : Constants.onStagePrice;
    }
    history.add('${DateTime.now().toIso8601String()}: ${names[index]} xuống ngựa');
  }

  void win(int index) {
    if (winner != null) undoWin(winner!);
    winner = index;
    for (var i = 0; i < numberOfPlayers; ++i) {
      money[i] += index == i ? Constants.winPrice * (numberOfPlayers - 1) : -Constants.winPrice;
    }
    history.add('${DateTime.now().toIso8601String()}: ${names[index]} chiến thắng');
  }

  void undoWin(int index) {
    winner = null;
    for (var i = 0; i < numberOfPlayers; ++i) {
      money[i] += index == i ? -Constants.winPrice * (numberOfPlayers - 1) : Constants.winPrice;
    }
    history.add('${DateTime.now().toIso8601String()}: ${names[index]} bị hủy chiến thắng');
  }

  Score({
    required this.id,
    required this.names,
    required this.kickes,
    required this.horses,
    required this.money,
    this.winner,
  });

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreToJson(this);
}
