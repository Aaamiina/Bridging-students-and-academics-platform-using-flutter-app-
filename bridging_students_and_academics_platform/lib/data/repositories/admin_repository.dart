// import 'dart:convert';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:bridging_students_and_academics_platform/core/app_config.dart';

// class AdminRepository {
//   static const String baseUrl = AppConfig.baseUrl;
//   final GetStorage _storage = GetStorage();

//   String get _token => _storage.read('token') ?? '';

//   Future<List<dynamic>> getAllGroups() async {
//     print("DEBUG: AdminRepository.getAllGroups - Entry");
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/groups'),
//         headers: {"Authorization": "Bearer $_token"},
//       ).timeout(const Duration(seconds: 10));
//       print("DEBUG: AdminRepository.getAllGroups - Status: ${response.statusCode}");
//       return response.statusCode == 200 ? jsonDecode(response.body) : [];
//     } catch (e) {
//       print("DEBUG: AdminRepository.getAllGroups - ERROR: $e");
//       return [];
//     }
//   }

//   Future<bool> createGroup(String name, String description) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/admin/groups'),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $_token"
//         },
//         body: jsonEncode({
//           "name": name, 
//           "description": description, 
//           "academicYear": "2024-2025" // Default or dynamic if needed
//         }),
//       );
//       return response.statusCode == 201;
//     } catch (e) {
//       return false;
//     }
//   }


//   Future<bool> assignSupervisor(String groupId, String supervisorId) async {
//   try {
//     final response = await http.post(
//       Uri.parse('${AppConfig.baseUrl}/admin/assign-supervisor'), // Update this path to match your route
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer ${_storage.read('token')}"
//       },
//       body: jsonEncode({
//         "groupId": groupId,
//         "supervisorId": supervisorId
//       }),
//     );
//     return response.statusCode == 200;
//   } catch (e) {
//     return false;
//   }
// }

//   Future<bool> assignMembers(String groupId, List<String> emails) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/admin/groups/$groupId/assign'),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $_token"
//         },
//         body: jsonEncode({"emails": emails}),
//       );
//       return response.statusCode == 200;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Reusing Logic from ApiUsers but centralized here if prefered
//   // For now we keep ApiUsers separately or merge. 
//   // Let's rely on ApiUsers for User management to avoid duplication, 
//   // or fetch users here for the "Assign Students" list.
//   Future<List<dynamic>> getAllUsers() async {
//      print("DEBUG: AdminRepository.getAllUsers - Entry");
//      try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/users'),
//         headers: {"Authorization": "Bearer $_token"},
//       ).timeout(const Duration(seconds: 10));
//       print("DEBUG: AdminRepository.getAllUsers - Status: ${response.statusCode}");
//       return response.statusCode == 200 ? jsonDecode(response.body) : [];
//     } catch (e) { 
//       print("DEBUG: AdminRepository.getAllUsers - ERROR: $e");
//       return []; 
//     }
//   }

//   Future<bool> updateUserGroup(String userId, String groupName) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/admin/users/$userId'),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $_token"
//         },
//         body: jsonEncode({"group": groupName}),
//       );
//       return response.statusCode == 200;
//     } catch (e) { return false; }
//   }

//   Future<bool> removeStudentFromGroup(String userId) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/admin/users/$userId'),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $_token"
//         },
//         body: jsonEncode({"group": null}), // Clear the group field properly
//       );
//       return response.statusCode == 200;
//     } catch (e) { return false; }
//   }

//   Future<bool> deleteGroup(String groupId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/admin/groups/$groupId'),
//         headers: {"Authorization": "Bearer $_token"},
//       ).timeout(const Duration(seconds: 10));
//       return response.statusCode == 200;
//     } catch (e) { return false; }
//   }

//   Future<Map<String, dynamic>> getGlobalStats() async {
//     print("DEBUG: AdminRepository.getGlobalStats - Entry");
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/stats'),
//         headers: {"Authorization": "Bearer $_token"},
//       ).timeout(const Duration(seconds: 10));
//       print("DEBUG: AdminRepository.getGlobalStats - Status: ${response.statusCode}");
//       return response.statusCode == 200 ? jsonDecode(response.body) : {};
//     } catch (e) {
//       print("DEBUG: AdminRepository.getGlobalStats - ERROR: $e");
//       return {};
//     }
//   }

