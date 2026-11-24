import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

// =========================================================================
// ECRÃ DE RANKING GLOBAL (RANKING SCREEN)
// =========================================================================
// Exibe a tabela de liderança com os 10 melhores pontuações do sistema,
// destacando o utilizador atual e estilizando o pódio de forma distinta.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  // =========================================================================
  // 1. ATRIBUTOS E INICIALIZAÇÃO DE DADOS DO LEADERBOARD
  // =========================================================================
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>>? _ranking;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  // DESCARGA DE DADOS ASSÍNCRONA (Defesa):
  // Descarrega o Top 10 de resultados através do ApiService, gerindo estados
  // de carregamento e potenciais falhas de ligação (error states).
  Future<void> _loadRanking() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final data = await _apiService.getLeaderboard();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (data != null) {
        _ranking = data;
      } else {
        _hasError = true;
      }
    });
  }

  // =========================================================================
  // 2. CONSTRUÇÃO DO ANDAIME PRINCIPAL (BUILD SCENE)
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    // Obtém o username do utilizador autenticado para o destacar na lista
    final currentUsername = Provider.of<AuthProvider>(context, listen: false).username;

    return Scaffold(
      backgroundColor: const Color(0xFF001133),
      appBar: AppBar(
        title: const Text(
          'RANKING GLOBAL',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4AF37)),
            onPressed: _loadRanking,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(currentUsername),
      ),
    );
  }

  // =========================================================================
  // 3. RENDERIZADOR DO CONTEÚDO (BODY BUILDER)
  // =========================================================================
  Widget _buildBody(String? currentUsername) {
    // Estado: A carregar
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      );
    }

    // Estado: Erro de ligação
    if (_hasError || _ranking == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 60, color: Color(0xFFD4AF37)),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar ranking',
              style: TextStyle(fontSize: 16, color: Color(0xFFF2E2B0)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadRanking,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4AF37)),
              label: const Text('Tentar novamente', style: TextStyle(color: Color(0xFFF2E2B0))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                backgroundColor: const Color(0xFF00081A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Estado: Lista vazia
    if (_ranking!.isEmpty) {
      return Center(
        child: Text(
          'Nenhum registo encontrado',
          style: TextStyle(
            fontSize: 18,
            color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
          ),
        ),
      );
    }

    // Estado: Lista com resultados
    // LÓGICA DE APRESENTAÇÃO DE LEADERBOARD (Defesa):
    // 1. Destaca o registo do jogador ativo com cores e sombras roxas diferenciadas 
    //    para contraste visual imediato.
    // 2. Formata cores metálicas exclusivas para o Pódio (1º Ouro, 2º Prata, 3º Bronze).
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _ranking!.length,
      itemBuilder: (context, index) {
        final jogador = _ranking![index];
        final String nome = jogador['username'] ?? '';
        final int highScore = jogador['highScore'] ?? 0;
        final bool isMe = nome == currentUsername;
        final int position = index + 1;

        // Cores padrão (Jogadores Gerais)
        Color cardColor = const Color(0xFF00081A); // Fundo Azul Marinho Profundo
        Color borderColor = const Color(0xFFD4AF37).withValues(alpha: 0.3);
        Color textColor = const Color(0xFFF2E2B0); // Dourado Claro
        Color scoreColor = const Color(0xFFD4AF37);
        
        // REGRA DE APRESENTAÇÃO (Destacar o próprio utilizador no Ranking):
        if (isMe) {
          cardColor = const Color(0xFFE8DDFF); // Lilás Claro
          borderColor = const Color(0xFF9C27B0); // Roxa viva
          textColor = const Color(0xFF4A148C); // Roxa Escura para legibilidade
          scoreColor = const Color(0xFF4A148C);
        }

        // CÍRCULOS METÁLICOS DO PÓDIO (Regra de Estilo):
        Color avatarColor;
        Color avatarTextColor = const Color(0xFF001133);
        if (position == 1) {
          avatarColor = const Color(0xFFFFD700); // 1º Lugar: Ouro
        } else if (position == 2) {
          avatarColor = const Color(0xFFC0C0C0); // 2º Lugar: Prata
        } else if (position == 3) {
          avatarColor = const Color(0xFFCD7F32); // 3º Lugar: Bronze
        } else {
          avatarColor = const Color(0xFF001133); // Fora do pódio
          avatarTextColor = const Color(0xFFD4AF37);
          if (isMe) {
            avatarColor = const Color(0xFF9C27B0);
            avatarTextColor = Colors.white;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isMe ? 2.5 : 1.0),
            boxShadow: isMe 
                ? [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor,
                border: Border.all(
                  color: (position > 3 && !isMe) ? const Color(0xFFD4AF37) : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: position <= 3
                    ? [
                        BoxShadow(
                          color: avatarColor.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                '$positionº',
                style: TextStyle(
                  color: avatarTextColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
            title: Text(
              isMe ? '$nome (Tu)' : nome,
              style: TextStyle(
                fontWeight: isMe ? FontWeight.w900 : FontWeight.w600,
                color: textColor,
                fontSize: 18,
              ),
            ),
            trailing: Text(
              '$highScore €',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: scoreColor,
                letterSpacing: 1.0,
              ),
            ),
          ),
        );
      },
    );
  }
}
