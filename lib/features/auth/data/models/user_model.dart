import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.login,
    super.sessionId,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;
    if (result == null) {
      throw Exception('Login failed: invalid credentials');
    }

    // Support standard Odoo response: result.uid, result.name, result.username
    if (result.containsKey('uid') && result['uid'] != false) {
      return UserModel(
        id: result['uid'] as int,
        name: result['name'] as String? ?? '',
        login: result['username'] as String? ?? '',
        role: result['role'] as String? ?? '',
      );
    }

    // Support custom response shape used by some endpoints: result.profile {...}
    if (result.containsKey('profile') && result['profile'] is Map<String, dynamic>) {
      final profile = result['profile'] as Map<String, dynamic>;
      return UserModel(
        id: profile['id'] as int,
        name: profile['name'] as String? ?? '',
        // email sometimes used as login identifier in custom responses
        login: (profile['email'] as String?) ?? (profile['login'] as String?) ?? '',
        role: profile['role'] as String? ?? '',
      );
    }

    throw Exception('Login failed: unsupported response format');
  }

  factory UserModel.fromStorage({
    required int id,
    required String name,
    required String login,
    String? sessionId,
    String role = '',
  }) {
    return UserModel(id: id, name: name, login: login, sessionId: sessionId, role: role);
  }
}
