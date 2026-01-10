import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

void _log(String message) {
  if (kDebugMode) {
    print('[AuthBloc] $message');
  }
}

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserUpdated extends AuthEvent {
  final UserModel user;

  const AuthUserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserUpdated>(_onAuthUserUpdated);

    // Listen to auth state changes
    _authSubscription = authRepository.authStateChanges.listen((authState) async {
      if (authState.session != null) {
        try {
          final user = await authRepository.getCurrentUser();
          if (user != null) {
            add(AuthUserUpdated(user));
          }
        } catch (_) {}
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _log('Checking auth state...');
    emit(AuthLoading());
    
    try {
      final user = await authRepository.getCurrentUser();
      
      if (user != null) {
        _log('User authenticated: ${user.email}');
        emit(AuthAuthenticated(user));
      } else {
        _log('No authenticated user found');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      _log('Auth check error: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    _log('Login requested for: ${event.email}');
    emit(AuthLoading());
    
    try {
      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      
      _log('Login successful for: ${user.email}');
      emit(AuthAuthenticated(user));
    } catch (e) {
      _log('Login failed: $e');
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _log('Logout requested');
    // Don't emit loading state to avoid hanging - directly sign out and emit unauthenticated
    try {
      await authRepository.signOut();
      _log('Logout successful');
    } catch (e) {
      _log('Logout error (still proceeding): $e');
      // Even if signOut throws, we still want to clear local state
    }
    // Always emit unauthenticated after logout attempt
    emit(AuthUnauthenticated());
  }

  void _onAuthUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthAuthenticated(event.user));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
