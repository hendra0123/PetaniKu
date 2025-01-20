part of 'models.dart';

class User extends Equatable {
  final RiceField? riceField;
  final Summary? summary;
  final String? phone;
  final String? name;

  const User({
    this.riceField,
    this.summary,
    this.phone,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        riceField: json['rice_field'] == null
            ? null
            : RiceField.fromJson(json['rice_field'] as Map<String, dynamic>),
        summary: json['summary'] == null
            ? null
            : Summary.fromJson(json['summary'] as Map<String, dynamic>),
        phone: json['phone'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'rice_field': riceField?.toJson(),
        'summary': summary?.toJson(),
        'phone': phone,
        'name': name,
      };

  User copyWith({
    RiceField? riceField,
    Summary? summary,
    String? phone,
    String? name,
  }) {
    return User(
      riceField: riceField ?? this.riceField,
      summary: summary ?? this.summary,
      phone: phone ?? this.phone,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [riceField, summary, phone, name];
}
