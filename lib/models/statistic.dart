part of 'models.dart';

class Statistic extends Equatable {
  final DateTime? createdTime;
  final double? ureaRequired;
  final double? yield;

  const Statistic({
    this.yield,
    this.ureaRequired,
    this.createdTime,
  });

  factory Statistic.fromJson(Map<String, dynamic> json) => Statistic(
        createdTime: json['created_time'] == null
            ? null
            : DateTime.parse(json['created_time'] as String),
        ureaRequired: (json['urea_required'] as num?)?.toDouble(),
        yield: (json['yield'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'created_time': createdTime?.toIso8601String(),
        'urea_required': ureaRequired,
        'yield': yield,
      };

  Statistic copyWith({
    DateTime? createdTime,
    double? ureaRequired,
    double? yield,
  }) {
    return Statistic(
      createdTime: createdTime ?? this.createdTime,
      ureaRequired: ureaRequired ?? this.ureaRequired,
      yield: yield ?? this.yield,
    );
  }

  @override
  List<Object?> get props {
    return [
      createdTime,
      ureaRequired,
      yield,
    ];
  }
}
