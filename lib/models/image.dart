part of 'models.dart';

class Image extends Equatable {
  final LatLng? coordinate;
  final int? level;
  final String? url;

  const Image({this.coordinate, this.level, this.url});

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        coordinate: LatLng(
          (json['latitude'] as num).toDouble(),
          (json['longitude'] as num).toDouble(),
        ),
        level: json['level'] as int?,
        url: json['url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'coordinate': coordinate,
        'level': level,
        'url': url,
      };

  Image copyWith({
    LatLng? coordinate,
    int? level,
    String? url,
  }) {
    return Image(
      coordinate: coordinate ?? this.coordinate,
      level: level ?? this.level,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [coordinate, level, url];
}
