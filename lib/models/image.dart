part of 'models.dart';

class Image extends Equatable {
  final double? latitude;
  final double? longitude;
  final int? level;
  final String? url;

  const Image({this.latitude, this.longitude, this.level, this.url});

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        level: json['level'] as int?,
        url: json['url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'level': level,
        'url': url,
      };

  Image copyWith({
    double? latitude,
    double? longitude,
    int? level,
    String? url,
  }) {
    return Image(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      level: level ?? this.level,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, level, url];
}
