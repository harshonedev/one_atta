import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_event.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SendLoginOtpRequested>(_onSendLoginOtpRequested);
    on<VerifyLoginOtpRequested>(_onVerifyLoginOtpRequested);
    on<SendRegistrationOtpRequested>(_onSendRegistrationOtpRequested);
    on<VerifyRegistrationOtpRequested>(_onVerifyRegistrationOtpRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final isLoggedInResult = await authRepository.isLoggedIn();

    isLoggedInResult.fold((failure) => emit(AuthUnauthenticated()), (
      isLoggedIn,
    ) async {
      if (isLoggedIn) {
        final userResult = await authRepository.getCurrentUser();
        userResult.fold((failure) => emit(AuthUnauthenticated()), (user) {
          if (user != null) {
            emit(AuthAuthenticated(user: user));
          } else {
            emit(AuthUnauthenticated());
          }
        });
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onSendLoginOtpRequested(
    SendLoginOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.sendLoginOtp(event.mobile);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (otpResponse) => emit(
        OtpSent(message: otpResponse.message, testOtp: otpResponse.testOtp),
      ),
    );
  }

  Future<void> _onVerifyLoginOtpRequested(
    VerifyLoginOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.verifyLoginOtp(event.mobile, event.otp);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (authResponse) => emit(AuthAuthenticated(user: authResponse.user)),
    );
  }

  Future<void> _onSendRegistrationOtpRequested(
    SendRegistrationOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.sendRegistrationOtp(
      mobile: event.mobile,
      name: event.name,
      email: event.email,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (otpResponse) => emit(
        OtpSent(message: otpResponse.message, testOtp: otpResponse.testOtp),
      ),
    );
  }

  Future<void> _onVerifyRegistrationOtpRequested(
    VerifyRegistrationOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.verifyRegistrationOtp(
      mobile: event.mobile,
      otp: event.otp,
      name: event.name,
      email: event.email,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (authResponse) => emit(AuthAuthenticated(user: authResponse.user)),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.removeToken();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