//   Future<List<dynamic>> getAdminTasks() async {
//     print("DEBUG: AdminRepository.getAdminTasks - Entry");
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/stats/tasks'),
//         headers: {"Authorization": "Bearer $_token"},
//       ).timeout(const Duration(seconds: 10));
//       print("DEBUG: AdminRepository.getAdminTasks - Status: ${response.statusCode}");
//       return response.statusCode == 200 ? jsonDecode(response.body) : [];
//     } catch (e) {
//       print("DEBUG: AdminRepository.getAdminTasks - ERROR: $e");
//       return [];
//     }
//   }

//   Future<List<dynamic>> getAdminSubmissions() async {
//     print("DEBUG: AdminRepository.getAdminSubmissions - Entry");
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/admin/stats/submissions'),
//         headers: {"Authorization": "Bearer $_token"},
//       ).timeout(const Duration(seconds: 10));
//       print("DEBUG: AdminRepository.getAdminSubmissions - Status: ${response.statusCode}");
//       return response.statusCode == 200 ? jsonDecode(response.body) : [];
//     } catch (e) {
//       print("DEBUG: AdminRepository.getAdminSubmissions - ERROR: $e");
//       return [];
//     }
//   }
// }




import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; 
import 'package:bridging_students_and_academics_platform/core/app_config.dart';

class AdminRepository {
  static const String baseUrl = AppConfig.baseUrl;
  final GetStorage _storage = GetStorage();

  String get _token => _storage.read('token') ?? '';

  /// FETCH ALL GROUPS
  Future<List<dynamic>> getAllGroups() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/groups'),
        headers: {"Authorization": "Bearer $_token"},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      print("DEBUG: AdminRepository.getAllGroups ERROR: $e");
      return [];
    }
  }

  /// UPDATE: Create Group with Named Parameters
  /// This fixes the "academicYear isn't defined" error in your Controller.
  Future<bool> createGroup({
    required String name,
    required String description,
    required String academicYear,
    String? supervisorId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/groups'), // Ensure this matches your route
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token"
        },
        body: jsonEncode({
          "name": name,
          "description": description,
          "academicYear": academicYear,
          "supervisorId": supervisorId // Can be null
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("DEBUG: AdminRepository.createGroup ERROR: $e");
      return false;
    }
  }

  /// ASSIGN SUPERVISOR TO GROUP
  /// Links a Group ID to a Supervisor ID in the Group collection.
  Future<bool> assignSupervisor(String groupId, String supervisorId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/groups/assign-supervisor'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token"
        },
        body: jsonEncode({
          "groupId": groupId,
          "supervisorId": supervisorId
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("DEBUG: AdminRepository.assignSupervisor ERROR: $e");
      return false;
    }
  }

  /// ASSIGN STUDENTS TO GROUP
  Future<bool> assignMembers(String groupId, List<String> emails) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/groups/$groupId/assign'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token"
        },
        body: jsonEncode({"emails": emails}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// FETCH ALL USERS
  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {"Authorization": "Bearer $_token"},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  /// REMOVE STUDENT FROM GROUP
  Future<bool> removeStudentFromGroup(String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token"
        },
        body: jsonEncode({"group": null}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// DELETE GROUP
  Future<bool> deleteGroup(String groupId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/groups/$groupId'),
        headers: {"Authorization": "Bearer $_token"},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// FETCH STATS & DASHBOARD DATA
  Future<Map<String, dynamic>> getGlobalStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: {"Authorization": "Bearer $_token"},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 ? jsonDecode(response.body) : {};
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> getAdminTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats/tasks'),
        headers: {"Authorization": "Bearer $_token"},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAdminSubmissions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats/submissions'),
        headers: {"Authorization": "Bearer $_token"},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      return [];
    }
  }
}