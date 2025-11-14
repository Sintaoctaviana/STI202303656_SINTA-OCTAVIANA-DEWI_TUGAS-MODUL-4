import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/error_logger.dart';

/// App implementation of Retrofit's ParseErrorLogger interface.
class AppParseErrorLogger implements ParseErrorLogger {
  @override
  void logError(Object error, StackTrace stack, RequestOptions options) {
    // Default: print debug info. You can replace this with any logging solution.
    debugPrint('ParseError: ${error.toString()}');
    debugPrint('Request: ${options.method} ${options.uri}');
    debugPrint('Stack: $stack');
  }
}
