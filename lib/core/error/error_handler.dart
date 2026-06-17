import 'failure.dart';

class ErrorHandler {
  static Failure handle(
    Object error,
  ) {
    return Failure(
      error.toString(),
    );
  }
}