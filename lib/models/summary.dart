part of 'models.dart';

class Summary extends Equatable {
  final List<RiceLeaf>? riceLeaves;
  final List<Statistic>? statistic;
  final DateTime? createdTime;
  final String? plantingType;
  final String? season;
  final int? paddyAge;

  const Summary({
    this.riceLeaves,
    this.statistic,
    this.createdTime,
    this.plantingType,
    this.season,
    this.paddyAge,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        riceLeaves: (json['rice_leaves'] as List<dynamic>?)
            ?.map((e) => RiceLeaf.fromJson(e as Map<String, dynamic>))
            .toList(),
        statistic: (json['statistic'] as List<dynamic>?)
            ?.map((e) => Statistic.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdTime: json['created_time'] == null
            ? null
            : DateTime.parse(json['created_time'] as String),
        plantingType: json['planting_type'] as String?,
        season: json['season'] as String?,
        paddyAge: (json['paddy_age'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'rice_leaves': riceLeaves?.map((e) => e.toJson()).toList(),
        'statistic': statistic?.map((e) => e.toJson()).toList(),
        'created_time': createdTime?.toIso8601String(),
        'planting_type': plantingType,
        'season': season,
        'paddy_age': paddyAge,
      };

  Summary copyWith({
    List<RiceLeaf>? riceLeaves,
    List<Statistic>? statistic,
    DateTime? createdTime,
    String? season,
    String? plantingType,
    int? paddyAge,
  }) {
    return Summary(
      riceLeaves: riceLeaves ?? this.riceLeaves,
      statistic: statistic ?? this.statistic,
      createdTime: createdTime ?? this.createdTime,
      plantingType: plantingType ?? this.plantingType,
      season: season ?? this.season,
      paddyAge: paddyAge ?? this.paddyAge,
    );
  }

  @override
  List<Object?> get props {
    return [riceLeaves, statistic, createdTime, plantingType, season, paddyAge];
  }
}
