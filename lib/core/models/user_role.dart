enum UserRole {
  student,
  instructor,
  admin,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.instructor:
        return 'instructor';
      case UserRole.admin:
        return 'admin';
    }
  }
}