import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Lógica de Login com Validação no Banco
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await DbHelper.instance.loginUser(email, password);
    
    _isLoading = false;
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true; // Login com sucesso
    }
    notifyListeners();
    return false; // Falha no login
  }

  // Lógica de Cadastro de Novo Usuário
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newUser = UserModel(name: name, email: email, password: password);
      await DbHelper.instance.registerUser(newUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lógica de Deslogar
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}