import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// =========================================================================
// SERVIÇO DE COMUNICAÇÃO COM A API (API SERVICE)
// =========================================================================
// Centraliza todas as chamadas HTTP (REST) ao backend em ASP.NET Core C#,
// incluindo gestão de persistência de tokens JWT e envio de ficheiros (Multipart).
class ApiService {
  // =========================================================================
  // 1. CONFIGURAÇÃO DE ENDEREÇOS E CONEXÃO
  // =========================================================================
  // CONFIGURAÇÃO DE HOST (Defesa):
  // - iOS Simulator / macOS: usa-se 'http://localhost:5219/api'.
  // - Android Emulator: necessita de 'http://10.0.2.2:5219/api' devido ao NAT do emulador.
  static const String baseUrl = 'http://localhost:5219/api';
  // =========================================================================
  // 2. ENDPOINTS DE AUTENTICAÇÃO E REGISTO DE UTILIZADORES
  // =========================================================================

  // ENVIO MULTIPART (Defesa):
  // Envia os dados do formulário e o ficheiro da foto de perfil como um
  // 'MultipartRequest' para corresponder ao DTO e ao 'IFormFile' no ASP.NET Core.
  Future<bool> register(
    String name,
    String username,
    String email,
    String password, {
    File? imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/Auth/register');

    try {
      final request = http.MultipartRequest('POST', url);

      request.fields['Name'] = name;
      request.fields['Username'] = username;
      request.fields['Email'] = email;
      request.fields['Password'] = password;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'ProfilePicture', 
            imageFile.path,
          ),
        );
      }

      // --- ALTERAÇÃO AQUI: Capturamos a resposta completa ---
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('DEBUG REGISTO - Status: ${response.statusCode}');
      debugPrint('DEBUG REGISTO - Body: ${response.body}');
      // ----------------------------------------------------

      return response.statusCode == 200 || response.statusCode == 201;
      
    } catch (e) {
      debugPrint('Erro CRÍTICO no registo: $e');
      return false;
    }
  }

  // PERSISTÊNCIA DE JWT (Defesa):
  // Realiza o POST das credenciais, recebe o JWT Token e o Username,
  // e persiste-os no armazenamento local através da biblioteca SharedPreferences.
  Future<Map<String, String>?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/Auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // O AuthController devolve { Token, Username }
        final token = data['token'] as String;
        final savedUsername = data['username'] as String;

        // Guarda token e username no armazenamento local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('username', savedUsername);

        return {'token': token, 'username': savedUsername};
      }
      return null; // Credenciais inválidas ou erro
    } catch (e) {
      debugPrint('Erro no login: $e');
      return null;
    }
  }

  // =========================================================================
  // 3. AUXILIARES DE ARMAZENAMENTO LOCAL (SHARED PREFERENCES)
  // =========================================================================

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('username');
  }

  // =========================================================================
  // 4. ENDPOINTS DO FLUXO DO JOGO E RANKINGS
  // =========================================================================

  // CONSUMO DE PERGUNTAS (Defesa):
  // Acede ao endpoint protegido '/Game/questions'. Requer o cabeçalho 'Authorization'
  // contendo o Bearer Token obtido após login com sucesso.
  Future<List<Map<String, dynamic>>?> getQuestions() async {
    final url = Uri.parse('$baseUrl/Game/questions');
    final token = await getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao obter perguntas da API: $e');
      return null;
    }
  }

  //CONSUMO DO PROFILE DO JOGADOR (Defesa)
  
  Future<Map<String, dynamic>?> getPlayerStats() async {
  final url = Uri.parse('$baseUrl/GameResults/stats'); // Exemplo
  final token = await getToken();
  
  final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body); // Retorna algo como { "maxPrize": 5000, "maxLevel": 15, "gamesPlayed": 20 }
  }
  return null;
}
  // PERSISTÊNCIA DE PONTUAÇÃO (Defesa):
  // Submete o nível alcançado e o prémio ganho no final do jogo
  // para que o backend grave a pontuação na BD SQL Server e atualize a tabela de resultados.
  Future<bool> submitScore(int levelReached, int moneyWon) async {
    final url = Uri.parse('$baseUrl/Game/submit-score');
    final token = await getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'levelReached': levelReached, // Alinha com SubmitResultDto.LevelReached no C#
          'moneyWon': moneyWon,         // Alinha com SubmitResultDto.MoneyWon no C#
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Erro ao submeter pontuação: $e');
      return false;
    }
  }

  // LEITURA DO RANKING GLOBAL (Defesa):
  // Consome a lista com as 10 melhores classificações registadas no sistema.
  Future<List<Map<String, dynamic>>?> getLeaderboard() async {
    final url = Uri.parse('$baseUrl/GameResults/leaderboard');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao obter o ranking: $e');
      return null;
    }
  }
}
