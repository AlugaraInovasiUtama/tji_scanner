import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String login;
  final String? sessionId;

  const User({
    required this.id,
    required this.name,
    required this.login,
    this.sessionId,
  });

  @override
  List<Object?> get props => [id, name, login, sessionId];
}
