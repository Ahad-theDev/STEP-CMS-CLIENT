class RegisterRequest {
  final String username;
  final String email;
  final String phone;
  final String fullName;
  final String password;
  final String role;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'phone': phone,
    "full_name": fullName,
    "password": password,
    'role': role,
  };
}
