part of 'models.dart';

class Coordinate extends Equatable {
  final double? latitude;
  final double? longitude;

  const Coordinate({this.latitude, this.longitude});

  factory Coordinate.fromJson(Map<String, dynamic> json) => Coordinate(
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  Coordinate copyWith({
    double? latitude,
    double? longitude,
  }) {
    return Coordinate(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
