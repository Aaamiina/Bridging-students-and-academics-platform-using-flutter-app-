import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bridging_students_and_academics_platform/api/api_users.dart';
import 'package:bridging_students_and_academics_platform/core/app_config.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});
  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final ApiUsers _apiService = ApiUsers();
  final ImagePicker _picker = ImagePicker();
  final Color brandGreen = const Color(0xFF4A6D3F);

  bool showForm = false;
  bool isEditing = false;
  String? editingId;
  bool _isLoading = false;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  List<dynamic> users = [];

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  
  String role = "Student"; 
  bool isActive = true;

  final TextEditingController _searchController = TextEditingController();
  String _roleFilter = "All"; // All, Admin, Supervisor, Student

  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredUsers {
    var list = users.where((u) => (u['role'] ?? '').toString() != 'Admin').toList();
    if (_roleFilter != "All") {
      list = list.where((u) => (u['role'] ?? '').toString() == _roleFilter).toList();
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        final role = (u['role'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q) || role.contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> _pickAndImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      _showSnack("Could not read file. Try selecting again.", Colors.red);
      return;
    }
    setState(() => _isLoading = true);
    final res = await _apiService.importUsers(file.bytes!, file.name);
    setState(() => _isLoading = false);
    if (res != null) {
      _fetchUsers();
      try { Get.find<AdminController>().fetchData(); } catch (_) {}
      final created = res['created'] ?? 0;
      final skipped = (res['skipped'] as List?)?.length ?? 0;
      final errors = (res['errors'] as List?)?.length ?? 0;
      _showSnack("Import done: $created created, $skipped skipped, $errors errors", Colors.green);
    }
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getUsers();
    setState(() { users = data; _isLoading = false; });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      if (mounted) {
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
        });
      }
    }
  }

  void _submitForm() async {
    if (name.text.isEmpty || email.text.isEmpty) {
       _showSnack("Please fill required fields", Colors.red);
       return;
    }

    setState(() => _isLoading = true);
    
    final userData = {
      "name": name.text,
      "email": email.text,
      "role": role,
      "phone": phone.text,
      "status": isActive,
    };
    
    if (password.text.isNotEmpty) userData["password"] = password.text;
    if (role == "Student") userData["studentId"] = studentIdController.text;

    bool success;
    if (isEditing && editingId != null) {
      final res = await _apiService.updateUser(
        editingId!,
        userData,
        imageBytes: _selectedImageBytes,
        imageFilename: _selectedImageName,
      );
      success = res != null;
    } else {
      success = await _apiService.createUser(
        userData,
        imageBytes: _selectedImageBytes,
        imageFilename: _selectedImageName,
      );
    }
    
    setState(() => _isLoading = false);

    if (success) {
      _fetchUsers();
      setState(() { showForm = false; isEditing = false; editingId = null; });
      _clearForm();
      _showSnack(isEditing ? "User Updated!" : "User Created!", Colors.green);
    } else {
      _showSnack("Operation failed", Colors.red);
    }
  }

  void _clearForm() {
    name.clear(); email.clear(); password.clear(); phone.clear(); studentIdController.clear();
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      role = "Student";
      isActive = true;
      isEditing = false;
      editingId = null;
    });
  }

  void _editUser(dynamic user) {
    setState(() {
      isEditing = true;
      editingId = user['_id'];
      showForm = true;
      name.text = user['name'] ?? "";
      email.text = user['email'] ?? "";
      phone.text = user['phone'] ?? "";
      studentIdController.text = user['studentId'] ?? "";
      role = user['role'] ?? "Student";
      isActive = user['status'] == true;
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  void _confirmDelete(String id, String userName) {
    Get.defaultDialog(
      title: "Delete User",
      middleText: "Are you sure you want to delete $userName?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        setState(() => _isLoading = true);
        final success = await _apiService.deleteUser(id);
        if (success) {
          _fetchUsers();
          // Refresh AdminController to update groups and other pages
          try {
            Get.find<AdminController>().fetchData();
          } catch (e) {
            print("DEBUG: AdminController not found, skipping refresh");
          }
        }
        setState(() => _isLoading = false);
      }
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchUsers,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Ensures refresh works even if list is short
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("User Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: _isLoading ? null : _pickAndImportFile,
                            icon: const Icon(Icons.upload_file, size: 18, color: Colors.white),
                            label: const Text("Import CSV", style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: TextButton.styleFrom(
                              backgroundColor: brandGreen.withOpacity(0.9),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.help_outline, size: 22, color: Color(0xFF4A6D3F)),
                            tooltip: "CSV format",
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text("CSV Import Format"),
                                  content: const SingleChildScrollView(
                                    child: Text(
                                      "First row must be headers:\n\n"
                                      "name, email, password, role, studentId, phone\n\n"
                                      "• name, email, password, role are required\n"
                                      "• role: Admin, Supervisor, or Student\n"
                                      "• studentId: only for Student role\n"
                                      "• phone: optional\n\n"
                                      "Example:\n"
                                      "John Doe,john@uni.edu,pass123,Student,S001,5551234\n"
                                      "Jane Smith,jane@uni.edu,pass456,Supervisor,,5555678",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(), child: const Text("OK")),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              if (showForm) _clearForm();
                              setState(() => showForm = !showForm);
                            },
                            icon: Icon(showForm ? Icons.close : Icons.add, color: Colors.white, size: 18),
                            label: Text(showForm ? "Close" : "Add User", style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name, email, or role...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF4A6D3F)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  // Role filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["All", "Supervisor", "Student"].map((r) {
                        final sel = _roleFilter == r;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(r),
                            selected: sel,
                            onSelected: (v) => setState(() => _roleFilter = r),
                            backgroundColor: Colors.white,
                            selectedColor: brandGreen.withOpacity(0.3),
                            checkmarkColor: brandGreen,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (showForm) _buildAnimatedForm(),
                  const SizedBox(height: 20),
                  _isLoading && !showForm 
                    ? const Center(child: CircularProgressIndicator()) 
                    : _buildUserList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
             Text(isEditing ? "Edit User" : "Add New User", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'InriaSerif')),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _selectedImageBytes != null
                        ? MemoryImage(_selectedImageBytes!)
                        : null,
                    child: _selectedImageBytes == null
                        ? const Icon(Icons.person, size: 50, color: Color(0xFF4A6D3F))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: brandGreen,
                      child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildField(name, "Full Name", Icons.person),
            _buildField(email, "Email", Icons.email),
            if (role == "Student") _buildField(studentIdController, "Student ID", Icons.badge),
            _buildField(password, isEditing ? "New Password (Optional)" : "Password", Icons.lock, isPass: true),
            _buildField(phone, "Phone Number", Icons.phone),
            
            // --- DROPDOWN FIELD FOR ROLE ---
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(
                labelText: "User Role",
                labelStyle: TextStyle(color: brandGreen),
                prefixIcon: Icon(Icons.assignment_ind, color: brandGreen),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: brandGreen)),
              ),
              items: ["Admin", "Supervisor", "Student"]
                  .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => role = value!);
              },
            ),

            // --- SWITCH FOR STATUS ---
            SwitchListTile(
              title: Text("Active", style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold)),
              value: isActive,
              activeColor: brandGreen,
              onChanged: (bool value) {
                setState(() => isActive = value);
              },
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEditing ? "Update User" : "Create User", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, IconData icon, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        obscureText: isPass,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: brandGreen),
          labelText: label,
          labelStyle: TextStyle(color: brandGreen),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: brandGreen)),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    final list = _filteredUsers;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            users.isEmpty ? "No users yet." : "No users match your search or filter.",
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final user = list[index];
        final String? imgUrl = user['profileImage'];
        // Construct full URL using AppConfig
        final String fullImgUrl = (imgUrl != null && imgUrl.isNotEmpty) 
            ? "${AppConfig.imageBaseUrl}$imgUrl" 
            : "";

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: brandGreen.withOpacity(0.1),
                  backgroundImage: fullImgUrl.isNotEmpty ? NetworkImage(fullImgUrl) : null,
                  child: fullImgUrl.isEmpty ? Icon(Icons.person, color: brandGreen) : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user['name'] ?? "No Name",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        "${user['role']} ${user['studentId'] != null ? '• ${user['studentId']}' : ''}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () => _editUser(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _confirmDelete(user['_id'], user['name'] ?? "User"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}