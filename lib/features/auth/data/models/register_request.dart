import 'package:cms/features/auth/data/models/teacher_registration_details.dart';

class RegisterRequest {
  final String username;
  final String email;
  final String phone;
  final String fullName;
  final String password;
  final String role;
  final TeacherRegistrationDetails? teacher;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.password,
    required this.role,
    this.teacher,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'phone': phone,
    "full_name": fullName,
    "password": password,
    'role': role,
    if (teacher != null) 'teacher': teacher!.toJson(),
  };
}
