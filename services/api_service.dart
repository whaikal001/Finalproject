import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/worker.dart';
import '../models/task.dart';
import '../models/submission.dart';

class ApiService {

  static const String _baseUrl = 'http://localhost/php_backend/'; 

  static Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

     
      if (response.statusCode >= 200 && response.statusCode < 300) {
       
        if (response.body.isEmpty) {
          return {"message": "Success with no content"};
        }
        return json.decode(response.body);
      } else {
      
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['message'] ?? 'API error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
     
      throw Exception('Network error: $e');
    }
  }

  // --- Authentication APIs ---

  static Future<Map<String, dynamic>> loginWorker(String email, String password) async {
    final response = await _post('login_worker.php', {
      'email': email,
      'password': password,
    });
    return response;
  }

  static Future<Map<String, dynamic>> registerWorker(
      String fullName, String email, String password, String phone, String address) async {
    final response = await _post('register_worker.php', {
      'full_name': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
    });
    return response;
  }

  // --- Task Management APIs ---

  static Future<List<Task>> getWorkerTasks(int workerId) async {
    final response = await _post('get_work.php', {'worker_id': workerId});
    if (response['tasks'] != null) {
      final List<dynamic> taskList = response['tasks'];
      return taskList.map((json) => Task.fromJson(json)).toList();
    }
    return []; // Return empty list if no tasks or error
  }

  static Future<Map<String, dynamic>> submitWork(
      int workId, int workerId, String submissionText) async {
    final response = await _post('submit_work.php', {
      'work_id': workId,
      'worker_id': workerId,
      'submission_text': submissionText,
    });
    return response;
  }

  // --- Submission History APIs ---

  static Future<List<Submission>> getSubmissionHistory(int workerId) async {
    final response = await _post('get_submission.php', {'worker_id': workerId});
    if (response['submissions'] != null) {
      final List<dynamic> submissionList = response['submissions'];
      return submissionList.map((json) => Submission.fromJson(json)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> editSubmission(
      int submissionId, String updatedText) async {
    return await _post('edit_submission.php', {
      'submission_id': submissionId,
      'updated_text': updatedText,
    });
  }

  // --- Profile Management APIs ---

  static Future<Worker> getProfile(int workerId) async {
    final dynamic response = await _post('get_profile.php', {'worker_id': workerId});

    // The PHP get_profile.php script returns a worker object directly on success.
    // Ensure it's a Map<String, dynamic> before parsing.
    if (response is Map<String, dynamic>) {
      // If the worker data is nested under a 'worker' key (e.g., from login_worker.php),
      // or directly at the top level (e.g., from get_profile.php).
      if (response['worker'] != null && response['worker'] is Map<String, dynamic>) {
        return Worker.fromJson(response['worker'] as Map<String, dynamic>);
      } else if (response['id'] != null) { // Assume it's the worker object itself if 'id' is present
        return Worker.fromJson(response);
      }
    }
    throw Exception('Failed to load profile: ${response['message'] ?? 'Unknown error or invalid response format.'}');
  }

  static Future<Map<String, dynamic>> updateProfile(Worker worker) async {
    final Map<String, dynamic> data = worker.toJson();
    // As per requirement, email is typically not editable via this update route for security.
    // Ensure the 'email' field is not sent if it shouldn't be updated.
    // The PHP script already handles dynamic updates based on provided fields.
    return await _post('update_profile.php', data);
  }

  // --- New API for Assigning Random Task ---
  static Future<Map<String, dynamic>> assignRandomTask(
      String title, String description, String dueDate) async {
    return await _post('create_and_assign_random_task.php', {
      'title': title,
      'description': description,
      'due_date': dueDate,
    });
  }

  // --- New API for Assigning Specific Task ---
  static Future<Map<String, dynamic>> assignSpecificTask(
      String title, String description, int assignedToId, String dueDate) async {
    return await _post('assign_specific_task.php', {
      'title': title,
      'description': description,
      'assigned_to_id': assignedToId,
      'due_date': dueDate,
    });
  }
}