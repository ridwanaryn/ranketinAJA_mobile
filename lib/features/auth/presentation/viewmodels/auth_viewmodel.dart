import 'package:flutter/foundation.dart';
import '../../../../core/services/session_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final SessionService _session;

  AuthViewModel({
    AuthRepository? repository,
    SessionService? session,
  })  : _repository = repository ?? AuthRepository(),
        _session = session ?? SessionService();

  AuthStatus _status = AuthStatus.idle;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> restoreSession() async {
    final s = await _session.loadSession();
    if (s != null) {
      _currentUser = UserModel(
        id: s['id'] as int,
        name: s['name'] as String,
        email: s['email'] as String,
        role: s['role'] as String,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.login(email: email, password: password);
    if (result.isSuccess) {
      _currentUser = result.user;
      await _session.saveSession(
        userId: result.user!.id,
        email: result.user!.email,
        name: result.user!.name,
        role: result.user!.role,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
    if (result.isSuccess) {
      _currentUser = result.user;
      await _session.saveSession(
        userId: result.user!.id,
        email: result.user!.email,
        name: result.user!.name,
        role: result.user!.role,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.error;
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _session.clearSession();
    _currentUser = null;
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
