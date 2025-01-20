part of 'models.dart';

class Prediction extends Equatable {
  final List<RiceLeaf>? riceLeaves;
  final List<String>? imageUrls;
  final RiceField? riceField;
  final DateTime? createdTime;
  final String? plantingType;
  final String? season;
  final double? ureaRequired;
  final int? paddyAge;
  final double? yield;

  const Prediction({
    this.riceLeaves,
    this.imageUrls,
    this.riceField,
    this.createdTime,
    this.plantingType,
    this.season,
    this.ureaRequired,
    this.paddyAge,
    this.yield,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        riceLeaves: (json['rice_leaves'] as List<dynamic>?)
            ?.map((e) => RiceLeaf.fromJson(e as Map<String, dynamic>))
            .toList(),
        imageUrls: (json['image_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        riceField: json['rice_field'] == null
            ? null
            : RiceField.fromJson(json['rice_field'] as Map<String, dynamic>),
        createdTime:
            json['created_time'] == null ? null : DateTime.parse(json['created_time'] as String),
        plantingType: json['planting_type'] as String?,
        season: json['season'] as String?,
        ureaRequired: (json['urea_required'] as num?)?.toDouble(),
        paddyAge: (json['paddy_age'] as num?)?.toInt(),
        yield: (json['yield'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'rice_leaves': riceLeaves?.map((e) => e.toJson()).toList(),
        'image_urls': imageUrls,
        'rice_field': riceField?.toJson(),
        'created_time': createdTime?.toIso8601String(),
        'planting_type': plantingType,
        'season': season,
        'urea_required': ureaRequired,
        'paddy_age': paddyAge,
        'yield': yield,
      };

  Prediction copyWith({
    List<RiceLeaf>? riceLeaves,
    List<String>? imageUrls,
    RiceField? riceField,
    DateTime? createdTime,
    String? plantingType,
    String? season,
    double? ureaRequired,
    int? paddyAge,
    double? yield,
  }) {
    return Prediction(
      riceLeaves: riceLeaves ?? this.riceLeaves,
      imageUrls: imageUrls ?? this.imageUrls,
      riceField: riceField ?? this.riceField,
      createdTime: createdTime ?? this.createdTime,
      plantingType: plantingType ?? this.plantingType,
      season: season ?? this.season,
      ureaRequired: ureaRequired ?? this.ureaRequired,
      paddyAge: paddyAge ?? this.paddyAge,
      yield: yield ?? this.yield,
    );
  }

  @override
  List<Object?> get props {
    return [
      riceLeaves,
      imageUrls,
      riceField,
      createdTime,
      plantingType,
      season,
      ureaRequired,
      paddyAge,
      yield,
    ];
  }
}
