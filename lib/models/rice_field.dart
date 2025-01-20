part of 'models.dart';

class RiceField extends Equatable {
  final DateTime? createdTime;
  final List<LatLng>? polygon;
  final double? maxYield;
  final double? area;

  const RiceField({
    this.createdTime,
    this.polygon,
    this.maxYield,
    this.area,
  });

  factory RiceField.fromJson(Map<String, dynamic> json) => RiceField(
        createdTime: json['created_time'] == null
            ? null
            : DateTime.parse(json['created_time'] as String),
        polygon: (json['polygon'] as List<dynamic>?)
            ?.map((point) => LatLng(
                (point[0] as num).toDouble(), (point[1] as num).toDouble()))
            .toList(),
        maxYield: (json['max_yield'] as num?)?.toDouble(),
        area: (json['area'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'created_time': createdTime?.toIso8601String(),
        'polygon':
            polygon?.map((point) => [point.latitude, point.longitude]).toList(),
        'max_yield': maxYield,
        'area': area,
      };

  RiceField copyWith({
    DateTime? createdTime,
    List<LatLng>? polygon,
    double? maxYield,
    double? area,
  }) {
    return RiceField(
      createdTime: createdTime ?? this.createdTime,
      polygon: polygon ?? this.polygon,
      maxYield: maxYield ?? this.maxYield,
      area: area ?? this.area,
    );
  }

  @override
  List<Object?> get props => [createdTime, polygon, maxYield, area];
}
