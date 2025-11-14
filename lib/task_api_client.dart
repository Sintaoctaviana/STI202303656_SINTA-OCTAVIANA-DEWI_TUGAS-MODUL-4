import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'task_api_model.dart';
import 'task_api_service.dart';
import 'parse_error_logger.dart';
import 'package:retrofit/error_logger.dart' as retrofit_logger;

/// Thin wrapper around the generated TaskApiService that adds timeout and
/// simple retry behavior for network operations.
class TaskApiClient {
  TaskApiClient({Dio? dio, retrofit_logger.ParseErrorLogger? logger})
      : _dio = dio ?? Dio(),
        _logger = logger ?? AppParseErrorLogger() {
    _service = TaskApiService(_dio, errorLogger: _logger);
  }

  final Dio _dio;
  final retrofit_logger.ParseErrorLogger? _logger;
  late final TaskApiService _service;

  Future<T> _withRetry<T>(Future<T> Function() action,
      {int retries = 2, Duration timeout = const Duration(seconds: 8)}) async {
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        return await action().timeout(timeout);
      } on TimeoutException catch (e, st) {
        _logger?.logError(e, st, RequestOptions(path: 'timeout'));
        if (attempt > retries) rethrow;
      } on DioException catch (e, st) {
        // Log detailed info for debugging: status, response body, request headers
        try {
          final status = e.response?.statusCode;
          final data = e.response?.data;
          final req = e.requestOptions;
          debugPrint('DioException caught: status=$status, path=${req.path}');
          debugPrint('Request headers: ${req.headers}');
          debugPrint('Response body: $data');
        } catch (logErr) {
          debugPrint('Error while logging DioException details: $logErr');
        }

        _logger?.logError(e, st, e.requestOptions);
        if (attempt > retries) rethrow;
        // small backoff
        await Future.delayed(Duration(milliseconds: 200 * attempt));
      } catch (e, st) {
        _logger?.logError(e, st, RequestOptions(path: 'unknown'));
        rethrow;
      }
    }
  }

  Future<TaskDto> createTask(TaskDto task) =>
      _withRetry(() => _service.createTask(task));

  Future<List<TaskDto>> getTasks() => _withRetry(() => _service.getTasks());

  Future<TaskDto> getTaskById(int id) => _withRetry(() => _service.getTaskById(id));

  Future<TaskDto> updateTask(int id, TaskDto task) =>
      _withRetry(() => _service.updateTask(id, task));

  Future<void> deleteTask(int id) => _withRetry(() => _service.deleteTask(id));
}
