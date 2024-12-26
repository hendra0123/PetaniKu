class AppException implements Exception {
  final String _message;
  final String _prefix;

  AppException(this._message, this._prefix);

  @override
  String toString() {
    return '$_prefix: $_message';
  }
}

class FetchDataException extends AppException {
  FetchDataException(String message)
      : super(message, 'Terjadi kesalahan saat berkomunikasi ke server');
}

class BadRequestException extends AppException {
  BadRequestException(String message)
      : super(message, 'Permintaan tidak valid');
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message)
      : super(message, 'Permintaan tidak terautentikasi');
}

class NotFoundException extends AppException {
  NotFoundException(String message)
      : super(message, 'Data yang diminta tidak ditemukan');
}

class NoInternetException extends AppException {
  NoInternetException(String message)
      : super(message, 'Tidak ada koneksi internet');
}
