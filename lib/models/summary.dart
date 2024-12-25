part of 'models.dart';

class Summary extends Equatable {
  final String? season;
  final int? paddyAge;
  final String? plantingType;
  final List<Image>? images;
  final DateTime? createdTime;
  final List<Statistic>? statistics;

  const Summary({
    this.season,
    this.paddyAge,
    this.plantingType,
    this.images,
    this.createdTime,
    this.statistics,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        season: json['season'] as String?,
        paddyAge: json['paddy_age'] as int?,
        plantingType: json['planting_type'] as String?,
        images: (json['images'] as List<dynamic>?)
            ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdTime:
            json['created_time'] == null ? null : DateTime.parse(json['created_time'] as String),
        statistics: (json['statistics'] as List<dynamic>?)
            ?.map((e) => Statistic.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'season': season,
        'paddy_age': paddyAge,
        'planting_type': plantingType,
        'images': images?.map((e) => e.toJson()).toList(),
        'created_time': createdTime?.toIso8601String(),
        'statistics': statistics?.map((e) => e.toJson()).toList(),
      };

  Summary copyWith({
    String? season,
    int? paddyAge,
    String? plantingType,
    List<Image>? images,
    DateTime? createdTime,
    List<Statistic>? statistics,
  }) {
    return Summary(
      season: season ?? this.season,
      paddyAge: paddyAge ?? this.paddyAge,
      plantingType: plantingType ?? this.plantingType,
      images: images ?? this.images,
      createdTime: createdTime ?? this.createdTime,
      statistics: statistics ?? this.statistics,
    );
  }

  @override
  List<Object?> get props {
    return [
      season,
      paddyAge,
      plantingType,
      images,
      createdTime,
      statistics,
    ];
  }
}
