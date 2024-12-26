part of 'models.dart';

class History extends Equatable {
  final double? ureaRequired;
  final int? yields;
  final int? nitrogenRequired;
  final String? plantingType;
  final DateTime? createdTime;
  final int? paddyAge;
  final double? fertilizerRequired;
  final String? season;
  final String? predictionId;

  const History({
    this.ureaRequired,
    this.yields,
    this.nitrogenRequired,
    this.plantingType,
    this.createdTime,
    this.paddyAge,
    this.fertilizerRequired,
    this.season,
    this.predictionId,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        ureaRequired: (json['urea_required'] as num?)?.toDouble(),
        yields: json['yields'] as int?,
        nitrogenRequired: json['nitrogen_required'] as int?,
        plantingType: json['planting_type'] as String?,
        createdTime: json['created_time'] == null
            ? null
            : DateTime.parse(json['created_time'] as String),
        paddyAge: json['paddy_age'] as int?,
        fertilizerRequired: (json['fertilizer_required'] as num?)?.toDouble(),
        season: json['season'] as String?,
        predictionId: json['prediction_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'urea_required': ureaRequired,
        'yields': yields,
        'nitrogen_required': nitrogenRequired,
        'planting_type': plantingType,
        'created_time': createdTime?.toIso8601String(),
        'paddy_age': paddyAge,
        'fertilizer_required': fertilizerRequired,
        'season': season,
        'prediction_id': predictionId,
      };

  History copyWith({
    double? ureaRequired,
    int? yields,
    int? nitrogenRequired,
    String? plantingType,
    DateTime? createdTime,
    int? paddyAge,
    double? fertilizerRequired,
    String? season,
    String? predictionId,
  }) {
    return History(
      ureaRequired: ureaRequired ?? this.ureaRequired,
      yields: yields ?? this.yields,
      nitrogenRequired: nitrogenRequired ?? this.nitrogenRequired,
      plantingType: plantingType ?? this.plantingType,
      createdTime: createdTime ?? this.createdTime,
      paddyAge: paddyAge ?? this.paddyAge,
      fertilizerRequired: fertilizerRequired ?? this.fertilizerRequired,
      season: season ?? this.season,
      predictionId: predictionId ?? this.predictionId,
    );
  }

  @override
  List<Object?> get props {
    return [
      ureaRequired,
      yields,
      nitrogenRequired,
      plantingType,
      createdTime,
      paddyAge,
      fertilizerRequired,
      season,
      predictionId,
    ];
  }
}
