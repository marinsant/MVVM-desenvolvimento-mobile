import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../database/db_helper.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await DbHelper.instance.loginUser(email, password);
      
      if (userData != null) {
        _currentUser = UserModel.fromMap(userData);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Erro no login: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(UserModel newUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Validação prévia de e-mail existente
      final emailExists = await DbHelper.instance.checkEmailExists(newUser.email);
      if (emailExists) {
        _isLoading = false;
        notifyListeners();
        return false; // Trava aqui e retorna falso para a View exibir o erro
      }

      // 2. Tenta inserir se passar pelo filtro
      final result = await DbHelper.instance.registerUser(newUser.toMap());
      
      if (result > 0) {
        _currentUser = newUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Erro no registro: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}