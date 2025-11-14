// BAB 6 Retrofit Service

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'task_api_model.dart';
// Penting: File ini akan memiliki file pendamping task_api_service.g.dart
part 'task_api_service.g.dart';

// Menggunakan endpoint mock API yang valid (jsonplaceholder)
// untuk mencegah error koneksi ke 'example.com'.
@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com')
abstract class TaskApiService {
  // Optional interface to allow generated code to accept an error logger.
  // You can implement this to log parse errors coming from responses.
  // Keep it simple so generated code can reference it.
  // NOTE: This must be defined before the factory so the type is visible.
  // The generated implementation will accept this as an optional named param.
  // Example implementation can be provided elsewhere if desired.
  //
  // interface-like class:
  // class ParseErrorLogger { void logError(Object e, StackTrace s, RequestOptions o) {} }

  /// Factory constructor that matches the generated implementation.
  factory TaskApiService(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _TaskApiService;

  // Operasi CRUD dasar menggunakan resource 'todos'

  @POST('/todos')
  Future<TaskDto> createTask(@Body() TaskDto task);

  @GET('/todos')
  Future<List<TaskDto>> getTasks();

  @GET('/todos/{id}')
  Future<TaskDto> getTaskById(@Path('id') int id);

  @PUT('/todos/{id}')
  Future<TaskDto> updateTask(@Path('id') int id, @Body() TaskDto task);

  @DELETE('/todos/{id}')
  Future<void> deleteTask(@Path('id') int id);
}