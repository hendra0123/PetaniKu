part of 'models.dart';

class Prediction extends Equatable {
  final double? ureaRequired;
  final int? yields;
  final int? nitrogenRequired;
  final String? plantingType;
  final DateTime? createdTime;
  final List<Image>? images;
  final int? paddyAge;
  final List<RiceField>? riceField;
  final double? fertilizerRequired;
  final String? season;
  final int? area;

  const Prediction({
    this.ureaRequired,
    this.yields,
    this.nitrogenRequired,
    this.plantingType,
    this.createdTime,
    this.images,
    this.paddyAge,
    this.riceField,
    this.fertilizerRequired,
    this.season,
    this.area,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        ureaRequired: (json['urea_required'] as num?)?.toDouble(),
        yields: json['yields'] as int?,
        nitrogenRequired: json['nitrogen_required'] as int?,
        plantingType: json['planting_type'] as String?,
        createdTime:
            json['created_time'] == null ? null : DateTime.parse(json['created_time'] as String),
        images: (json['images'] as List<dynamic>?)
            ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
            .toList(),
        paddyAge: json['paddy_age'] as int?,
        riceField: (json['rice_field'] as List<dynamic>?)
            ?.map((e) => RiceField.fromJson(e as Map<String, dynamic>))
            .toList(),
        fertilizerRequired: (json['fertilizer_required'] as num?)?.toDouble(),
        season: json['season'] as String?,
        area: json['area'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'urea_required': ureaRequired,
        'yields': yields,
        'nitrogen_required': nitrogenRequired,
        'planting_type': plantingType,
        'created_time': createdTime?.toIso8601String(),
        'images': images?.map((e) => e.toJson()).toList(),
        'paddy_age': paddyAge,
        'rice_field': riceField?.map((e) => e.toJson()).toList(),
        'fertilizer_required': fertilizerRequired,
        'season': season,
        'area': area,
      };

  Prediction copyWith({
    double? ureaRequired,
    int? yields,
    int? nitrogenRequired,
    String? plantingType,
    DateTime? createdTime,
    List<Image>? images,
    int? paddyAge,
    List<RiceField>? riceField,
    double? fertilizerRequired,
    String? season,
    int? area,
  }) {
    return Prediction(
      ureaRequired: ureaRequired ?? this.ureaRequired,
      yields: yields ?? this.yields,
      nitrogenRequired: nitrogenRequired ?? this.nitrogenRequired,
      plantingType: plantingType ?? this.plantingType,
      createdTime: createdTime ?? this.createdTime,
      images: images ?? this.images,
      paddyAge: paddyAge ?? this.paddyAge,
      riceField: riceField ?? this.riceField,
      fertilizerRequired: fertilizerRequired ?? this.fertilizerRequired,
      season: season ?? this.season,
      area: area ?? this.area,
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
      images,
      paddyAge,
      riceField,
      fertilizerRequired,
      season,
      area,
    ];
  }
}
