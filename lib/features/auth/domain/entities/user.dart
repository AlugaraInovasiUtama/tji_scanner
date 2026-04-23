import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String login;
  final String? sessionId;
  /// User's warehouse role: 'admin', 'helper', or '' (unknown)
  final String role;

  const User({
    required this.id,
    required this.name,
    required this.login,
    this.sessionId,
    this.role = '',
  });

  @override
  List<Object?> get props => [id, name, login, sessionId, role];
}
