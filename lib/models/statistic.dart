part of 'models.dart';

class Statistic extends Equatable {
  final double? nitrogenRequired;
  final double? ureaRequired;
  final double? fertilizerRequired;
  final int? yields;
  final DateTime? createdTime;

  const Statistic({
    this.nitrogenRequired,
    this.ureaRequired,
    this.fertilizerRequired,
    this.yields,
    this.createdTime,
  });

  factory Statistic.fromJson(Map<String, dynamic> json) => Statistic(
        nitrogenRequired: (json['nitrogen_required'] as num?)?.toDouble(),
        ureaRequired: (json['urea_required'] as num?)?.toDouble(),
        fertilizerRequired: (json['fertilizer_required'] as num?)?.toDouble(),
        yields: json['yields'] as int?,
        createdTime:
            json['created_time'] == null ? null : DateTime.parse(json['created_time'] as String),
      );

  Map<String, dynamic> toJson() => {
        'nitrogen_required': nitrogenRequired,
        'urea_required': ureaRequired,
        'fertilizer_required': fertilizerRequired,
        'yields': yields,
        'created_time': createdTime?.toIso8601String(),
      };

  Statistic copyWith({
    double? nitrogenRequired,
    double? ureaRequired,
    double? fertilizerRequired,
    int? yields,
    DateTime? createdTime,
  }) {
    return Statistic(
      nitrogenRequired: nitrogenRequired ?? this.nitrogenRequired,
      ureaRequired: ureaRequired ?? this.ureaRequired,
      fertilizerRequired: fertilizerRequired ?? this.fertilizerRequired,
      yields: yields ?? this.yields,
      createdTime: createdTime ?? this.createdTime,
    );
  }

  @override
  List<Object?> get props {
    return [
      nitrogenRequired,
      ureaRequired,
      fertilizerRequired,
      yields,
      createdTime,
    ];
  }
}
