import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

// =========================================================================
// ECRÃ DE PERFIL DO UTILIZADOR (PROFILE SCREEN)
// =========================================================================
// Exibe os dados de identificação do jogador, fotografia de perfil
// e métricas globais de desempenho acumuladas.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ApiService().getPlayerStats(); // Chama a tua API
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  // =========================================================================
  // 1. ESTRUTURA PRINCIPAL DA UI (MÉTODO BUILD)
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001133),
      appBar: AppBar(
        title: const Text(
          'O MEU PERFIL',
          style: TextStyle(
            color: Color(0xFFF2E2B0),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAvatar(context),
                    const SizedBox(height: 48),
                    _buildStatsGrid(),
                  ],
                ),
              ),
      ),
    );
  }

  // =========================================================================
  // 2. CONSTRUTORES DE COMPONENTES (AVATAR E DETALHES DE ESTADO)
  // =========================================================================

  // AVATAR DE UTILIZADOR (Defesa):
  // Exibe a foto de perfil do utilizador ou um ícone padrão rodeado de
  // moldura dourada premium para manter a estética televisiva do jogo.
  Widget _buildAvatar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.username ?? 'joker_fan';
    final displayName = username.toUpperCase();

    return Column(
      children: [
        // Avatar circular com borda dupla dourada
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00081A),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              // Ícone de silhueta dourada
              child: Icon(Icons.person, size: 60, color: Color(0xFFD4AF37)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Nome de exibição
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF2E2B0),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        // @Username dourado brilhante
        Text(
          '@$username',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. TABELA E GRID DE ESTATÍSTICAS DO JOGADOR
  // =========================================================================

  // GRID DE ESTATÍSTICAS (Defesa):
  // Apresenta cartões estatísticos das partidas (Maiores Prémios, Níveis Máximos, etc.).
  // Nota: Atualmente estes dados estão estáticos/mockados para demonstração de layout,
  // podendo ser ligados a endpoints de agregação no C# em futuras fases.
  Widget _buildStatsGrid() {
    final maxPrize = _stats?['maxPrize'] ?? 0;
    final maxLevel = _stats?['maxLevel'] ?? 0;
    final gamesPlayed = _stats?['gamesPlayed'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          icon: Icons.savings_rounded, // Ícone de "saco de dinheiro" / mealheiro
          title: 'Maior Prémio',
          value: '$maxPrize €',
        ),
        _buildStatCard(
          icon: Icons.emoji_events_rounded, // Ícone de Troféu
          title: 'Nível Máximo',
          value: '$maxLevel',
        ),
        _buildStatCard(
          icon: Icons.sports_esports_rounded, // Ícone de Comando de Jogo
          title: 'Partidas Jogadas',
          value: '$gamesPlayed',
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF00081A), // Fundo Azul Marinho Profundo
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37), width: 0.5), // bordas douradas muito finas
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 36),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF2E2B0).withValues(alpha: 0.6), // champagne atenuada
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFFF2E2B0), // numéricos grandes e negrito
            ),
          ),
        ],
      ),
    );
  }
}
