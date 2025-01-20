part of 'models.dart';

class History extends Equatable {
  final DateTime? createdTime;
  final String? predictionId;
  final String? imageUrl;
  final double? ureaRequired;
  final double? yield;

  const History({
    this.createdTime,
    this.predictionId,
    this.imageUrl,
    this.ureaRequired,
    this.yield,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        createdTime:
            json['created_time'] == null ? null : DateTime.parse(json['created_time'] as String),
        predictionId: json['prediction_id'] as String?,
        imageUrl: json['image_url'] as String?,
        ureaRequired: (json['urea_required'] as num?)?.toDouble(),
        yield: (json['yield'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'created_time': createdTime?.toIso8601String(),
        'prediction_id': predictionId,
        'image_url': imageUrl,
        'urea_required': ureaRequired,
        'yield': yield,
      };

  History copyWith({
    DateTime? createdTime,
    String? predictionId,
    String? imageUrl,
    double? ureaRequired,
    double? yield,
  }) {
    return History(
      createdTime: createdTime ?? this.createdTime,
      predictionId: predictionId ?? this.predictionId,
      imageUrl: imageUrl ?? this.imageUrl,
      ureaRequired: ureaRequired ?? this.ureaRequired,
      yield: yield ?? this.yield,
    );
  }

  @override
  List<Object?> get props {
    return [
      createdTime,
      predictionId,
      imageUrl,
      ureaRequired,
      yield,
    ];
  }
}
