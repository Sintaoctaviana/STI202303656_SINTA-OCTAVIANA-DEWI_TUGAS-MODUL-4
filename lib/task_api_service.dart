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
  // Factory constructor yang diperlukan oleh Retrofit
  factory TaskApiService(Dio dio, {String baseUrl}) = _TaskApiService;

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