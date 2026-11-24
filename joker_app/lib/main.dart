import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart'; // Importa o novo provider
import 'screens/login_screen.dart';
import 'screens/main_menu_screen.dart';

// =========================================================================
// 1. INICIALIZAÇÃO DA APLICAÇÃO (MÉTODO MAIN)
// =========================================================================
// PONTO DE ENTRADA E ARQUITETURA DE ESTADO (Defesa):
// O jogo utiliza MultiProvider no topo da árvore de widgets para injetar:
// 1. AuthProvider: Gere sessão do jogador e tokens JWT.
// 2. GameProvider: Orquestra o ciclo de vida do jogo Joker.
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (context) => GameProvider()),
      ],
      child: const JokerApp(),
    ),
  );
}

// =========================================================================
// 2. CONFIGURAÇÃO GLOBAL DO WIDGET PRINCIPAL (JOKER APP)
// =========================================================================
class JokerApp extends StatelessWidget {
  const JokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Joker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // CONTROLO DE ROTEAMENTO DINÂMICO (Defesa):
      // Um Consumer escuta alterações no AuthProvider de forma reativa.
      // Se autenticado (token válido presente), renderiza o Menu Principal;
      // caso contrário, direciona automaticamente para o ecrã de Login.
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const MainMenuScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
