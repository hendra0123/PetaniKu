part of 'models.dart';

class Prediction extends Equatable {
  final double? ureaRequired;
  final int? yields;
  final int? nitrogenRequired;
  final String? plantingType;
  final DateTime? createdTime;
  final List<RiceLeaf>? riceLeaves;
  final int? paddyAge;
  final RiceField? riceField;
  final double? fertilizerRequired;
  final String? season;

  const Prediction({
    this.ureaRequired,
    this.yields,
    this.nitrogenRequired,
    this.plantingType,
    this.createdTime,
    this.riceLeaves,
    this.paddyAge,
    this.riceField,
    this.fertilizerRequired,
    this.season,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        ureaRequired: (json['urea_required'] as num?)?.toDouble(),
        yields: json['yields'] as int?,
        nitrogenRequired: json['nitrogen_required'] as int?,
        plantingType: json['planting_type'] as String?,
        createdTime:
            json['created_time'] == null ? null : DateTime.parse(json['created_time'] as String),
        riceLeaves: (json['images'] as List<dynamic>?)
            ?.map((e) => RiceLeaf.fromJson(e as Map<String, dynamic>))
            .toList(),
        paddyAge: json['paddy_age'] as int?,
        riceField: json['rice_field'] == null
            ? null
            : RiceField.fromJson(json['rice_field'] as Map<String, dynamic>),
        fertilizerRequired: (json['fertilizer_required'] as num?)?.toDouble(),
        season: json['season'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'urea_required': ureaRequired,
        'yields': yields,
        'nitrogen_required': nitrogenRequired,
        'planting_type': plantingType,
        'created_time': createdTime?.toIso8601String(),
        'images': riceLeaves?.map((e) => e.toJson()).toList(),
        'paddy_age': paddyAge,
        'rice_field': riceField?.toJson(),
        'fertilizer_required': fertilizerRequired,
        'season': season,
      };

  Prediction copyWith({
    double? ureaRequired,
    int? yields,
    int? nitrogenRequired,
    String? plantingType,
    DateTime? createdTime,
    List<RiceLeaf>? images,
    int? paddyAge,
    RiceField? riceField,
    double? fertilizerRequired,
    String? season,
  }) {
    return Prediction(
      ureaRequired: ureaRequired ?? this.ureaRequired,
      yields: yields ?? this.yields,
      nitrogenRequired: nitrogenRequired ?? this.nitrogenRequired,
      plantingType: plantingType ?? this.plantingType,
      createdTime: createdTime ?? this.createdTime,
      riceLeaves: images ?? this.riceLeaves,
      paddyAge: paddyAge ?? this.paddyAge,
      riceField: riceField ?? this.riceField,
      fertilizerRequired: fertilizerRequired ?? this.fertilizerRequired,
      season: season ?? this.season,
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
      riceLeaves,
      paddyAge,
      riceField,
      fertilizerRequired,
      season,
    ];
  }
}
