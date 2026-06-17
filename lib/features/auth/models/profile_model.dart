class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String role;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory ProfileModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ProfileModel(
      id: map['id'],
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      role: map['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
    };
  }
}