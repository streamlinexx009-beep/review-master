class RoleGuard {
  static bool isAdmin(String role) {
    return role == 'admin';
  }

  static bool isInstructor(
    String role,
  ) {
    return role == 'instructor';
  }

  static bool isStudent(
    String role,
  ) {
    return role == 'student';
  }
}