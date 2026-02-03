class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? group;
  final String? studentId;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.group,
    this.studentId,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("DEBUG: UserModel.fromJson Parsing...");
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(), 
      role: (json['role'] ?? 'student').toString(),
      group: json['group']?.toString(),
      studentId: json['studentId']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'group': group,
      'profileImage': profileImage,
    };
  }
}
