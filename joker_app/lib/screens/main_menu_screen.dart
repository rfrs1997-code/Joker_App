import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'ranking_screen.dart';
import 'profile_screen.dart';
import 'game_screen.dart';

// =========================================================================
// MENU PRINCIPAL DO JOGO (MAIN MENU SCREEN)
// =========================================================================
// Hub central da aplicação onde o jogador autenticado pode iniciar uma partida,
// consultar o ranking global, gerir o perfil ou encerrar a sessão.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  // =========================================================================
  // 1. ESTRUTURA PRINCIPAL DA UI (MÉTODO BUILD)
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return MenuBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIdentity(context),
              const SizedBox(height: 64),
              _buildPlayButton(context),
              const SizedBox(height: 24),
              // NAVEGAÇÃO ENTRE ECRÃS (Defesa):
              // Roteamento imperativo simples usando o padrão Navigator.push.
              _buildSecondaryButton(
                context,
                label: 'RANKING GLOBAL',
                icon: Icons.emoji_events_rounded,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingScreen()));
                },
              ),
              const SizedBox(height: 16),
              _buildSecondaryButton(
                context,
                label: 'VER PERFIL',
                icon: Icons.person_rounded,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. CONSTRUTORES DE COMPONENTES DE IDENTIDADE E BOTÕES
  // =========================================================================

  // IDENTIFICAÇÃO DO UTILIZADOR (Defesa):
  // Lê reativamente o username persistido no AuthProvider para
  // saudar o utilizador ativo no topo do menu.
  Widget _buildIdentity(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.username ?? 'Jogador';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logótipo Completo JOKER
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF001133),
                border: const Border.symmetric(
                  horizontal: BorderSide(color: Color(0xFFD4AF37), width: 2.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            Container(
              width: 180,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF001133),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                    blurRadius: 12,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'JOKER',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF2E2B0), // Dourado Champagne
                  letterSpacing: 6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Mensagem de Boas-vindas
        Text(
          'Olá, $username!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF2E2B0),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF2E2B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Color(0xFF001133), size: 32),
            SizedBox(width: 12),
            Text(
              'JOGAR NOVO JOGO',
              style: TextStyle(
                color: Color(0xFF001133),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF00081A), // Muito escuro
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFFF2E2B0), size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFF2E2B0),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 3. WIDGET DE FUNDO E ACÇÕES GLOBAIS DE BARRA (APPBAR)
// =========================================================================

// Fundo do Menu com Efeito de Vinheta Gradual e botão de Logout embutido na AppBar.
class MenuBackground extends StatelessWidget {
  final Widget child;

  const MenuBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001133), // Azul Marinho Imperial
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white54, size: 28),
            onPressed: () {
              // Limpa o token e avisa o Provider para fazer logout
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            tooltip: 'Sair',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Efeito de Vinheta Esmerada (vignette)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
