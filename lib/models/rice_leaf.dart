part of 'models.dart';

class RiceLeaf extends Equatable {
  final LatLng? coordinate;
  final int? level;
  final String? url;

  const RiceLeaf({this.coordinate, this.level, this.url});

  factory RiceLeaf.fromJson(Map<String, dynamic> json) => RiceLeaf(
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

  RiceLeaf copyWith({
    LatLng? coordinate,
    int? level,
    String? url,
  }) {
    return RiceLeaf(
      coordinate: coordinate ?? this.coordinate,
      level: level ?? this.level,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [coordinate, level, url];
}
