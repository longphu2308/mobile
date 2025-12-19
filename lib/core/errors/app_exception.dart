class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException({required String message, String? code})
    : super(message: message, code: code);
}

class FirestoreException extends AppException {
  FirestoreException({required String message, String? code})
    : super(message: message, code: code);
}

class NetworkException extends AppException {
  NetworkException({required String message, String? code})
    : super(message: message, code: code);
}

class StorageException extends AppException {
  StorageException({required String message, String? code})
    : super(message: message, code: code);
}