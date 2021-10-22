class ApiException implements Exception {
  final dynamic _message;
  final dynamic _prefix;

  ApiException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends ApiException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends ApiException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends ApiException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends ApiException {
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException([message])
      : super(message, "Internal Server Error: ");
}
