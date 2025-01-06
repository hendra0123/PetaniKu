import 'package:equatable/equatable.dart';

class Authentication extends Equatable {
  final String? pesan;
  final String? token;

  const Authentication({this.pesan, this.token});

  factory Authentication.fromJson(Map<String, dynamic> json) {
    return Authentication(
      pesan: json['pesan'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'pesan': pesan,
        'token': token,
      };

  Authentication copyWith({
    String? pesan,
    String? token,
  }) {
    return Authentication(
      pesan: pesan ?? this.pesan,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [pesan, token];
}
