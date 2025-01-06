part of 'models.dart';

class User extends Equatable {
  final String? phone;
  final String? name;
  final Summary? summary;
  final RiceField? riceField;

  const User({this.phone, this.name, this.summary, this.riceField});

  factory User.fromJson(Map<String, dynamic> json) => User(
        phone: json['phone'] as String?,
        name: json['name'] as String?,
        summary: json['summary'] == null
            ? null
            : Summary.fromJson(json['summary'] as Map<String, dynamic>),
        riceField: json['rice_field'] == null
            ? null
            : RiceField.fromJson(json['rice_field'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'name': name,
        'summary': summary?.toJson(),
        'rice_field': riceField?.toJson(),
      };

  User copyWith({
    String? phone,
    String? name,
    Summary? summary,
    RiceField? riceField,
  }) {
    return User(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      riceField: riceField ?? this.riceField,
    );
  }

  @override
  List<Object?> get props => [phone, name, summary, riceField];
}
