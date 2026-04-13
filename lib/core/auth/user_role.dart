enum UserRole {
  client,
  staff;

  static UserRole fromString(String value) {
    switch (value) {
      case 'staff': return UserRole.staff;
      default: return UserRole.client;
    }
  }
}
