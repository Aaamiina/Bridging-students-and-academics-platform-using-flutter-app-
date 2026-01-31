import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bridging_students_and_academics_platform/api/api_users.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});
  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final ApiUsers _apiService = ApiUsers();
  final ImagePicker _picker = ImagePicker();
  
  bool showForm = false;
  bool _isLoading = false;
  File? _selectedImage;
  String? _token;
  List<dynamic> users = [];

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phone = TextEditingController();
  
  // NEW FIELDS
  String role = "Student"; 
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');
    if (savedToken != null) {
      setState(() => _token = savedToken);
      _fetchUsers();
    }
  }

  Future<void> _fetchUsers() async {
    if (_token == null) return;
    setState(() => _isLoading = true);
    final data = await _apiService.getUsers(_token!);
    setState(() { users = data; _isLoading = false; });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _submitForm() async {
    if (name.text.isEmpty || email.text.isEmpty || _token == null) {
       _showSnack("Please fill required fields", Colors.red);
       return;
    }

    setState(() => _isLoading = true);
    
    final userData = {
      "name": name.text,
      "email": email.text,
      "password": password.text,
      "role": role, // Using the selected role from dropdown
      "phone": phone.text,
      "status": isActive ? "Active" : "Inactive",
    };

    final success = await _apiService.createUser(userData, _token!, _selectedImage);
    
    setState(() => _isLoading = false);

    if (success) {
      _fetchUsers();
      setState(() => showForm = false);
      _clearForm();
      _showSnack("User Created Successfully!", Colors.green);
    } else {
      _showSnack("Failed to create user", Colors.red);
    }
  }

  void _clearForm() {
    name.clear(); email.clear(); password.clear(); phone.clear();
    setState(() {
      _selectedImage = null;
      role = "Student";
      isActive = true;
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("User Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A6D3F))),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A6D3F)),
                      onPressed: () => setState(() => showForm = !showForm),
                      icon: Icon(showForm ? Icons.close : Icons.add, color: Colors.white),
                      label: Text(showForm ? "Close" : "Add", style: const TextStyle(color: Colors.white)),
                    )
                  ],
                ),
                const SizedBox(height: 20),
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
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null 
                        ? const Icon(Icons.person, size: 50, color: Color(0xFF4A6D3F)) 
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFF4A6D3F),
                      child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildField(name, "Full Name", Icons.person),
            _buildField(email, "Email", Icons.email),
            _buildField(password, "Password", Icons.lock, isPass: true),
            _buildField(phone, "Phone Number", Icons.phone),
            
            // --- DROPDOWN FIELD FOR ROLE ---
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(
                labelText: "User Role",
                labelStyle: const TextStyle(color: Color(0xFF4A6D3F)),
                prefixIcon: const Icon(Icons.assignment_ind, color: Color(0xFF4A6D3F)),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4A6D3F))),
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
              title: const Text("Account Active", style: TextStyle(color: Color(0xFF4A6D3F), fontWeight: FontWeight.bold)),
              value: isActive,
              activeColor: const Color(0xFF4A6D3F),
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
                  backgroundColor: const Color(0xFF4A6D3F), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          prefixIcon: Icon(icon, color: const Color(0xFF4A6D3F)),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4A6D3F)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4A6D3F))),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFF4A6D3F), child: Icon(Icons.person, color: Colors.white)),
            title: Text(user['name'] ?? "No Name"),
            subtitle: Text(user['role'] ?? "Student"),
            trailing: Icon(Icons.circle, color: user['status'] == "Active" ? Colors.green : Colors.red, size: 12),
          ),
        );
      },
    );
  }
}