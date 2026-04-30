import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String baseUrl;
  final String db;
  final String username;
  final String password;

  AuthLoginRequested({
    required this.baseUrl,
    required this.db,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [baseUrl, db, username, password];
}

class AuthLogoutRequested extends AuthEvent {}
