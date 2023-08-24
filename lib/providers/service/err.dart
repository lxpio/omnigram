abstract class BaseErrorWrapper implements Exception {
  final OpenAIError? data;
  final int? code;

  BaseErrorWrapper({this.data, this.code});

  @override
  String toString() => "status code :$code  message :${data?.error.toMap()}\n";
}

///[MissingTokenException]
///not found access token
class MissingTokenException extends BaseErrorWrapper {
  @override
  String toString() =>
      "Not Missing Your Token look more https://beta.openai.com/account/api-keys";
}

///[RequestError]
///narmal error
class RequestError extends BaseErrorWrapper {
  RequestError({super.data, super.code});
}

///Cause: Invalid Authentication
/// Solution: Ensure the correct API
/// key and requesting organization are being used.
class OpenAIAuthError extends BaseErrorWrapper {
  OpenAIAuthError({super.data, super.code});
}

///Cause: You are sending requests too quickly.
/// Solution: Pace your requests. Read the Rate limit guide.
class OpenAIRateLimitError extends BaseErrorWrapper {
  OpenAIRateLimitError({super.data, super.code});
}

///Cause: Issue on our servers.
///Solution: Retry your request
/// after a brief wait and
/// contact us if the issue persists. Check the status page.
class OpenAIServerError extends BaseErrorWrapper {
  OpenAIServerError({super.data, super.code});
}

class OpenAIError {
  final String message;
  final ErrorData error;

  OpenAIError({required this.message, required this.error});

  factory OpenAIError.fromJson(Map<String, dynamic>? json, String message) =>
      OpenAIError(
        message: message,
        error: ErrorData.fromJson(json?['error']),
      );
}

class ErrorData {
  final String? message;
  final String? type;
  final String? code;

  ErrorData({this.message, this.type, this.code});

  factory ErrorData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ErrorData();
    }

    return ErrorData(
      message: json['message'],
      code: json['code'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toMap() =>
      Map.of({'message': message, 'code': code, 'type': type});
}
