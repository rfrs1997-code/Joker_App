import 'package:flutter/material.dart';
import '../services/api_service.dart';

// =========================================================================
// GESTÃO DE AUTENTICAÇÃO (AUTH PROVIDER)
// =========================================================================
// Responsável por gerir a sessão local do utilizador, persistir e
// validar tokens JWT, e gerir o estado de login/logout.
class AuthProvider with ChangeNotifier {
  // =========================================================================
  // 1. ATRIBUTOS E ESTADO DE AUTENTICAÇÃO
  // =========================================================================
  final ApiService _apiService = ApiService();
  String? _token;
  String? _username; // Guardado localmente para destaque reativo no ranking
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get username => _username;

  // =========================================================================
  // 2. MÉTODOS DE CONTROLO DE SESSÃO
  // =========================================================================

  // VERIFICAÇÃO AUTOMÁTICA DE SESSÃO (Defesa):
  // Executado no arranque da aplicação. Tenta recuperar credenciais e tokens 
  // persistidos no SharedPreferences para contornar o login manual.
  Future<void> checkAuth() async {
    _token = await _apiService.getToken();
    _username = await _apiService.getSavedUsername();
    notifyListeners();
  }

  // FLUXO DE LOGIN (Defesa):
  // Comunica com o backend, guarda o token JWT e nome do utilizador 
  // localmente no sucesso, e atualiza o estado da UI.
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.login(username, password);
    _token = result?['token'];
    _username = result?['username'];
    
    _isLoading = false;
    notifyListeners();
    return _token != null;
  }

  // FLUXO DE LOGOUT (Defesa):
  // Limpa de forma segura o token JWT e o username local e no armazenamento
  // persistente do dispositivo, forçando o redirecionamento imediato para o login.
  Future<void> logout() async {
    await _apiService.logout();
    _token = null;
    _username = null;
    notifyListeners();
  }
}
