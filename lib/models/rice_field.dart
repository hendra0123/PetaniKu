part of 'models.dart';

class RiceField extends Equatable {
  final DateTime? createdTime;
  final List<LatLng>? coordinates;
  final num? area;

  const RiceField({this.createdTime, this.coordinates, this.area});

  factory RiceField.fromJson(Map<String, dynamic> json) => RiceField(
        createdTime: json['created_time'] == null
            ? null
            : DateTime.parse(json['created_time'] as String),
        coordinates: (json['coordinates'] as List<dynamic>?)
            ?.map((e) => LatLng(
                  (e['latitude'] as num).toDouble(),
                  (e['longitude'] as num).toDouble(),
                ))
            .toList(),
        area: json['area'] as num,
      );

  Map<String, dynamic> toJson() => {
        'created_time': createdTime?.toIso8601String(),
        'coordinates': coordinates?.map((e) => e.toJson()).toList(),
        'area': area,
      };

  RiceField copyWith({
    DateTime? createdTime,
    List<LatLng>? coordinates,
    num? area,
  }) {
    return RiceField(
      createdTime: createdTime ?? this.createdTime,
      coordinates: coordinates ?? this.coordinates,
      area: area ?? this.area,
    );
  }

  @override
  List<Object?> get props => [createdTime, coordinates, area];
}
