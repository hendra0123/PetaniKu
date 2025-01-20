part of 'models.dart';

class RiceLeaf extends Equatable {
  final List<LatLng>? polygon;
  final List<LatLng>? points;
  final int? level;

  const RiceLeaf({
    this.polygon,
    this.points,
    this.level,
  });

  factory RiceLeaf.fromJson(Map<String, dynamic> json) => RiceLeaf(
        polygon: (json['polygon'] as List<dynamic>?)
            ?.map((point) => LatLng(
                (point[0] as num).toDouble(), (point[1] as num).toDouble()))
            .toList(),
        points: (json['points'] as List<dynamic>?)
            ?.map((point) => LatLng(
                (point[0] as num).toDouble(), (point[1] as num).toDouble()))
            .toList(),
        level: json['level'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'polygon':
            polygon?.map((point) => [point.latitude, point.longitude]).toList(),
        'points':
            points?.map((point) => [point.latitude, point.longitude]).toList(),
        'level': level,
      };

  RiceLeaf copyWith({
    List<LatLng>? polygon,
    List<LatLng>? points,
    int? level,
  }) {
    return RiceLeaf(
      polygon: polygon ?? this.polygon,
      points: points ?? this.points,
      level: level ?? this.level,
    );
  }

  @override
  List<Object?> get props => [polygon, points, level];
}
