// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
      id: json['id'] as String,
      name: json['name'] as String,
      score: Score.fromJson(json['score'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'score': instance.score,
      'createdAt': instance.createdAt,
    };

Score _$ScoreFromJson(Map<String, dynamic> json) => Score(
      id: json['id'] as String,
      names: (json['names'] as List<dynamic>).map((e) => e as String).toList(),
      kickes: (json['kickes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      horses: (json['horses'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      money: (json['money'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      winner: (json['winner'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ScoreToJson(Score instance) => <String, dynamic>{
      'id': instance.id,
      'names': instance.names,
      'kickes': instance.kickes,
      'horses': instance.horses,
      'money': instance.money,
      'winner': instance.winner,
    };
