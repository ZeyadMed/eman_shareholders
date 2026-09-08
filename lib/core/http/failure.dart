abstract interface class Failure {
  final String message;

  Failure(this.message);
}

class AuthFailure extends Failure {
  AuthFailure({required String message}) : super(message);
}

class ValidationFailure extends Failure {
  final List<String> errors;

  ValidationFailure({required String message, required this.errors})
      : super(message);
}

class ConnectionFailure extends Failure {
  ConnectionFailure({required String message}) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure({required String message}) : super(message);
}

class RequestTimeOutFailure extends Failure {
  RequestTimeOutFailure({required String message}) : super(message);
}

class SendTimeOutFailure extends Failure {
  SendTimeOutFailure({required String message}) : super(message);
}

class UnknownFailure extends Failure {
  UnknownFailure({required String message}) : super(message);
}

class ParsingFailure extends Failure {
  ParsingFailure({required String message}) : super(message);
  @override toString(){
    return message;
  }
}

class ServerFailure extends Failure {
  ServerFailure({required String message}) : super(message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({required String message}) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure({required String message}) : super(message);
}

class PaymentFailure extends Failure {
  PaymentFailure({required String message}) : super(message);
}

class VerifyOTPFailure extends Failure {
  VerifyOTPFailure({required String message}) : super(message);
}

class BanFailure extends Failure {
  BanFailure({required String message}) : super(message);
}

class SyncAppFailure extends Failure {
  SyncAppFailure({required String message}) : super(message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure({required String message}) : super(message);
}
class GoogleMapsFailure extends Failure {
  GoogleMapsFailure({required String message}) : super(message);
}